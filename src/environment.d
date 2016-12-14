module dodbc.environment;

import dodbc.root;

import std.conv : to;
import std.string : fromStringz;

struct Drivers
{
    string description;
    string attributes;
}

struct DataSources
{
    string server_name;
    string description;
}

package final class Environment : Handle!(HandleType.Environment,
        SQLGetEnvAttr, SQLSetEnvAttr, EnvironmentAttributes)
{
    public enum ODBCVersion odbc_version = ODBCVersion.v3_80;
    private bool _lowercase;
    private bool _null_terminated_strings;
    private ConnectionPoolMatch _connection_pool_match;
    private ConnectionPooling _connection_pooling;

    package this(bool _lowercase, bool _null_terminated_strings,
            ConnectionPoolMatch _connection_pool_match, ConnectionPooling _connection_pooling)
    {
        super();
        this.lowercase = _lowercase;
        this.null_terminated_strings = _null_terminated_strings;
        this.connection_pool_match = _connection_pool_match;
        this.connection_pooling = _connection_pooling;

        this.allocate();
    }

    public @property bool lowercase()
    {
        return this._lowercase;
    }

    public @property void lowercase(bool input)
    {
        this._lowercase = input;
    }

    public override ODBCReturn allocate(handle_t input = SQL_NULL_HANDLE)
    {
        ODBCReturn output = super.allocate(input);
        this.apply_odbc_version();
        this.apply_null_terminated_strings();
        this.apply_connection_pool_match();
        this.apply_connection_pooling();
        return output;
    }

    public @property bool null_terminated_strings()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = SQLINTEGER.init;
            this.getAttribute(EnvironmentAttributes.NullTerminatedStrings, &value_ptr);
            this._null_terminated_strings = (value_ptr == SQL_TRUE);
        }
        return this._null_terminated_strings;
    }

    private @property void null_terminated_strings(bool input)
    {
        this._null_terminated_strings = input;
        this.apply_null_terminated_strings();
    }

    private ODBCReturn apply_null_terminated_strings()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = to!SQLINTEGER(this.null_terminated_strings ? SQL_TRUE : SQL_FALSE);
            return this.setAttribute(EnvironmentAttributes.NullTerminatedStrings,
                    cast(pointer_t) value_ptr);
        }
        return ODBCReturn.Error;
    }

    private ODBCReturn apply_odbc_version()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = to!SQLINTEGER(this.odbc_version);
            return this.setAttribute(EnvironmentAttributes.ODBCVersion, cast(pointer_t) value_ptr);
        }
        return ODBCReturn.Error;
    }

    public @property ConnectionPoolMatch connection_pool_match()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = 0;
            this.getAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
            this._connection_pool_match = to!ConnectionPoolMatch(value_ptr);
        }
        return this._connection_pool_match;
    }

    private @property void connection_pool_match(ConnectionPoolMatch input)
    {
        this._connection_pool_match = input;
        this.apply_connection_pool_match();
    }

    private ODBCReturn apply_connection_pool_match()
    {
        if (this.isAllocated)
        {
            SQLINTEGER value_ptr = to!SQLINTEGER(this.connection_pool_match);
            return this.setAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
        }
        return ODBCReturn.Error;
    }

    public @property ConnectionPooling connection_pooling()
    {
        if (this.isAllocated)
        {
            SQLUINTEGER value_ptr = 0;
            this.getAttribute(EnvironmentAttributes.ConnectionPooling, &value_ptr);
            this._connection_pooling = to!ConnectionPooling(value_ptr);
        }
        return this._connection_pooling;
    }

    private @property void connection_pooling(ConnectionPooling input)
    {
        this._connection_pooling = input;
        this.apply_connection_pooling();
    }

    private ODBCReturn apply_connection_pooling()
    {
        if (this.isAllocated)
        {
            SQLUINTEGER value_ptr = to!SQLUINTEGER(this.connection_pooling);
            return this.setAttribute(EnvironmentAttributes.ConnectionPooling, &value_ptr);
        }
        return ODBCReturn.Error;
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

package Environment environment_factory(bool lowercase = false, bool null_terminated_strings = true,
        ConnectionPoolMatch connection_pool_match = ConnectionPoolMatch.Default,
        ConnectionPooling connection_pooling = ConnectionPooling.Default)
{
    return new Environment(lowercase, null_terminated_strings,
            connection_pool_match, connection_pooling);
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

    Environment environment = environment_factory();
    assert(environment.isAllocated);

    writeln("Environment Unit Tests\n");

    assert(environment.isAllocated);
    assert(environment.null_terminated_strings);

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

    writeln("\n\n");
}
