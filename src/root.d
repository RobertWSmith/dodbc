module dodbc.root;

version (Windows) import core.sys.windows.windows;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;
import etc.c.odbc.sqlucode;

version (Windows) pragma(lib, "odbc32");

import dodbc.types;
import dodbc.constants;

static import uuid = std.uuid;

import std.conv; // : to;
import std.string; // : format, strip, fromStringz, toStringz;
import std.traits; // : isImplicitlyConvertible, hasMember;
import std.typecons; // : Ternary;

debug
{
    public import std.stdio;
    public import std.traits;

    public import std.variant;
    public import std.typecons : Tuple;
}

version (unittest)
{
    public import std.stdio;
    public import std.conv;
    public import std.string;
    public import std.traits;
}

package uuid.UUID generateUUID(string name = "")
{
    const(char[]) nm = to!(const(char[]))("dodbc." ~ name);

    return uuid.md5UUID(nm, uuid.oidNamespace);
}

package ODBCReturn ret(SQLRETURN rc)
{
    return to!ODBCReturn(rc);
}

package bool isAllocated(handle_t handle)
{
    return !(handle == SQL_NULL_HANDLE);
}

immutable(Char)[] string_map_to_string(Char)(immutable(Char)[][immutable(Char)[]] input,
        Char assign_sep = '=', Char value_sep = ';', Char open_quotechar = '{',
        Char close_quotechar = '}')
{
    // 1 = key
    // 2 = value
    // 3 = assign_sep
    // 4 = open_quotechar
    // 5 = close_quotechar
    // 6 = value_sep

    enum immutable(Char)[] _format_string = "%1$s%3$s%4$s%2$s%5$s%6$s";
    immutable(Char)[] output = "";
    foreach (key, value; input)
        output ~= format(_format_string, key, value, assign_sep,
                open_quotechar, close_quotechar, value_sep);
    return output;
}

String[String] string_to_string_map(Char, alias String = immutable(Char)[])(String input,
        Char assign_sep = '=', Char value_sep = ';', Char open_quotechar = '{',
        Char close_quotechar = '}')
{
    StringMap output;
    return output;
}

package Char[] str_conv(Char)(immutable(Char)[] input)
{
    if (input !is null)
        return to!(Char[])(toStringz(input));
    return null;
}

package immutable(Char)[] str_conv(Char)(Char* input)
{
    return to!(immutable(Char)[])(fromStringz(input));
}

struct Diagnostics
{
    ushort record;
    string state;
    int native_error;
    string message;

    this(SQLSMALLINT rec, SQLCHAR* state_ptr, SQLINTEGER native_err, SQLCHAR* msg_ptr)
    {
        this.record = to!ushort(rec);
        this.state = str_conv(state_ptr);
        this.native_error = to!int(native_err);
        this.message = str_conv(msg_ptr);
    }

    string toString()
    {
        return format("%d {%s} [%s] %s  ", this.record, this.native_error,
                this.state, this.message);
    }
}

