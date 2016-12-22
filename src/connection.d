module dodbc.connection;

import std.algorithm : find, merge;
import std.container.array : Array;
import std.container.util : make;
import std.conv : to;
import std.functional : partial;
import std.typecons : Ternary, Tuple;
import std.traits : EnumMembers;
import std.string : toStringz, fromStringz;

static import uuid = std.uuid;

import dodbc.types;
import dodbc.constants;
import dodbc.root;
import dodbc.environment;
import dodbc.statement;

// shared Environment variable
import std.concurrency;
import core.atomic;
import core.sync.mutex : Mutex;

shared static this()
{
    sharedConnectionMutex = new Mutex;
}

// this mutex protects `sharedConnectionMutexArray`
private __gshared Mutex sharedConnectionMutex;
// this mutex array protects `sharedConnectionObjectArray`
private __gshared Mutex[uuid.UUID] sharedConnectionMutexArray;
private shared Connection[uuid.UUID] sharedConnectionObjectArray;

// returns the default global environment
private Connection defaultSharedConnectionImpl(
        uuid.UUID id = uuid.UUID("00000000-0000-0000-0000-000000000001")) @trusted
{
    synchronized (sharedConnectionMutex)
    {
        Mutex* m = (id in sharedConnectionMutexArray);
        if (m is null)
        {
            *m = new Mutex;
            synchronized (*m)
            {
                Connection conn = connect();
                sharedConnectionObjectArray[id] = cast(shared) conn;
            }
        }
    }
    return cast(Connection) atomicLoad!(MemoryOrder.acq)(sharedConnectionObjectArray[id]);
}

public Connection sharedConnection(uuid.UUID id)
{
    static auto trustedLoad(ref shared Connection env) @trusted
    {
        return atomicLoad!(MemoryOrder.acq)(env);
    }

    // if we have set up our own environment use that
    if (auto env = trustedLoad(sharedConnectionObjectArray[id]))
    {
        return env;
    }
    else
    {
        return defaultSharedConnectionImpl;
    }
}

public void sharedConnection(Connection input) @trusted
{
    uuid.UUID id = input.id;
    atomicStore!(MemoryOrder.rel)(sharedConnectionObjectArray[id], cast(shared) input);
}

class Connection : ConnectionHandle
{
    private string _connection_string;
    private Statement[] _statements;

    package this(size_t login_timeout, uuid.UUID id = generateUUID("Connection"))
    {
        super(id);
        this.allocate();
        this.login_timeout = login_timeout;
    }

    public ~this()
    {
        this._connection_string = null;
        this.free();
    }

    public override void allocate(handle_t input = (sharedEnvironment.handle))
    {
        this.free();
        if (!sharedEnvironment.isAllocated)
            sharedEnvironment.allocate();
        super.allocate(input);
    }

    public override void free()
    {

        foreach (stmt; this._statements)
            stmt.free();
        this._statements.length = 0;

        this.disconnect();
        super.free();
    }

    public Statement start()
    {
        Statement crsr = new Statement(this);
        this._statements ~= crsr;
        return crsr;
    }

    public bool end(Statement input)
    {
        return true;
    }

    public void getInfo(InfoType info_type, pointer_t value_ptr,
            SQLSMALLINT buffer_length = 0, SQLSMALLINT* string_length_ptr = null)
    {
        alias sql_func = SQLGetInfo;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("info_type", info_type);
            this.insert_kwarg("buffer_length", buffer_length);
            this.insert_kwarg("string_length_ptr", string_length_ptr);
        }

