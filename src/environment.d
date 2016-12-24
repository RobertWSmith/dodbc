module dodbc.environment;

import dodbc.types;
import dodbc.constants;
import dodbc.root;

version (Windows) import core.sys.windows.windows;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;
import etc.c.odbc.sqlucode;

version (Windows) pragma(lib, "odbc32");

static import uuid = std.uuid;
import std.conv : to;
import std.string : fromStringz;

// shared Environment variable
import std.concurrency;
import core.atomic;
import core.sync.mutex : Mutex;

shared static this()
{
    sharedEnvironmentMutex = new Mutex;
}

private __gshared Mutex sharedEnvironmentMutex;
private shared Environment sharedEnvironmentObject;

// returns the default global environment
private @property Environment defaultSharedEnvironmentImpl() @trusted
{
    synchronized (sharedEnvironmentMutex)
    {
        if (sharedEnvironmentObject is null)
            sharedEnvironmentObject = cast(shared) environment_factory();
    }
    return cast(Environment) sharedEnvironmentObject;
}

public @property Environment sharedEnvironment()
{
    static auto trustedLoad(ref shared Environment env) @trusted
    {
        return atomicLoad!(MemoryOrder.acq)(env);
    }

    // if we have set up our own environment use that
    if (auto env = trustedLoad(sharedEnvironmentObject))
    {
        return env;
    }
    else
    {
        return defaultSharedEnvironmentImpl;
    }
}

public @property void sharedEnvironment(Environment input) @trusted
{
    atomicStore!(MemoryOrder.rel)(sharedEnvironmentObject, cast(shared) input);
}

unittest
{
    import std.compiler;

    writefln("Compiler Name:           %s", name);
    writefln("Compiler Vendor:         %s", vendor);
    writefln("D Major Version:         %s", D_major);
    writefln("Version:                 %s.%s", version_major, version_minor);
    writeln();
}

unittest
{
    import std.system;

    writefln("Operating System:        %s", os);
    writefln("Endian:                  %s", endian);
    writeln();
}

unittest
{
    import core.cpuid;

    CacheInfo ci;

    writefln("Cache Size (kb):         %s", ci.size);
    writefln("Cache Miss Line Size:    %s", ci.lineSize);

    writefln("Processor Vendor:        %s", vendor);
    writefln("Processor:               %s", processor);
    writefln("64-bit?:                 %s", isX86_64);
    writefln("Hyper Threading?:        %s", hyperThreading);
    writefln("Threads per CPU:         %s", threadsPerCPU);
    writefln("Cores per CPU:           %s", coresPerCPU);
    writefln("Cache Levels:            %s", cacheLevels);

    foreach (size_t ix, CacheInfo cache; dataCaches())
        if (ix < cacheLevels)
            writefln("Cache %s:                 %s", ix, cache);

    writeln();
}

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

// manages ODBC environments, accessed via `environment_factory` function 
final class Environment : EnvironmentHandle
{
    public static ODBCVersion odbc_version;
    private bool _lowercase;
    private bool _null_terminated_strings;
    private ConnectionPoolMatch _connection_pool_match;
    private ConnectionPooling _connection_pooling;