package Diagnostics[] p_diagnose(HandleType ht, handle_t handle)
{
    Diagnostics[] output;
    if (handle.isAllocated)
    {
        string temp_output, state_str, message_str;
        SQLSMALLINT rec = 0;
        SQLCHAR[7] state;
        SQLINTEGER native_err = 0;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] message;
        SQLSMALLINT buffer_length = (message.length - 1), text_length;
        SQLRETURN ret = SQL_SUCCESS;

        while (true)
        {
            state_str = null;
            state[] = '\0';
            message_str = null;
            message[] = '\0';
            text_length = 0;
            rec++;
            ret = SQLGetDiagRec(ht, handle, rec, state.ptr, &native_err,
                    message.ptr, buffer_length, &text_length);

            if (ret == SQL_NO_DATA)
                break;

            output ~= Diagnostics(rec, state.ptr, native_err, message.ptr);
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

abstract class Identified
{
    static import uuid = std.uuid;

    enum uuid.UUID default_uuid = uuid.UUID("00000000-0000-0000-0000-000000000001");

    public static uuid.UUID id;

    package this(uuid.UUID id = generateUUID("Identified"))
    {
        this.id = id;
    }

    public override bool opEquals(Object other)
    {
        static if (hasMember!(Object, "id"))
            return (this.id == other.id);
        return (this == other);
    }

    public override int opCmp(Object other)
    {
        static if (hasMember!(Object, "id"))
            return (this.id.opCmp(other.id));
        return (this == other);
    }

}

unittest
{
    assert(isAbstractClass!Identified);
}

abstract class Root(HandleType _ht) : Identified
{
    debug alias kwarg_tuple = Tuple!(string, "key", Variant, "value");
    debug private string _sql_function;
    debug private kwarg_tuple[] _sql_kwargs;

    package handle_t _handle;
    public enum HandleType handle_enum = _ht;
    public enum SQLSMALLINT handle_type = to!SQLSMALLINT(_ht);
    private ODBCReturn _return_code;

    this(uuid.UUID id = generateUUID(format("Root.%s", this.handle_enum)))
    {
        super(id);

        this.nullify();
        this._return_code = ODBCReturn.Success;

        debug
        {
            this._sql_function = "ClassInitialization";
            this._sql_kwargs = kwarg_tuple[].init;
            this.debugger();
        }
    }

    ~this()
    {
        this.free();
    }

    public final @property void return_code(ODBCReturn input)
    {
        this._return_code = ret(input);
    }

    public final @property ODBCReturn return_code()
    {
        return this._return_code;
    }

    public final @property void sqlreturn(SQLRETURN input)
    {
        this.return_code = to!ODBCReturn(input);
    }

    public final @property SQLRETURN sqlreturn()
    {
        return to!SQLRETURN(this._return_code);
    }

    public final @property immutable(bool) isAllocated()
    {
        return ((this.handle).isAllocated);
    }

    public final @property handle_t handle()
    {
        return this._handle;
    }

    private final @property void handle(handle_t input)
    {
        this._handle = input;
    }

    //    alias sql_func = SQLDescribeCol;
    //    debug
    //    {
    //        this.sql_function = fullyQualifiedName!sql_func;
    //        this.insert_kwarg("columnNbr", columnNbr);
    //    }
    //
    //    this.sqlreturn = SQLDescribeCol(this.handle, columnNbr, columnNamePtr, bufferLength,
    //            nameLengthPtr, dataTypePtr, columnSizePtr, decimalDigitsPtr, nullablePtr);
    //
    //    debug this.debugger();

    public void allocate(handle_t prior = SQL_NULL_HANDLE)
    {
        alias sql_func = SQLAllocHandle;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("handle_type", this.handle_enum);
        }

        this.free();
        this.sqlreturn = sql_func(this.handle_type, prior, &(this._handle));

        debug this.debugger();
    }

    public void free()
    {
        alias sql_func = SQLFreeHandle;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
        }

        if (this.isAllocated)
        {
            this.sqlreturn = sql_func(handle_type, (this._handle));
            debug this.debugger();
        }

        this.nullify();
    }

    private void nullify()
    {
        this.handle = SQL_NULL_HANDLE;
        this._return_code = ODBCReturn.Success;
    }

    debug public @property string sql_function()
    {
        return this._sql_function;
    }

    debug public @property void sql_function(string input)
    {
        this.clear_debug_values();
        this._sql_function = input;
    }

    debug private void clear_debug_values()
    {
        this._sql_function = "";
        this._sql_kwargs.length = 0;
    }

    debug public void insert_kwarg(T)(string key, T value)
    {
        Variant v = value;
        kwarg_tuple kw = kwarg_tuple(key, v);
        this._sql_kwargs ~= kw;
    }

    debug public @property string sql_function_diagnostic_call()
    {
        string output = sql_call_to_string(this._sql_function, this._sql_kwargs);
        return output;
    }

    debug private immutable(Char)[] sql_call_to_string(Char)(string func, kwarg_tuple[] tpl,
            immutable(Char)[] open_quotechar = "(", immutable(Char)[] close_quotechar = ")")
    {
        return format("%1$s%3$s%2$s%4$s", func,
                kwarg_tuple_to_string!(Char)(tpl), open_quotechar, close_quotechar);
    }

    debug private immutable(Char)[] kwarg_tuple_to_string(Char)(kwarg_tuple[] input,
            immutable(Char)[] assign_sep = " = ", immutable(Char)[] value_sep = ", ",
            immutable(Char)[] open_quotechar = "[", immutable(Char)[] close_quotechar = "]")
    {
        if (input.length > 0)
        {
            alias String = immutable(Char)[];

            // 1 = key
            // 2 = value
            // 3 = assign_sep
            // 4 = open_quotechar
            // 5 = close_quotechar
            // example output:
            //    x = [y]
            String[] elem_list;
            foreach (v; input)
                elem_list ~= format("%1$s%3$s%4$s%2$s%5$s", v[0], v[1],
                        assign_sep, open_quotechar, close_quotechar);

            // 1 = prior
            // 2 = additional
            // 3 = value_sep
            // example output
            //    x1 = [y1], x2 = [y2]            
            String output = elem_list[0];
            foreach (e; elem_list[1 .. $])
                output = format("%1$s%3$s%2$s", output, e, value_sep);

            return output;
        }
        else
        {
            return "";
        }
    }

    debug package final void debugger()
    {
        writefln("UUID: %s\tHandle Type: %s\n\tFunction: %s\n\tArguments: %s\n\tReturn: %s", this.id, this.handle_enum,
                this.sql_function, this.kwarg_tuple_to_string(this._sql_kwargs), this.return_code);
        if (!SQL_SUCCEEDED(this.sqlreturn) || this.return_code == ODBCReturn.SuccessWithInfo)
            foreach (d; this.diagnose())
                writeln(d);
    }

    debug package final string[] diagnostics()
    {
        string[] output;
        output = [this.sql_function_diagnostic_call,];
        foreach (d; this.diagnose())
            output ~= d.toString();
        return output;
    }

    debug package final Diagnostics[] diagnose()
    {
        return p_diagnose(this.handle_enum, (this.handle));
    }
}