        this.sqlreturn = sql_func((this.handle), to!SQLSMALLINT(info_type),
                value_ptr, buffer_length, string_length_ptr);
        debug this.debugger();
    }

    public void connect(string dsn, string uid, string pwd, handle_t event_handle = null)
    {
        string[string] kwargs;
        kwargs["DSN"] = dsn;
        if (uid !is null)
            kwargs["UID"] = uid;
        if (pwd !is null)
            kwargs["PWD"] = pwd;

        this.connect(kwargs, event_handle);
    }

    public void connect(string[string] kwargs, handle_t event_handle = null)
    {
        this.connect(string_map_to_string(kwargs), event_handle);
    }

    public void connect(string connection_string_ = null, handle_t event_handle = null)
    {
        alias sql_func = SQLDriverConnect;
        this.disconnect();
        if (connection_string_ !is null)
            this.connection_string = connection_string_;

        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("connection_string", this.connection_string);
        }

        SQLCHAR[] conn_str = to!(SQLCHAR[])(toStringz(this.connection_string));
        SQLSMALLINT conn_str_len = to!SQLSMALLINT(conn_str.length);
        this.sqlreturn = sql_func(this.handle, cast(SQLHWND) null, conn_str.ptr,
                SQL_NTS, null, 0, null, SQL_DRIVER_NOPROMPT);

        debug this.debugger();
    }

    public void disconnect()
    {
        alias sql_func = SQLDisconnect;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
        }

        if (this.isAllocated)
        {
            this.sqlreturn = sql_func((this.handle));
            debug this.debugger();
        }
    }

    // public void enable_async(handle_t event_handle)
    // {
    // }

    // public void async_complete()
    // {
    // }

    public @property Environment environment()
    {
        return sharedEnvironment;
    }

    public Statement statement()
    {
        Statement stmt = new Statement(this);
        this._statements ~= stmt;
        // this._Statement = this._Statement.merge(Array!Statement(crsr));
        return stmt;
    }

    /// SQLTables
    public Prepared tables(string catalog = null, string schema = null,
            string table_name = null, string type = null)
    {
        Statement stmt = this.statement();
        //        return stmt.tables(catalog, schema, table_name, type);
        Prepared prep = stmt.tables(catalog, schema, table_name, type);
        return prep;
        //        return (this.statement()).tables(catalog, schema, table_name, type);
    }

    /// SQLColumns
    public Prepared columns(string catalog = null, string schema = null,
            string table_name = null, string column_name = null)
    {
        //    Statement stmt = this.statement();
        //		  Prepared prep = stmt.columns(catalog, schema, table_name, column_name);
        //    return prep;
        return (this.statement()).columns(catalog, schema, table_name, column_name);
    }

    /// SQLStatistics
    public Prepared statistics(string catalog = null, string schema = null,
            string table_name = null, StatisticsIndexType unique = StatisticsIndexType.All,
            StatisticsCardinalityPages cardinality_pages = StatisticsCardinalityPages.Quick)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.statistics(catalog, schema, table_name, unique, reserved);
        // return prep;
        return (this.statement()).statistics(catalog, schema, table_name,
                unique, cardinality_pages);
    }

    /// SQLSpecialColumns
    public Prepared special_columns(short identifier_type = SQL_ROWVER, string catalog = null, string schema = null,
            string table_name = null, short row_scope = SQL_SCOPE_CURROW,
            short nullable = SQL_NULLABLE)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.special_columns(identifier_type, catalog, schema, table_name, row_scope, nullable);
        // return prep;
        return (this.statement()).special_columns(identifier_type, catalog,
                schema, table_name, row_scope, nullable);
    }

    /// SQLPrimaryKeys
    public Prepared primary_keys(string catalog = null, string schema = null,
            string table_name = null)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.primary_keys(catalog, schema, table_name);
        // return prep;
        return (this.statement()).primary_keys(catalog, schema, table_name);
    }

    /// SQLForeignKeys
    public Prepared foreign_keys(string pk_catalog = null, string pk_schema = null, string pk_table_name = null,
            string fk_catalog = null, string fk_schema = null, string fk_table_name = null)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.foreign_keys(pk_catalog, pk_schema, pk_table_name, fk_catalog, fk_schema, fk_table_name);
        // return prep;
        return (this.statement()).foreign_keys(pk_catalog, pk_schema,
                pk_table_name, fk_catalog, fk_schema, fk_table_name);
    }

    /// SQLTablePrivileges
    public Prepared table_privileges(string catalog = null, string schema = null,
            string table_name = null)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.table_privileges(catalog, schema, table_name);
        // return prep;
        return (this.statement()).table_privileges(catalog, schema, table_name);
    }

    /// SQLColumnPrivileges
    public Prepared column_privileges(string catalog = null, string schema = null,
            string table_name = null, string column_name = null)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.column_privileges(catalog, schema, table_name, column_name);
        // return prep;
        return (this.statement()).column_privileges(catalog, schema, table_name, column_name);
    }

    /// SQLProcedures
    public Prepared procedures(string catalog = null, string schema = null,
            string procedure_name = null)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.procedures(catalog, schema, procedure_name);
        // return prep;
        return (this.statement()).procedures(catalog, schema, procedure_name);
    }

    /// SQLProcedureColumns
    public Prepared procedure_columns(string catalog = null, string schema = null,
            string procedure_name = null, string column_name = null)
    {
        // Statement stmt = this.statement();
        // Prepared prep = stmt.procedure_columns(catalog, schema, procedure_name, column_name);
        // return prep;
        return (this.statement()).procedure_columns(catalog, schema, procedure_name, column_name);
    }

    private @property void connection_string(string input)
    {
        this._connection_string = input.dup;
    }

    public @property string connection_string()
    {
        return this._connection_string;
    }

    public @property void access_mode(AccessMode input)
    {
        SQLINTEGER value_ptr = to!SQLINTEGER(input);
        this.setAttribute(ConnectionAttributes.AccessMode, cast(pointer_t)&value_ptr);
    }

    public @property AccessMode access_mode()
    {
        SQLINTEGER value_ptr;
        this.getAttribute(ConnectionAttributes.AccessMode, cast(pointer_t)&value_ptr);
        return to!AccessMode(value_ptr);
    }

    public @property AsyncEnable async_enable()
    {
        SQLULEN value_ptr;
        this.getAttribute(ConnectionAttributes.AsyncEnable, &value_ptr);
        return to!AsyncEnable(value_ptr);
    }

    public @property void async_enable(AsyncEnable input)
    {
        SQLULEN value_ptr = to!SQLULEN(input);
        this.setAttribute(ConnectionAttributes.AsyncEnable, cast(pointer_t) value_ptr);
    }

    public @property Ternary auto_ipd()
    {
        Ternary output;
        if (this.isAllocated)
        {
            SQLULEN value_ptr;
            this.getAttribute(ConnectionAttributes.AutoIPD, &value_ptr);
            output = (value_ptr == SQL_TRUE);
        }
        return output;
    }

    public @property void autocommit(bool input)
    {
        SQLINTEGER value_ptr = input ? SQL_AUTOCOMMIT_ON : SQL_AUTOCOMMIT_OFF;
        this.setAttribute(ConnectionAttributes.Autocommit, cast(pointer_t) value_ptr);
    }

    public @property bool autocommit()
    {
        SQLINTEGER value_ptr;
        this.getAttribute(ConnectionAttributes.Autocommit, &value_ptr);
        return (value_ptr == SQL_AUTOCOMMIT_ON);
    }

    //public @property bool connection_dead()
    //{
    //
    //this.getAttribute(ConnectionAttributes.ConnectionDead, 
    //return true;
    //}

    public @property size_t connection_timeout()
    {
        SQLINTEGER value_ptr;
        this.getAttribute(ConnectionAttributes.ConnectionTimeout, &value_ptr);
        return to!size_t(value_ptr);
    }

    public @property void connection_timeout(size_t input)
    {
        SQLINTEGER value_ptr = to!SQLINTEGER(input);
        this.setAttribute(ConnectionAttributes.ConnectionTimeout, &value_ptr);
    }

    public @property string current_catalog()
    {
        char[(2048 + 1)] value;
        value[] = '\0';

        SQLINTEGER value_len = value.length - 1, str_len_ptr;

        this.getAttribute(ConnectionAttributes.CurrentCatalog,
                cast(pointer_t) value.ptr, value_len, &str_len_ptr);
        return to!string(value[0 .. str_len_ptr]);
    }

    public @property void current_catalog(string input)
    {
        char[] value = to!(char[])(toStringz(input));
        //value ~= '\0';
        SQLINTEGER len = value.length;
        this.setAttribute(ConnectionAttributes.CurrentCatalog, cast(pointer_t) value.ptr, len);
    }

    public @property size_t login_timeout()
    {
        SQLINTEGER value;
        this.getAttribute(ConnectionAttributes.LoginTimeout, &value);
        return to!size_t(value);
    }

    ///before connect only
    private @property void login_timeout(size_t input)
    {
        SQLINTEGER value = to!SQLINTEGER(input);
        this.setAttribute(ConnectionAttributes.LoginTimeout, cast(pointer_t) value);
    }

    public @property bool metadata_id()
    {
        SQLINTEGER value;
        this.getAttribute(ConnectionAttributes.MetadataID, &value);
        return (value == SQL_TRUE);
    }

    public @property void metadata_id(bool input)
    {
        SQLINTEGER value = input ? SQL_TRUE : SQL_FALSE;
        this.setAttribute(ConnectionAttributes.MetadataID, cast(pointer_t) value);
    }

    public @property ODBCCursors odbc_cursors()
    {
        SQLULEN value;
        this.getAttribute(ConnectionAttributes.ODBCCursors, &value);
        return to!ODBCCursors(value);
    }

    public @property size_t packet_size()
    {
        SQLINTEGER value;
        this.getAttribute(ConnectionAttributes.PacketSize, cast(pointer_t) value);
        return to!size_t(value);
    }

    ///set before connection only
    private @property void packet_size(size_t input)
    {
        SQLINTEGER value = to!SQLINTEGER(input);
        this.setAttribute(ConnectionAttributes.PacketSize, &value);
    }

    public @property bool trace()
    {
        SQLINTEGER value;
        this.getAttribute(ConnectionAttributes.Trace, &value);
        return (value == SQL_OPT_TRACE_ON);
    }

    public @property void trace(bool input)
    {
        SQLINTEGER value = input ? SQL_OPT_TRACE_ON : SQL_OPT_TRACE_OFF;
        this.setAttribute(ConnectionAttributes.Trace, cast(pointer_t) value);
    }

    public @property string tracefile()
    {
        SQLCHAR[(2048 + 1)] value;
        SQLINTEGER value_len = value.length, str_len_ptr = 0;
        this.getAttribute(ConnectionAttributes.Tracefile,
                cast(pointer_t) value.ptr, value_len, &str_len_ptr);
        string output = to!string(value[0 .. str_len_ptr]);
        return output;
    }

    public @property void tracefile(string input)
    {
        char[] value = to!(char[])(input) ~ '\0';
        SQLINTEGER value_len = value.length;
        this.setAttribute(ConnectionAttributes.Tracefile, cast(pointer_t) value.ptr, value_len);
    }

    //public @property string translate_lib()
    //{
    //return "";
    //}

    //public @property void translate_lib(string input)
    //{
    //
    //}

    public @property TransactionIsolation transaction_isolation()
    {
        TransactionIsolation output = TransactionIsolation.Undefined;
        if (this.isAllocated)
        {
            SQLINTEGER value = 0;
            this.getAttribute(ConnectionAttributes.TransactionIsolation, cast(pointer_t)&value);
            if (value > 0)
                output = to!TransactionIsolation(value);
        }

        //foreach (v; EnumMembers!TransactionIsolation)
        //if ((to!SQLINTEGER(v) & value) == 0)
        //output ~= v;
        return output;
    }

    public @property void transaction_isolation(TransactionIsolation input)
    {
        SQLINTEGER value = to!SQLINTEGER(input);
        //foreach (i; input)
        //value += to!SQLINTEGER(i);
        this.setAttribute(ConnectionAttributes.TransactionIsolation, &value);
    }

    ////driver getInfo properties
    //public @property string async_mode()
    //{
    //return "";
    //}
    //
    //public @property string async_notification()
    //{
    //return "";
    //}
    //
    //public @property string data_source_name()
    //{
    //return "";
    //}
    //
    //public @property string driver_name()
    //{
    //return "";
    //}
    //
    //public @property string driver_odbc_version()
    //{
    //return "";
    //}
    //
    //public @property string driver_version()
    //{
    //return "";
    //}
    //
    //public @property string info_schema_views()
    //{
    //return "";
    //}
    //
    //public @property string max_async_concurrent_statements()
    //{
    //return "";
    //}
    //
    //public @property string mas_concurrent_activities()
    //{
    //return "";
    //}
    //
    //public @property string max_driver_connections()
    //{
    //return "";
    //}
    //
    //public @property string odbc_interface_conformance()
    //{
    //return "";
    //}
    //
    //public @property string odbc_standard_cli_conformance()
    //{
    //return "";
    //}
    //
    //public @property string odbc_version()
    //{
    //return "";
    //}
    //
    //public @property string parameter_array_row_counts()
    //{
    //return "";
    //}
    //
    //public @property string parameter_array_selects()
    //{
    //return "";
    //}
    //
    //public @property string row_updates()
    //{
    //return "";
    //}
    //
    //public @property string search_pattern_escape()
    //{
    //return "";
    //}
    //
    //public @property string server_name()
    //{
    //return "";
    //}
    //
    ////dbms product getInfo properties
    //public @property string database_name()
    //{
    //return "";
    //}
    //
    //public @property string dbms_name()
    //{
    //return "";
    //}
    //
    //public @property string dbms_version()
    //{
    //return "";
    //}
    //
    ////data source getInfo properties
    //public @property string catalog_term()
    //{
    //return "";
    //}
    //
    //public @property string Statement_commit_behavior()
    //{
    //return "";
    //}
    //
    //public @property string Statement_rollback_behavior()
    //{
    //return "";
    //}
    //
    //public @property string Statement_sensitivity()
    //{
    //return "";
    //}
    //
    //public @property string data_source_read_only()
    //{
    //return "";
    //}
    //
    //public @property string default_transaction_isolation()
    //{
    //return "";
    //}
    //
    //public @property string describe_parameter()
    //{
    //return "";
    //}
    //
    //public @property string multiple_result_sets()
    //{
    //return "";
    //}
    //
    //public @property string multiple_active_transactions()
    //{
    //return "";
    //}
    //
    //public @property string need_long_data_length()
    //{
    //return "";
    //}
    //
    //public @property string null_collation()
    //{
    //return "";
    //}
    //
    //public @property string procedure_term()
    //{
    //return "";
    //}
    //
    //public @property string scheam_term()
    //{
    //return "";
    //}
    //
    //public @property string scroll_options()
    //{
    //return "";
    //}
    //
    //public @property string table_term()
    //{
    //return "";
    //}
    //
    //public @property string transaction_capable()
    //{
    //return "";
    //}
    //
    //public @property string transaction_isolation_option()
    //{
    //return "";
    //}
    //
    //public @property string user_name()
    //{
    //return "";
    //}
    //
    ////supported SQL getInfo properties
    //
    ////SQL limits getInfo properties
    //
    ////scalar function getInfo properties
    //
    ////conversion getInfo properties
}

