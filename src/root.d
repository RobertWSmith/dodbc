module dodbc.root;

public import dodbc.type_alias;
public import dodbc.constants;

import std.traits : isImplicitlyConvertible;
import std.typecons : Ternary;
import std.conv : to;
import std.string : fromStringz;

package ODBCReturn ret(return_type rc)
{
    return to!ODBCReturn(rc);
}

package bool isAllocated(handle_t handle)
{
    return !(handle == SQL_NULL_HANDLE);
}

package string[] diagnose(HandleType ht, handle_t handle)
{
    string[] output;
    if (isAllocated(handle))
    {
        string temp_output;
        SQLSMALLINT rec = 0;
        SQLCHAR[7] state;
        SQLINTEGER native_err = 0;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] message;
        SQLSMALLINT buffer_length, text_length;
        ODBCReturn ret = ODBCReturn.Success;

        while (ret != ODBCReturn.NoData)
        {
            // append newline if this isn't the first call to SQLGetDiagRec
            if (rec > 1)
                output ~= "\n";
            rec++;
            state[] = '\0';
            message[] = '\0';
            buffer_length = message.length - 1;
            text_length = 0;
            ret = to!ODBCReturn(SQLGetDiagRec(ht, handle, rec, state.ptr,
                    &native_err, message.ptr, buffer_length, &text_length));
            temp_output = to!string(native_err) ~ " [" ~ to!string(
                    fromStringz(state.ptr)) ~ "] " ~ to!string(fromStringz(message.ptr));
            output ~= temp_output;
        }
    }
    return output;
}

package bool evaluate_bitmask(T, U)(T true_val, U eval_val)
        if (isImplicitlyConvertible!(T, U) && isImplicitlyConvertible!(U, T))
{
    BitArray tArr = BitArray(to!(void[])(true_val), true_val.sizeof);
    BitArray eArr = BitArray(to!(void[])(eval_val), eval_val.sizeof);

    bool output = true;
    foreach (tup; zip(tArr, eArr))
    {
        // if the bit is set on the test array, check the eval array - else, ignore
        if (tup[0])
            output &= (tup[0] & tup[1]);

        // if the output is set to FALSE at any point, break loop and return
        if (!output)
            break;
    }

    return output;
}

abstract class Root(HandleType _ht)
{
    package handle_t _handle;
    public enum HandleType handle_enum = _ht;
    public enum SQLSMALLINT handle_type = to!SQLSMALLINT(_ht);

    this()
    {
        this.nullify();
    }

    ~this()
    {
        this.free();
    }

    public final @property immutable(bool) isAllocated()
    {
        return (this.handle).isAllocated;
    }

    public final @property handle_t handle()
    {
        return this._handle;
    }

    private final @property void handle(handle_t input)
    {
        this._handle = input;
    }

    public ODBCReturn allocate(handle_t prior = SQL_NULL_HANDLE)
    {
        ODBCReturn output = this.free();
        output = ret(SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &this._handle));
        return output;
    }

    public ODBCReturn free()
    {
        ODBCReturn output = ODBCReturn.Success;
        if (this.isAllocated)
            output = ret(SQLFreeHandle(handle_type, this._handle));
        this.nullify();
        return output;
    }

    private void nullify()
    {
        this.handle = SQL_NULL_HANDLE;
    }
}

abstract class Handle(HandleType _ht, alias _getAttr, alias _setAttr, alias _attrEnum) : Root!(_ht)
{
    public alias GetAttribute = _getAttr;
    public alias SetAttribute = _setAttr;
    public alias attrEnum = _attrEnum;

    this()
    {
        super();
    }

    public ~this()
    {
        this.free();
    }

    public ODBCReturn setAttribute(attrEnum attr, pointer_t value_ptr, SQLINTEGER string_length = 0)
    {
        return to!ODBCReturn(SetAttribute(this._handle, to!SQLINTEGER(attr),
                value_ptr, string_length));
    }

    public ODBCReturn getAttribute(attrEnum attr, pointer_t value_ptr,
            SQLINTEGER buffer_length = 0, SQLINTEGER* string_length_ptr = null)
    {
        return to!ODBCReturn(GetAttribute(this._handle, to!SQLINTEGER(attr),
                value_ptr, buffer_length, string_length_ptr));
    }
}
