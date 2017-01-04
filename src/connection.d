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

version (Windows) import core.sys.windows.windows;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;
import etc.c.odbc.sqlucode;

version (Windows) pragma(lib, "odbc32");

import dodbc.types;
import dodbc.constants;
import dodbc.root;
import dodbc.environment;
import dodbc.statement;

// // shared Environment variable
//import std.concurrency;
//import core.atomic;
//import core.sync.mutex : Mutex;
//
//shared static this()
//{
//    sharedConnectionMutex = new Mutex;
//}
//
// // this mutex protects `sharedConnectionMutexArray`
//private __gshared Mutex sharedConnectionMutex;
// // this mutex array protects `sharedConnectionObjectArray`
//private __gshared Mutex[uuid.UUID] sharedConnectionMutexArray;
//private shared Connection[uuid.UUID] sharedConnectionObjectArray;
//
// // returns the default global environment
//private Connection defaultSharedConnectionImpl(
//        uuid.UUID id = uuid.UUID("00000000-0000-0000-0000-000000000001")) @trusted
//{
//    synchronized (sharedConnectionMutex)
//    {
//        Mutex* m = (id in sharedConnectionMutexArray);
//        if (m is null)
//        {
//            *m = new Mutex;
//            synchronized (*m)
//            {
//                Connection conn = connect();
//                sharedConnectionObjectArray[id] = cast(shared) conn;
//            }
//        }
//    }
//    return cast(Connection) atomicLoad!(MemoryOrder.acq)(sharedConnectionObjectArray[id]);
//}
//
//public Connection sharedConnection(uuid.UUID id)
//{
//    static auto trustedLoad(ref shared Connection env) @trusted
//    {
//        return atomicLoad!(MemoryOrder.acq)(env);
//    }
//
//    // if we have set up our own environment use that
//    if (auto env = trustedLoad(sharedConnectionObjectArray[id]))
//    {
//        return env;
//    }
//    else
//    {
//        return defaultSharedConnectionImpl;
//    }
//}
//
//public void sharedConnection(Connection input) @trusted
//{
//    uuid.UUID id = input.id;
//    atomicStore!(MemoryOrder.rel)(sharedConnectionObjectArray[id], cast(shared) input);
//}

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
        SQLCHAR[] value = new SQLCHAR[this.max_catalog_name_length + 1];
        SQLINTEGER str_len_ptr;

        this.getAttribute(ConnectionAttributes.CurrentCatalog,
                cast(pointer_t) value.ptr, (value.length - 1), &str_len_ptr);
        return str_conv(value.ptr);
    }

    public @property void current_catalog(string input)
    {
        SQLCHAR[] value = to!(SQLCHAR[])(toStringz(input));
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

    //    public void getInfo(InfoType info_type, pointer_t value_ptr,
    //            SQLSMALLINT buffer_length = 0, SQLSMALLINT* string_length_ptr = null)

    // //driver getInfo properties
    public @property AsyncMode async_mode()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.AsyncMode, &value);
        return to!AsyncMode(value);
    }

    //    public @property bool async_notification_capable()
    //    {
    //        SQLUINTEGER value;
    //        this.getInfo(InfoType.AsyncNotification, &value);
    //        return (value == SQL_ASYNC_NOTIFICATION_CAPABLE);
    //    }

    public @property string data_source_name()
    {
        SQLCHAR[1024 + 1] value;
        this.getInfo(InfoType.DataSourceName, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property string driver_name()
    {
        SQLCHAR[1024 + 1] value;
        this.getInfo(InfoType.DriverName, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property string driver_odbc_version()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.DriverODBCVersion, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property string driver_version()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.DriverVersion, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property SQLUINTEGER information_schema_views()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.InformationSchemaViews, &value);
        return value;
    }

    public @property ODBCInterfaceConformance odbc_interface_conformance()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.ODBCInterfaceConformance, &value);
        return to!ODBCInterfaceConformance(value);
    }

    //public @property string odbc_standard_cli_conformance()
    //{
    //return "";
    //}

    public @property string odbc_version()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.ODBCVersion, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

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
    public @property string database_name()
    {
        SQLCHAR[1024 + 1] value;
        this.getInfo(InfoType.DatabaseName, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property string dbms_name()
    {
        SQLCHAR[1024 + 1] value;
        this.getInfo(InfoType.DBMSName, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property string dbms_version()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.DBMSVersion, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    //data source getInfo properties
    public @property string catalog_term()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.CatalogTerm, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property CursorCommitBehavior cursor_commit_behavior()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.CursorCommitBehavior, cast(pointer_t)&value);
        return to!CursorCommitBehavior(value);
    }

    public @property CursorRollbackBehavior cursor_rollback_behavior()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.CursorRollbackBehavior, cast(pointer_t)&value);
        return to!CursorRollbackBehavior(value);
    }

    public @property CursorSensitivity cursor_sensitivity()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CursorSensitivity, cast(pointer_t)&value);
        return to!CursorSensitivity(value);
    }

    public @property bool data_source_read_only()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.DataSourceReadOnly, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property DefaultTransactionIsolation default_transaction_isolation()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.DefaultTransactionIsolation, &value);
        return to!DefaultTransactionIsolation(value);
    }

    public @property bool supports_describe_parameter()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.DescribeParameter, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property bool supports_multiple_result_sets()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.MultipleResultSets, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property bool supports_multiple_active_transactions()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.MultipleActiveTransactions, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property bool need_long_data_length()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.NeedLongDataLength, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property SQLUSMALLINT null_collation()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.NullCollation, &value);
        return value;
    }

    public @property string procedure_term()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.ProcedureTerm, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property string schema_term()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.SchemaTerm, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property SQLUINTEGER scroll_options()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.ScrollOptions, &value);
        return value;
    }

    public @property string table_term()
    {
        SQLCHAR[64 + 1] value;
        this.getInfo(InfoType.TableTerm, cast(pointer_t) value.ptr, value.length);
        return str_conv(value.ptr);
    }

    public @property SQLUSMALLINT transaction_capable()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.TransactionCapabilities, &value);
        return value;
    }

    public @property SQLUINTEGER transaction_isolation_option()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.TransactionIsolationOptions, &value);
        return value;
    }

    public @property string user_name()
    {
        SQLCHAR[] value = new SQLCHAR[this.max_user_name_length + 1];
        this.getInfo(InfoType.UserName, cast(pointer_t) value.ptr,
                to!SQLSMALLINT(value.length - 1));
        return str_conv(value.ptr);
    }

    //supported SQL getInfo properties

    public @property SQLUINTEGER aggregate_functions()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.AggregateFunctions, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER alter_domain()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.AlterDomain, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER alter_table()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.AlterTable, cast(pointer_t)&value);
        return value;
    }

    //    public @property SQLUINTEGER ansi_sql_datetime_literals()
    //    {
    //        return "";
    //    }

    public @property CatalogLocation catalog_location()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CatalogLocation, cast(pointer_t)&value);
        return to!CatalogLocation(value);
    }

    public @property bool supports_catalog_name()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.CatalogName, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property string catalog_name_separator()
    {
        if (this.supports_catalog_name)
        {
            SQLCHAR[64 + 1] value;
            this.getInfo(InfoType.UserName, cast(pointer_t) value.ptr, value.length);
            return str_conv(value.ptr);
        }
        return "";
    }

    public @property SQLUINTEGER catalog_usage()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CatalogUsage, cast(pointer_t)&value);
        return value;
    }

    public @property bool supports_column_alias()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.ColumnAlias, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property SQLUSMALLINT correlation_name()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.CorrelationName, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_assertion()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateAssertion, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_character_set()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateCharacterSet, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_collation()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateCollation, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_domain()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateDomain, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_schema()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateSchema, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_table()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateTable, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_translation()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateTranslation, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER create_view()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.CreateView, cast(pointer_t)&value);
        return value;
    }

    public @property SQLUINTEGER ddl_index()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.DDLIndex, cast(pointer_t)&value);
        return value;
    }

    //    public @property string drop_assertion()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_character_set()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_collation()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_domain()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_schema()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_table()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_translation()
    //    {
    //        return "";
    //    }
    //
    //    public @property string drop_view()
    //    {
    //        return "";
    //    }
    //
    //    public @property string expressions_in_order_by()
    //    {
    //        return "";
    //    }
    //
    //    public @property string group_by()
    //    {
    //        return "";
    //    }
    //
    //    public @property string identifier_case()
    //    {
    //        return "";
    //    }
    //
    //    public @property string identifier_quote_char()
    //    {
    //        return "";
    //    }
    //
    //    public @property string index_keywords()
    //    {
    //        return "";
    //    }
    //
    //    public @property string insert_statement()
    //    {
    //        return "";
    //    }
    //
    //    public @property string integrity()
    //    {
    //        return "";
    //    }
    //
    //    public @property string keywords()
    //    {
    //        return "";
    //    }
    //
    //    public @property string like_escape_clause()
    //    {
    //        return "";
    //    }
    //
    //    public @property string non_nullable_columns()
    //    {
    //        return "";
    //    }
    //
    //    public @property string sql_conformance()
    //    {
    //        return "";
    //    }
    //
    //    public @property string outer_join_capabilities()
    //    {
    //        return "";
    //    }
    //
    //    public @property string order_by_columns_in_select()
    //    {
    //        return "";
    //    }
    //
    //    public @property string outer_joins()
    //    {
    //        return "";
    //    }
    //
    //    public @property string procedures()
    //    {
    //        return "";
    //    }
    //
    //    public @property string quoted_identifier_case()
    //    {
    //        return "";
    //    }
    //
    //    public @property string schema_usage()
    //    {
    //        return "";
    //    }
    //
    //    public @property string special_characters()
    //    {
    //        return "";
    //    }
    //
    //    public @property string subqueries()
    //    {
    //        return "";
    //    }
    //
    //    public @property string sql_union()
    //    {
    //        return "";
    //    }

    //SQL limits getInfo properties

    public @property size_t max_async_concurrent_statements()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.MaxAsyncConcurrentStatements, &value);
        return to!size_t(value);
    }

    public @property size_t max_binary_literal_length()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.MaxBinaryLiteralLength, cast(pointer_t)&value);
        return to!size_t(value);
    }

    public @property ushort max_catalog_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxCatalogNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property size_t max_character_literals_length()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.MaxCharacterLiteralsLength, cast(pointer_t)&value);
        return to!size_t(value);
    }

    public @property ushort max_column_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxColumnNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_columns_in_group_by()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxColumnsInGroupBy, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_columns_in_index()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxColumnsInIndex, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_columns_in_order_by()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxColumnsInOrderBy, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_columns_in_select()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxColumnsInSelect, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_columns_in_table()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxColumnsInTable, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_concurrent_activities()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxConcurrentActivities, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_cursor_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxCursorNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_driver_connections()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxDriverConnections, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_identifier_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxIdentifierLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property size_t max_index_size()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.MaxIndexSize, cast(pointer_t)&value);
        return to!size_t(value);
    }

    public @property ushort max_procedure_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxProcedureNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property size_t max_row_size()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.MaxRowSize, cast(pointer_t)&value);
        return to!size_t(value);
    }

    public @property bool max_row_size_includes_long()
    {
        SQLCHAR[1 + 1] value;
        this.getInfo(InfoType.MaxRowSizeIncludesLong, cast(pointer_t) value.ptr, value.length);
        return (value[0] == 'Y');
    }

    public @property ushort max_schema_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxSchemaNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property size_t max_statement_length()
    {
        SQLUINTEGER value;
        this.getInfo(InfoType.MaxStatementLength, cast(pointer_t)&value);
        return to!size_t(value);
    }

    public @property ushort max_table_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxTableNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_tables_in_select()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxTablesInSelect, cast(pointer_t)&value);
        return to!ushort(value);
    }

    public @property ushort max_user_name_length()
    {
        SQLUSMALLINT value;
        this.getInfo(InfoType.MaxUserNameLength, cast(pointer_t)&value);
        return to!ushort(value);
    }

    //scalar function getInfo properties

    //    public @property string convert_functions()
    //    {
    //        return "";
    //    }
    //
    //    public @property string numeric_functions()
    //    {
    //        return "";
    //    }
    //
    //    public @property string string_functions()
    //    {
    //        return "";
    //    }
    //
    //    public @property string system_functions()
    //    {
    //        return "";
    //    }
    //
    //    public @property string timedate_add_intervals()
    //    {
    //        return "";
    //    }
    //
    //    public @property string timedate_diff_intervals()
    //    {
    //        return "";
    //    }
    //
    //    public @property string timedate_functions()
    //    {
    //        return "";
    //    }

    //conversion getInfo properties

    //    public @property string convert_bigint()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_binary()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_bit()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_char()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_date()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_decimal()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_double()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_float()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_integer()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_interval_year_month()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_interval_day_time()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_longvarbinary()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_longvarchar()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_numeric()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_real()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_smallint()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_time()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_timestamp()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_tinyint()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_varbinary()
    //    {
    //        return "";
    //    }
    //
    //    public @property string convert_varchar()
    //    {
    //        return "";
    //    }

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
    Connection conn = connect();

    writeln("After allocate:");
    assert(conn.environment.isAllocated,
            format("Environment is not allocated, status: %s", conn.environment.isAllocated));
    assert(conn.isAllocated, format("Connection is not allocated, status: %s", conn.isAllocated));
    writefln("Is Allocated: %s", conn.isAllocated);
    writefln("Connection String: %s", conn.connection_string);
    writefln("Access Mode: %s", conn.access_mode);
    writefln("Autocommit: %s", conn.autocommit);
    writefln("Connection Timeout: %s", conn.connection_timeout);
    writefln("Current Catalog: %s", conn.current_catalog);
    writefln("Login Timeout: %s", conn.login_timeout);
    writefln("Metadata ID: %s", conn.metadata_id);
    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    writefln("Packet Size: %s", conn.packet_size);
    writefln("Trace: %s", conn.trace);
    writefln("Tracefile: %s", conn.tracefile);
    writefln("Transaction Isolation: %s", conn.transaction_isolation);

    conn.free();
    writeln("\nAfter free:");
    assert(!conn.isAllocated);

    writefln("Is Allocated: %s", conn.isAllocated);
    writefln("Connection String: %s", conn.connection_string);
    writefln("Access Mode: %s", conn.access_mode);
    writefln("Autocommit: %s", conn.autocommit);
    writefln("Connection Timeout: %s", conn.connection_timeout);
    writefln("Current Catalog: %s", conn.current_catalog);
    writefln("Login Timeout: %s", conn.login_timeout);
    writefln("Metadata ID: %s", conn.metadata_id);
    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    writefln("Packet Size: %s", conn.packet_size);
    writefln("Trace: %s", conn.trace);
    writefln("Tracefile: %s", conn.tracefile);
    writefln("Transaction Isolation: %s", conn.transaction_isolation);

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

    writefln("Async Mode: %s", conn2.async_mode);
    writefln("Data Source Name: %s", conn2.data_source_name);
    writefln("Driver Name: %s", conn2.driver_name);
    writefln("Driver ODBC Version: %s", conn2.driver_odbc_version);
    writefln("Driver Version: %s", conn2.driver_version);
    writefln("Information Schema Views: %s", conn2.information_schema_views);
    writefln("ODBC Interface Conformance: %s", conn2.odbc_interface_conformance);
    writefln("ODBC Version: %s", conn2.odbc_version);
    writefln("Database Name: %s", conn2.database_name);
    writefln("DBMS Name: %s", conn2.dbms_name);
    writefln("DBMS Version: %s", conn2.dbms_version);
    writefln("Catalog Term: %s", conn2.catalog_term);
    writefln("Cursor Commit Behavior: %s", conn2.cursor_commit_behavior);
    writefln("Cursor Rollback Behavior: %s", conn2.cursor_rollback_behavior);
    writefln("Cursor Sensitivity: %s", conn2.cursor_sensitivity);
    writefln("Default Transaction Isolation: %s", conn2.default_transaction_isolation);
    writefln("Supports Describe Parameter: %s", conn2.supports_describe_parameter);
    writefln("Supports Multiple Result Sets: %s", conn2.supports_multiple_result_sets);
    writefln("Needs Long Data Length: %s", conn2.need_long_data_length);
    writefln("Null Collation: %s", conn2.null_collation);
    writefln("Procedure Term: %s", conn2.procedure_term);
    writefln("Schema Term: %s", conn2.schema_term);
    writefln("Scroll Options: %s", conn2.scroll_options);
    writefln("Table Term: %s", conn2.table_term);
    writefln("Transaction Capabilities: %s", conn2.transaction_capable);
    writefln("Transaction Isolation Option: %s", conn2.transaction_isolation_option);
    writefln("User Name: %s", conn2.user_name);

    writefln("Max Async Concurrent Statements: %s", conn2.max_async_concurrent_statements);
    writefln("Max Binary Literal Length: %s", conn2.max_binary_literal_length);
    writefln("Max Catalog Name Length: %s", conn2.max_catalog_name_length);
    writefln("Max Character Literals Length: %s", conn2.max_character_literals_length);
    writefln("Max Column Name Length: %s", conn2.max_column_name_length);
    writefln("Max Concurrent Statements: %s", conn2.max_concurrent_activities);
    writefln("Max Driver Connections: %s", conn2.max_driver_connections);
    writefln("Max Identifier Length: %s", conn2.max_identifier_length);
    writefln("Max Row Size: %s", conn2.max_row_size);
    writefln("Max Schema Name Length: %s", conn2.max_schema_name_length);
    writefln("Max Statement Length: %s", conn2.max_statement_length);
    writefln("Max Table Name Length: %s", conn2.max_table_name_length);
    writefln("Max User Name Length: %s", conn2.max_user_name_length);

    writeln("\nCalling SQLTables:");
    auto tables_prep = conn2.tables();
    writefln("Number of Columns: %s", tables_prep.n_cols);
    tables_prep.describeColumns();
    writeln("\nCalling SQLColumns:");
    auto columns_prep = conn2.columns();
    writefln("Number of Columns: %s", columns_prep.n_cols);
    columns_prep.describeColumns(); //        prep.destroy();
    //        conn2.destroy();

    writeln("\n\n");
}