alias RootEnvironment = Root!(HandleType.Environment);
alias RootConnection = Root!(HandleType.Connection);
alias RootStatement = Root!(HandleType.Statement);
alias RootDescription = Root!(HandleType.Description);

unittest
{
    assert(isAbstractClass!(Root!(HandleType.Environment)));
    assert(isAbstractClass!(Root!(HandleType.Connection)));
    assert(isAbstractClass!(Root!(HandleType.Statement)));
    assert(isAbstractClass!(Root!(HandleType.Description)));

    assert(isAbstractClass!RootEnvironment);
    assert(isAbstractClass!RootConnection);
    assert(isAbstractClass!RootStatement);
    assert(isAbstractClass!RootDescription);

    assert(hasMember!(RootEnvironment, "id"));
    assert(hasMember!(RootConnection, "id"));
    assert(hasMember!(RootStatement, "id"));
    assert(hasMember!(RootDescription, "id"));
}

abstract class Handle(HandleType _ht, alias _getAttr, alias _setAttr, alias _attrEnum) : Root!(_ht)
{
    public alias GetAttribute = _getAttr;
    public alias SetAttribute = _setAttr;
    public alias attrEnum = _attrEnum;

    this(uuid.UUID id = generateUUID(format("handle.%s", this.handle_enum)))
    {
        super(id);
    }

    public void setAttribute(attrEnum attr, pointer_t value_ptr, SQLINTEGER string_length = 0)
    {
        alias sql_func = SetAttribute;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("attr", attr);
        }

        this.sqlreturn = sql_func(this._handle, to!SQLINTEGER(attr), value_ptr, string_length);

        debug this.debugger();
    }

    public void getAttribute(attrEnum attr, pointer_t value_ptr,
            SQLINTEGER buffer_length = 0, SQLINTEGER* string_length_ptr = null)
    {
        alias sql_func = GetAttribute;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("attr", attr);
        }

        this.sqlreturn = sql_func(this._handle, to!SQLINTEGER(attr), value_ptr,
                buffer_length, string_length_ptr);
        debug this.debugger();
    }
}

alias EnvironmentHandle = Handle!(HandleType.Environment, SQLGetEnvAttr,
        SQLSetEnvAttr, EnvironmentAttributes);
alias ConnectionHandle = Handle!(HandleType.Connection, SQLGetConnectAttr,
        SQLSetConnectAttr, ConnectionAttributes);
alias StatementHandle = Handle!(HandleType.Statement, SQLGetStmtAttr,
        SQLSetStmtAttr, StatementAttributes);

//unittest
//{
//    assert(isAbstractClass!(Handle!(HandleType.Environment, SQLGetEnvAttr,
//            SQLSetEnvAttr, EnvironmentAttributes)));
//    assert(isAbstractClass!(Handle!(HandleType.Connection, SQLGetStmtAttr,
//            SQLSetStmtAttr, StatementAttributes)));
//    assert(isAbstractClass!(Handle!(HandleType.Statement, SQLGetConnectAttr,
//            SQLSetConnectAttr, ConnectionAttributes)));
//}