    package this(ODBCVersion odbc_version, bool _lowercase, bool _null_terminated_strings,
            ConnectionPoolMatch _connection_pool_match, ConnectionPooling _connection_pooling)
    {
        super(generateUUID("Environment"));
        this.odbc_version = odbc_version;
        this.lowercase = _lowercase;
        // this.null_terminated_strings = _null_terminated_strings;
        // this.connection_pool_match = _connection_pool_match;
        // this.connection_pooling = _connection_pooling;
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

    public void allocate()
    {
        this.free();
        super.allocate(SQL_NULL_HANDLE);

        this.apply_odbc_version();
        // this.apply_null_terminated_strings();
        // this.apply_connection_pool_match();
        // this.apply_connection_pooling();
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

    // private @property void null_terminated_strings(bool input)
    // {
    // this._null_terminated_strings = input;
    // this.apply_null_terminated_strings();
    // }

    // private ODBCReturn apply_null_terminated_strings()
    // {
    // if (this.isAllocated)
    // {
    // SQLINTEGER value_ptr = to!SQLINTEGER(this.null_terminated_strings ? SQL_TRUE : SQL_FALSE);
    // return this.setAttribute(EnvironmentAttributes.NullTerminatedStrings,
    // cast(pointer_t) value_ptr);
    // }
    // return ODBCReturn.Error;
    // }

    private void apply_odbc_version()
    {
        SQLINTEGER value_ptr = to!SQLINTEGER(this.odbc_version);
        this.setAttribute(EnvironmentAttributes.ODBCVersion, cast(pointer_t) value_ptr);
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

    // private @property void connection_pool_match(ConnectionPoolMatch input)
    // {
    // this._connection_pool_match = input;
    // this.apply_connection_pool_match();
    // }

    // private ODBCReturn apply_connection_pool_match()
    // {
    // if (this.isAllocated)
    // {
    // SQLINTEGER value_ptr = to!SQLINTEGER(this.connection_pool_match);
    // return this.setAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value_ptr);
    // }
    // return ODBCReturn.Error;
    // }

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

    // private @property void connection_pooling(ConnectionPooling input)
    // {
    // this._connection_pooling = input;
    // this.apply_connection_pooling();
    // }

    // private ODBCReturn apply_connection_pooling()
    // {
    // if (this.isAllocated)
    // {
    // SQLUINTEGER value_ptr = to!SQLUINTEGER(this.connection_pooling);
    // return this.setAttribute(EnvironmentAttributes.ConnectionPooling, &value_ptr);
    // }
    // return ODBCReturn.Error;
    // }

    public @property Drivers[] drivers()
    {
        alias sql_func = SQLDrivers;
        SQLUSMALLINT direction = SQL_FETCH_FIRST;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] description;
        SQLCHAR[2048 + 1] attributes;
        this.sqlreturn = ODBCReturn.Success;
        Drivers[] output;

        while (true)
        {
            SQLSMALLINT buffer_length1 = description.length - 1, descr_len_ptr = 0;
            SQLSMALLINT buffer_length2 = attributes.length - 1, attr_len_ptr = 0;
            description[] = '\0';
            attributes[] = '\0';

            this.sqlreturn = sql_func(this.handle, direction, description.ptr, buffer_length1,
                    &descr_len_ptr, attributes.ptr, buffer_length2, &attr_len_ptr);

            if (this.sqlreturn == ODBCReturn.NoData)
                break;

            direction = SQL_FETCH_NEXT;

            output ~= Drivers(to!string(fromStringz(description.ptr)),
                    to!string(fromStringz(attributes.ptr)));
        }
        return output;
    }

    public @property DataSources[] data_sources()
    {
        alias sql_func = SQLDataSources;
        SQLUSMALLINT direction = SQL_FETCH_FIRST;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] server_name;
        SQLCHAR[2048 + 1] description;
        this.sqlreturn = ODBCReturn.Success;
        DataSources[] output;

        while (true)
        {
            server_name[] = '\0';
            description[] = '\0';
            SQLSMALLINT buffer_length1 = server_name.length - 1, server_name_len_ptr = 0;
            SQLSMALLINT buffer_length2 = description.length - 1, descr_len_ptr = 0;

            this.sqlreturn = sql_func(this.handle, direction, server_name.ptr, buffer_length1,
                    &server_name_len_ptr, description.ptr, buffer_length2, &descr_len_ptr);

            if (this.return_code == ODBCReturn.NoData)
                break;

            direction = SQL_FETCH_NEXT;

            output ~= DataSources(to!string(fromStringz(server_name.ptr)),
                    to!string(fromStringz(description.ptr)));
        }
        return output;
    }
}

package Environment environment_factory(ODBCVersion odbc_version = ODBCVersion.v3,
        bool lowercase = false, bool null_terminated_strings = true,
        ConnectionPoolMatch connection_pool_match = ConnectionPoolMatch.Default,
        ConnectionPooling connection_pooling = ConnectionPooling.Default)
{
    Environment env = new Environment(odbc_version, lowercase,
            null_terminated_strings, connection_pool_match, connection_pooling);
    return env;
}

// Thread global
// private shared Mutex sharedEnvironmentMutex;
// private shared Environment sharedEnvironment;
// 
// public @property Environment environment() @safe
// {
// synchronized (sharedEnvironmentMutex)
// {
// if (sharedEnvironment is null)
// sharedEnvironment = cast(shared Environment) new Environment(ODBCVersion.v3);
// }
// 
// // Workaround for atomics not allowed in @safe code
// auto trustedLoad(T)(ref shared T value) @trusted
// {
// return atomicLoad!(MemoryOrder.acq)(value);
// }
// 
// auto env = trustedLoad(sharedEnvironment);
// 
// if (!env.handle is SQL_NULL_HANDLE)
// env.allocate();
// return env;
// }

unittest
{
    writeln("\n\nBegin Environment Unit Tests\n");
    assert(sharedEnvironment.isAllocated);
    assert(sharedEnvironment.null_terminated_strings);

    writefln("Is Allocated: %s", sharedEnvironment.isAllocated);
    writefln("Null Terminated Strings: %s", sharedEnvironment.null_terminated_strings);
    writefln("ODBC Version: %s", sharedEnvironment.odbc_version);
    writefln("Connection Pool Match: %s", sharedEnvironment.connection_pool_match);

    writeln("\n");

    foreach (drv; sharedEnvironment.drivers)
        writefln("Description: %s\tAttributes: %s", drv.description, drv.attributes);

    writeln("\n");

    foreach (ds; sharedEnvironment.data_sources)
        writefln("Server Name: %s\tDescription: %s", ds.server_name, ds.description);

    writeln("\n");

    sharedEnvironment.free();
    assert(!sharedEnvironment.isAllocated);

    writefln("Is Allocated: %s", sharedEnvironment.isAllocated);
    writefln("Null Terminated Strings: %s", sharedEnvironment.null_terminated_strings);
    writefln("ODBC Version: %s", sharedEnvironment.odbc_version);
    writefln("Connection Pool Match: %s", sharedEnvironment.connection_pool_match);

    writeln("\nEnd Environment Unit Tests\n\n");
}
