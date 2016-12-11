module dodbc.environment;

import dodbc.interfaces;
import dodbc.constants;
import dodbc.utilities;

import std.conv : to;
import std.typecons : Ternary;

import etc.c.odbc.sql;

version (Windows) pragma(lib, "odbc32");

final class Environment : IEnvironment
{
    private handle_t _handle;

    public this(ODBCVersion ver = ODBCVersion.v3)
    {
        this.allocate();
        this.odbc_version = ver;
    }

    public ~this()
    {
        this.free();
    }

    //    @disable this(this);

    public @property handle_t handle()
    {
        return this._handle;
    }

    public @property void handle(handle_t input)
    {
        this._handle = input;
    }

    public ODBCReturn allocate()
    {
        handle_t temp = this.handle;
        ODBCReturn output = to!ODBCReturn(SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &temp));
        this.handle = temp;
        return output;
    }

    public ODBCReturn free()
    {
        ODBCReturn output = to!ODBCReturn(SQLFreeHandle(SQL_HANDLE_ENV, this.handle));
        this.handle = SQL_NULL_HANDLE;
        return output;
    }

    public ODBCReturn setAttribute(EnvironmentAttributes attr,
            pointer_t value_ptr, SQLINTEGER string_length = 0)
    {
        return to!ODBCReturn(SQLSetEnvAttr(this._handle, to!SQLINTEGER(attr),
                value_ptr, string_length));
    }

    public ODBCReturn getAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            SQLINTEGER buffer_length = 0, SQLINTEGER* string_length_ptr = null)
    {
        return to!ODBCReturn(SQLGetEnvAttr(this._handle, to!SQLINTEGER(attr),
                value_ptr, buffer_length, string_length_ptr));
    }

    public @property Ternary null_terminated_strings()
    {
        Ternary output;
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = SQLINTEGER.init;
            this.getAttribute(EnvironmentAttributes.NullTerminatedStrings, &value_ptr);
            output = (value_ptr == SQL_TRUE);
        }
        return output;
    }

    public @property void null_terminated_strings(U : bool)(U input)
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = input ? SQL_TRUE : SQL_FALSE;
            this.setAttribute(EnvironmentAttributes.NullTerminatedStrings, &value_ptr);
        }
    }

    public @property void null_terminated_strings(U : Ternary)(U input)
    {
        assert(input != Ternary.unknown);
        if (this.isAllocated)
        {
            this.null_terminated_strings = input ? true : false;
        }
    }

    public @property ODBCVersion odbc_version()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = SQLINTEGER.init;
            this.getAttribute(EnvironmentAttributes.ODBCVersion, &value_ptr);
            return to!ODBCVersion(value_ptr);
        }
        return ODBCVersion.Undefined;
    }

    public @property ConnectionPoolMatch connection_pool_match()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = SQLINTEGER.init;
            this.getAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
            return to!ConnectionPoolMatch(value_ptr);
        }
        return ConnectionPoolMatch.Undefined;
    }

    public @property void connection_pool_match(ConnectionPoolMatch input)
    {
        assert(input != ConnectionPoolMatch.Undefined);
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = to!SQLINTEGER(input);
            this.setAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
        }
    }

    private @property void odbc_version(ODBCVersion input)
    {
        //        assert(input != ODBCVersion.Undefined);
        SQLINTEGER value_ptr = to!SQLINTEGER(input);
        this.setAttribute(EnvironmentAttributes.ODBCVersion, cast(pointer_t) value_ptr);
    }
}

unittest
{
    Environment env = new Environment();
    assert(env.isAllocated);
}

unittest
{
    import std.stdio;

    writeln("Environment Unit Tests\n");

    Environment env = new Environment();

    assert(env.isAllocated);
    assert(env.null_terminated_strings == Ternary.yes);

    writefln("Is Allocated: %s", env.isAllocated);
    writefln("Null Terminated Strings: %s", env.null_terminated_strings);
    writefln("ODBC Version: %s", env.odbc_version);
    writefln("Connection Pool Match: %s", env.connection_pool_match);

    env.free();
    assert(!env.isAllocated);

    writefln("Is Allocated: %s", env.isAllocated);
    writefln("Null Terminated Strings: %s", env.null_terminated_strings);
    writefln("ODBC Version: %s", env.odbc_version);
    writefln("Connection Pool Match: %s", env.connection_pool_match);

    assert(env.null_terminated_strings == Ternary.unknown);
    writeln("\n\n");
}
