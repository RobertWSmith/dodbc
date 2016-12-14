module dodbc.environment;

import dodbc.root;

import std.conv : to;
import std.typecons : Ternary, Tuple;
import std.string : fromStringz;

//import etc.c.odbc.sql;
//import etc.c.odbc.sqlext;
//version (Windows) pragma(lib, "odbc32");

alias Drivers = Tuple!(string, "description", string, "attributes");
alias DataSources = Tuple!(string, "server_name", string, "description");

package final class Environment : Handle!(HandleType.Environment,
        SQLGetEnvAttr, SQLSetEnvAttr, EnvironmentAttributes)
{
    private bool _lowercase;

    package this(ODBCVersion ver = ODBCVersion.v3, bool lowercase = false)
    {
        super();
        this.allocate();
        this.odbc_version = ver;
    }

    public @property bool lowercase()
    {
        return this._lowercase;
    }

    public @property void lowercase(bool input)
    {
        this._lowercase = input;
    }

    public @property Ternary null_terminated_strings()
    {
        Ternary output = Ternary.unknown;
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = SQLINTEGER.init;
            this.getAttribute(EnvironmentAttributes.NullTerminatedStrings, &value_ptr);
            output = (value_ptr == SQL_TRUE);
        }
        return output;
    }

    private @property void null_terminated_strings(U : bool)(U input)
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = input ? SQL_TRUE : SQL_FALSE;
            this.setAttribute(EnvironmentAttributes.NullTerminatedStrings, &value_ptr);
        }
    }

    private @property void null_terminated_strings(U : Ternary)(U input)
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
        return ODBCVersion.init;
    }

    private @property void odbc_version(ODBCVersion input)
    {
        //        assert(input != ODBCVersion.Undefined);
        SQLINTEGER value_ptr = to!SQLINTEGER(input);
        this.setAttribute(EnvironmentAttributes.ODBCVersion, cast(pointer_t) value_ptr);
    }

    public @property ConnectionPoolMatch connection_pool_match()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = SQLINTEGER.init;
            this.getAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
            return to!ConnectionPoolMatch(value_ptr);
        }
        return ConnectionPoolMatch.init;
    }

    private @property void connection_pool_match(ConnectionPoolMatch input)
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = to!SQLINTEGER(input);
            this.setAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
        }
    }

    public @property Drivers[] drivers()
    {
        SQLUSMALLINT direction = SQL_FETCH_FIRST;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] description;
        SQLCHAR[2048 + 1] attributes;
        ODBCReturn ret = ODBCReturn.Success;
        Drivers[] output;

        while (true)
        {
            SQLSMALLINT buffer_length1 = description.length - 1, descr_len_ptr = 0;
            SQLSMALLINT buffer_length2 = attributes.length - 1, attr_len_ptr = 0;
            description[] = '\0';
            attributes[] = '\0';

            ret = to!ODBCReturn(SQLDrivers(this.handle, direction, description.ptr, buffer_length1,
                    &descr_len_ptr, attributes.ptr, buffer_length2, &attr_len_ptr));

            if (ret == ODBCReturn.NoData)
                break;

            direction = SQL_FETCH_NEXT;

            output ~= Drivers(to!string(fromStringz(description.ptr)),
                    to!string(fromStringz(attributes.ptr)));
        }
        return output;
    }

    public @property DataSources[] data_sources()
    {
        SQLUSMALLINT direction = SQL_FETCH_FIRST;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] server_name;
        SQLCHAR[2048 + 1] description;
        ODBCReturn ret = ODBCReturn.Success;
        DataSources[] output;

        while (true)
        {
            server_name[] = '\0';
            description[] = '\0';
            SQLSMALLINT buffer_length1 = server_name.length - 1, server_name_len_ptr = 0;
            SQLSMALLINT buffer_length2 = description.length - 1, descr_len_ptr = 0;

            ret = to!ODBCReturn(SQLDataSources(this.handle, direction, server_name.ptr, buffer_length1,
                    &server_name_len_ptr, description.ptr, buffer_length2, &descr_len_ptr));

            if (ret == ODBCReturn.NoData)
                break;

            direction = SQL_FETCH_NEXT;

            output ~= DataSources(to!string(fromStringz(server_name.ptr)),
                    to!string(fromStringz(description.ptr)));
        }
        return output;
    }
}

// Thread global
//private shared Mutex sharedEnvironmentMutex;
//private shared Environment sharedEnvironment;
//
//public @property Environment environment() @safe
//{
//    synchronized (sharedEnvironmentMutex)
//    {
//        if (sharedEnvironment is null)
//            sharedEnvironment = cast(shared Environment) new Environment(ODBCVersion.v3);
//    }
//
//    // Workaround for atomics not allowed in @safe code
//    auto trustedLoad(T)(ref shared T value) @trusted
//    {
//        return atomicLoad!(MemoryOrder.acq)(value);
//    }
//
//    auto env = trustedLoad(sharedEnvironment);
//
//    if (!env.handle is SQL_NULL_HANDLE)
//        env.allocate();
//    return env;
//}

unittest
{
    import std.stdio;

    Environment environment = new Environment();
    assert(environment.isAllocated);

    writeln("Environment Unit Tests\n");

    assert(environment.isAllocated);
    assert(environment.null_terminated_strings == Ternary.yes);

    writefln("Is Allocated: %s", environment.isAllocated);
    writefln("Null Terminated Strings: %s", environment.null_terminated_strings);
    writefln("ODBC Version: %s", environment.odbc_version);
    writefln("Connection Pool Match: %s", environment.connection_pool_match);

    writeln("\n");

    foreach (drv; environment.drivers)
        writefln("Description: %s\tAttributes: %s", drv.description, drv.attributes);

    writeln("\n");

    foreach (ds; environment.data_sources)
        writefln("Server Name: %s\tDescription: %s", ds.server_name, ds.description);

    writeln("\n");

    environment.free();
    assert(!environment.isAllocated);

    writefln("Is Allocated: %s", environment.isAllocated);
    writefln("Null Terminated Strings: %s", environment.null_terminated_strings);
    writefln("ODBC Version: %s", environment.odbc_version);
    writefln("Connection Pool Match: %s", environment.connection_pool_match);

    assert(environment.null_terminated_strings == Ternary.unknown);
    writeln("\n\n");
}