private Connection connection_factory(size_t login_timeout)
{
    Connection conn = new Connection(login_timeout);
    debug
    {
        writefln("Connection Login Timeout: %s", conn.login_timeout);
        writefln("Connection ODBC Cursors: %s", conn.odbc_cursors);
    }
    return conn;
}

public Connection connect(size_t login_timeout = 0)
{
    return connection_factory(login_timeout);
}

public Connection connect(string[string] kwargs, size_t login_timeout = 0)
{
    Connection conn = connect(login_timeout);
    conn.connect(kwargs["DSN"], kwargs["UID"], kwargs["PWD"]);
    return conn;
}

public Connection connect(string connection_string, size_t login_timeout = 0)
{
    Connection conn = connect(login_timeout);
    conn.connect(connection_string);
    return conn;
}

unittest
{
    writeln("\n\nConnection Unit Tests\n");
    //    Connection conn = connect();
    //
    //    writeln("After allocate:");
    //    assert(conn.environment.isAllocated,
    //            format("Environment is not allocated, status: %s", conn.environment.isAllocated));
    //    assert(conn.isAllocated, format("Connection is not allocated, status: %s", conn.isAllocated));
    //
    //    writefln("Is Allocated: %s", conn.isAllocated);
    //    writefln("Connection String: %s", conn.connection_string);
    //    writefln("Access Mode: %s", conn.access_mode);
    //    writefln("Autocommit: %s", conn.autocommit);
    //    writefln("Connection Timeout: %s", conn.connection_timeout);
    //    writefln("Current Catalog: %s", conn.current_catalog);
    //    writefln("Login Timeout: %s", conn.login_timeout);
    //    writefln("Metadata ID: %s", conn.metadata_id);
    //    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    //    writefln("Packet Size: %s", conn.packet_size);
    //    writefln("Trace: %s", conn.trace);
    //    writefln("Tracefile: %s", conn.tracefile);
    //    writefln("Transaction Isolation: %s", conn.transaction_isolation);
    //
    //    conn.free();
    //    writeln("\nAfter free:");
    //    assert(!conn.isAllocated);
    //
    //    writefln("Is Allocated: %s", conn.isAllocated);
    //    writefln("Connection String: %s", conn.connection_string);
    //    writefln("Access Mode: %s", conn.access_mode);
    //    writefln("Autocommit: %s", conn.autocommit);
    //    writefln("Connection Timeout: %s", conn.connection_timeout);
    //    writefln("Current Catalog: %s", conn.current_catalog);
    //    writefln("Login Timeout: %s", conn.login_timeout);
    //    writefln("Metadata ID: %s", conn.metadata_id);
    //    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    //    writefln("Packet Size: %s", conn.packet_size);
    //    writefln("Trace: %s", conn.trace);
    //    writefln("Tracefile: %s", conn.tracefile);
    //    writefln("Transaction Isolation: %s", conn.transaction_isolation);

    //    conn.destroy();

    auto conn2 = connect();
    assert(conn2.isAllocated);
    //DSN is set up as a file on local directory: C:\testsqlite.sqlite
    string conn_str = "Driver={SQLite3 ODBC Driver};Database=:memory:;";
    conn2.connect(conn_str);

    writeln("\nAfter Connect:");

    writefln("Connection String: %s", conn2.connection_string);
    writefln("Access Mode: %s", conn2.access_mode);
    writefln("Autocommit: %s", conn2.autocommit);
    writefln("Connection Timeout: %s", conn2.connection_timeout);
    writefln("Current Catalog: %s", conn2.current_catalog);
    writefln("Login Timeout: %s", conn2.login_timeout);
    writefln("Metadata ID: %s", conn2.metadata_id);
    writefln("ODBC Cursors: %s", conn2.odbc_cursors);
    writefln("Packet Size: %s", conn2.packet_size);
    writefln("Trace: %s", conn2.trace);
    writefln("Tracefile: %s", conn2.tracefile);
    writefln("Transaction Isolation: %s", conn2.transaction_isolation);

    writeln("\nCalling SQLTables:");
    auto tables_prep = conn2.tables();
    writefln("Number of Columns: %s", tables_prep.n_cols);
    tables_prep.describeColumns();

    writeln("\nCalling SQLColumns:");
    auto columns_prep = conn2.columns();
    writefln("Number of Columns: %s", columns_prep.n_cols);
    columns_prep.describeColumns();

    //        prep.destroy();
    //        conn2.destroy();

    writeln("\n\n");
}
