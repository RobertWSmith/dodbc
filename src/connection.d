module dodbc.connection;

//import etc.c.odbc.sql;
//import etc.c.odbc.sqlext;
//import etc.c.odbc.sqltypes;
//version (Windows) pragma(lib, "odbc32");

import std.conv : to;
import std.typecons : Ternary, Tuple;
import std.traits : EnumMembers;
import std.string : toStringz, fromStringz;
import std.uuid;

import dodbc.root;
import dodbc.environment;
import dodbc.transaction;

// dfmt off
enum ConnectionAttributes : SQLINTEGER
{
    AccessMode = SQL_ATTR_ACCESS_MODE,
    AsyncEnable = SQL_ATTR_ASYNC_ENABLE,
    AutoIPD = SQL_ATTR_AUTO_IPD,
    Autocommit = SQL_ATTR_AUTOCOMMIT,
    ConnectionDead = SQL_ATTR_CONNECTION_DEAD,
    ConnectionTimeout = SQL_ATTR_CONNECTION_TIMEOUT,
    CurrentCatalog = SQL_ATTR_CURRENT_CATALOG,
    EnlistInDTC = SQL_ATTR_ENLIST_IN_DTC,
    LoginTimeout = SQL_ATTR_LOGIN_TIMEOUT,
    MetadataID = SQL_ATTR_METADATA_ID,
    ODBCCursors = SQL_ATTR_ODBC_CURSORS,
    PacketSize = SQL_ATTR_PACKET_SIZE,
    QuietMode = SQL_ATTR_QUIET_MODE,
    Trace = SQL_ATTR_TRACE,
    Tracefile = SQL_ATTR_TRACEFILE,
    TranslateLibrary = SQL_ATTR_TRANSLATE_LIB,
    TranslateOption = SQL_ATTR_TRANSLATE_OPTION,
    TransactionIsolation = SQL_ATTR_TXN_ISOLATION,
    Undefined,
    // AsyncDBCEvent = SQL_ATTR_ASYNC_DBC_EVENT,
    // AsyncDBCFunctionsEnable = SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE,
    // AsyncDBCPcallback = SQL_ATTR_ASYNC_DBC_PCALLBACK,
    // AsyncDBCPcontext = SQL_ATTR_ASYNC_DBC_PCALLBACK,
    // DBCInfoToken = SQL_ATTR_DBC_INFO_TOKEN,
}
// dfmt on

enum AccessMode : SQLUINTEGER
{
    ReadWrite = SQL_MODE_READ_WRITE,
    ReadOnly = SQL_MODE_READ_ONLY,
    Undefined,
}

enum AsyncEnable : SQLULEN
{
    Off = SQL_ASYNC_ENABLE_OFF,
    On = SQL_ASYNC_ENABLE_ON,
    Undefined,
}

enum ODBCCursors : SQLULEN
{
    UseIfNeeded = SQL_CUR_USE_IF_NEEDED,
    UseODBC = SQL_CUR_USE_ODBC,
    UseDriver = SQL_CUR_USE_DRIVER,
    Undefined,
}

enum TransactionIsolation : SQLUINTEGER
{
    ReadUncommitted = SQL_TXN_READ_UNCOMMITTED,
    ReadCommitted = SQL_TXN_READ_COMMITTED,
    RepeatableRead = SQL_TXN_REPEATABLE_READ,
    Serializable = SQL_TXN_SERIALIZABLE,
    Undefined,
}

// dfmt off
enum InfoType : SQLUSMALLINT
{
    AccessibleProcedures = SQL_ACCESSIBLE_PROCEDURES,
    AccessibleTables = SQL_ACCESSIBLE_TABLES,
    ActiveEnvironment = SQL_ACTIVE_ENVIRONMENTS,
    AggregateFunctions = SQL_AGGREGATE_FUNCTIONS,
    AlterDomain = SQL_ALTER_DOMAIN,
    AlterTable = SQL_ALTER_TABLE,
    AsyncMode = SQL_ASYNC_MODE,
    BatchRowCount = SQL_BATCH_ROW_COUNT,
    BatchSupport = SQL_BATCH_SUPPORT,
    CatalogLocation = SQL_CATALOG_LOCATION,
    CatalogName = SQL_CATALOG_NAME,
    CatalogNameSeparator = SQL_CATALOG_NAME_SEPARATOR,
    CatalogTerm = SQL_CATALOG_TERM,
    CatalogUsage = SQL_CATALOG_USAGE,
    CollationSequence = SQL_COLLATION_SEQ,
    CursorCommitBehavior = SQL_CURSOR_COMMIT_BEHAVIOR,
    CursorSensitivity = SQL_CURSOR_SENSITIVITY,
    DataSourceName = SQL_DATA_SOURCE_NAME,
    DataSourceReadOnly = SQL_DATA_SOURCE_READ_ONLY,
    DatetimeLiterals = SQL_DATETIME_LITERALS,
    DBMSName = SQL_DBMS_NAME,
    DBMSVersion = SQL_DBMS_VER,
    DDLIndex = SQL_DDL_INDEX,
    DefaultTransactionIsolation = SQL_DEFAULT_TXN_ISOLATION,
    DescribeParameter = SQL_DESCRIBE_PARAMETER,
    DMVersion = SQL_DM_VER,
    DynamicCursorAttributes1 = SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
    DynamicCursorAttributes2 = SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
    ForwardOnlyCursorAttributes1 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
    ForwardOnlyCursorAttributes2 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
    GetDataExtensions = SQL_GETDATA_EXTENSIONS,
    IdentifierCase = SQL_IDENTIFIER_CASE,
    IdentifierQuoteCahr = SQL_IDENTIFIER_QUOTE_CHAR,
    IndexKeyworkds = SQL_INDEX_KEYWORDS, 
    InfoSchemaViews = SQL_INFO_SCHEMA_VIEWS,
    InsertStatement = SQL_INSERT_STATEMENT, 
    Integrity = SQL_INTEGRITY,
    KeysetCursorAttributes1 = SQL_KEYSET_CURSOR_ATTRIBUTES1,
    KeysetCursorAttributes2 = SQL_KEYSET_CURSOR_ATTRIBUTES2,
    MaxAsyncConcurrentStatements = SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,
    MaxColumnsInGroupBy = SQL_MAX_COLUMNS_IN_GROUP_BY,
    MaxColumnsInIndex = SQL_MAX_COLUMNS_IN_INDEX,
    MaxColumnsInOrderBy = SQL_MAX_COLUMNS_IN_ORDER_BY,
    MaxColumnsInSelect = SQL_MAX_COLUMNS_IN_SELECT,
    MaxColumnsInTable = SQL_MAX_COLUMNS_IN_TABLE,
    MaxConcurrentActivities = SQL_MAX_CONCURRENT_ACTIVITIES,
    MaxDriverConnections = SQL_MAX_DRIVER_CONNECTIONS,
    MaxIndexSize = SQL_MAX_INDEX_SIZE, 
    MaxRowSize = SQL_MAX_ROW_SIZE,
    MaxSchemaNameLength = SQL_MAX_SCHEMA_NAME_LEN, 
    MaxStatementLength = SQL_MAX_STATEMENT_LEN, 
    MaxTableNameLength = SQL_MAX_TABLE_NAME_LEN,
    MaxTablesInSelect = SQL_MAX_TABLES_IN_SELECT,
    MaxUserNameLength = SQL_MAX_USER_NAME_LEN,
    NullCollation = SQL_NULL_COLLATION, 
    ODBCInterfaceConformance = SQL_ODBC_INTERFACE_CONFORMANCE,
    OuterJoinCapabilities = SQL_OJ_CAPABILITIES,
    OrderByColumnsInSelect = SQL_ORDER_BY_COLUMNS_IN_SELECT,
    ParameterArrayRowCounts = SQL_PARAM_ARRAY_ROW_COUNTS,
    ParameterArraySelects = SQL_PARAM_ARRAY_SELECTS,
    SchemaTerm = SQL_SCHEMA_TERM, SchemaUsage = SQL_SCHEMA_USAGE,
    SearchPatternEscape = SQL_SEARCH_PATTERN_ESCAPE,
    ServerName = SQL_SERVER_NAME, 
    SpecialCharacters = SQL_SPECIAL_CHARACTERS,
    SQLConformance = SQL_SQL_CONFORMANCE,
    StaticCursorAttributes1 = SQL_STATIC_CURSOR_ATTRIBUTES1,
    StaticCursorAttributes2 = SQL_STATIC_CURSOR_ATTRIBUTES2, 
    TransactionCapabilities = SQL_TXN_CAPABLE,
    TransactionIsolationOptions = SQL_TXN_ISOLATION_OPTION,
    Union = SQL_UNION, UserName = SQL_USER_NAME,
    // AsyncNotification = SQL_ASYNC_NOTIFICATION,
    // BookmarkPersistence = SQL_BOOKMARK_PERSISTENCE,
    // ColumAlias = SQL_COLUMN_ALIAS,
    // CursorRollbackBehavior = SQL_CURSOR_ROLLBACK_BEHAVIOR,
    // DatabaseName = SQL_DATABASE_NAME,
    // DriverConnection = SQL_DRIVER_HDBC,
    // DriverEnvironment = SQL_DRIVER_HENV,
    // DriverName = SQL_DRIVER_NAME,
    // DriverODBCVersion = SQL_DRIVER_ODBC_VER,
    // DriverVersion = SQL_DRIVER_VER,
    // ExpressionsInOrderBy = SQL_EXPRESSIONS_IN_ORDERBY,
    // FileUsage = SQL_FILE_USAGE,
    // GroupBy = SQL_GROUP_BY,
    // Keywords = SQL_KEYWORDS,
    // LikeEscapeClause = SQL_LIKE_ESCAPE_CLAUSE,
    // MaxBinaryLiteralLength = SQL_MAX_BINARY_LITERAL_LENGTH,
    // MaxCatalogNameLength = SQL_MAX_CATALOG_NAME_LENGTH,
    // MaxCharLiteralLength = SQL_MAX_CHAR_LITERAL_LENGTH,
    // MaxColumnNameLength = SQL_MAX_COLUMN_NAME_LENGTH,
    // MaxCursorNameLength = SQL_MAX_CURSOR_NAME_LENGTH,
    // MaxIdentifierLength = SQL_MAX_IDENTIFIER_LENGTH,
    // MaxProcedureNameLength = SQL_MAX_PROCEDURE_NAME_LEN, 
    // AsyncDBCFucntions = SQL_ASYNC_DBC_FUNCTIONS,
    // ConcatNullBehavior = SQL_CONCAT_NULL_BEHAVIOR,
    // ConvertFunctions = SQL_CONVERT_FUNCTIONS,
    // CorrelationName = SQL_CORRELATION_NAME,
    // CreateAssertion = SQL_CREATE_ASSERTION,
    // CreateCharacterSet = SQL_CREATE_CHARACTER_SET,
    // CreateDomain = SQL_CREATE_DOMAIN,
    // CreateSchema = SQL_CREATE_SCHEMA,
    // Createtable = SQL_CREATE_TABLE,
    // CreateTranslation = SQL_CREATE_TRANSLATION,
    // CreateView = SQL_CREATE_VIEW,
    // DriverAwarePoolingSupported = SQL_DRIVER_AWARE_POOLING_SUPPORTED,
    // StringFunctions = SQL_STRING_FUNCTIONS, 
    // Subqueries = SQL_SUBQUERIES,
    // SystemFunctions = SQL_SYSTEM_FUNCTIONS, 
    // TableTerm = SQL_TABLE_TERM,
    // TimedateAddIntervals = SQL_TIMEDATE_ADD_INTERVALS,
    // TimedateDiffIntervals = SQL_TIMEDATE_DIFF_INTERVALS, 
    // TimedateFunctions = SQL_TIMEDATE_FUNCTIONS,
    // ScrollOptions = SQL_SCROLL_OPTIONS,
    // ProcedureTerm = SQL_PROCEDURE_TERM, 
    // Procedures = SQL_PROCEDURES,
    // PositionOperations = SQL_POS_OPERATIONS,
    // QuotedIdentifierCase = SQL_QUOTED_IDENTIFIER_CASE, 
    // RowUpdates = SQL_ROW_UPDATES,
    // MultipleResultSets = SQL_MULT_RESULT_SETS,
    // MultipleActiveTransactions = SQL_MULTIPLE_ACTIVE_TXN,
    // NeedLongDataLength = SQL_NEED_LONG_DATA_LEN,
    // NonNullableColumns = SQL_NON_NULLABLE_COLUMNS,
    // ODBCVersion = SQL_ODBC_VER, 
    // MaxRowSizeIncludesLong = SQL_MAX_ROW_SIZE_INCLUDES_LONG,
}
// dfmt on

class Connection : Handle!(HandleType.Connection, SQLGetConnectAttr,
        SQLSetConnectAttr, ConnectionAttributes)
{
    private Environment _env;
    private handle_t _handle = SQL_NULL_HANDLE;
    private string _connection_string;
    private Transaction[UUID] _transactions;

    package this()
    {
        super();
        this._env = new Environment(ODBCVersion.v3);
        this.allocate(((this.environment).handle));
    }

    public Transaction start()
    {
        UUID id = randomUUID();
        this._transactions[id] = new Transaction(this, id);
        this._transactions[id].start();
        return this._transactions[id];
    }

    public bool end(U : Transaction)(U input)
    {
        return this.end(input.id);
    }

    public bool end(U : UUID)(U input)
    {
        this._transactions[id].close();
        return this._transactions.remove(input);
    }

    public ODBCReturn getInfo(InfoType info_type, pointer_t value_ptr,
            SQLSMALLINT buffer_length = 0, SQLSMALLINT* string_length_ptr = null)
    {
        return to!ODBCReturn(SQLGetInfo((this.handle), info_type, value_ptr,
                buffer_length, string_length_ptr));
    }

    public ODBCReturn connect(string dsn, string uid, string pwd, handle_t event_handle = null)
    {
        string conn_str = "DSN={" ~ dsn ~ "};";
        if (uid !is null)
            conn_str ~= "UID={" ~ uid ~ "};";
        if (pwd !is null)
            conn_str ~= "PWD={" ~ pwd ~ "};";

        return this.connect(conn_str);
    }

    public ODBCReturn connect(string connection_string_ = null, handle_t event_handle = null)
    {
        this.disconnect();

        if (connection_string_ !is null)
            this.connection_string = connection_string_;

        SQLCHAR[] conn_str = to!(SQLCHAR[])(toStringz(this.connection_string));
        SQLSMALLINT conn_str_len = to!SQLSMALLINT(conn_str.length);
        SQLCHAR[2048 + 1] conn_str_out;
        conn_str_out[] = '\0';
        SQLSMALLINT buffer_length = conn_str_out.length - 1, out_conn_str_len = 0;
        ODBCReturn output = to!ODBCReturn(SQLDriverConnect(this.handle, cast(SQLHWND) null, conn_str.ptr, conn_str_len,
                conn_str_out.ptr, buffer_length, &out_conn_str_len, SQL_DRIVER_NOPROMPT));

        string cstr = to!string(fromStringz(conn_str_out.ptr));
        if (cstr.length > 0 && cstr != this.connection_string)
            this.connection_string = cstr.dup;
        return output;
    }

    public ODBCReturn disconnect()
    {
        return to!ODBCReturn(SQLDisconnect((this.handle)));
    }

//    public void enable_async(handle_t event_handle)
//    {
//
//    }

//    public void async_complete()
//    {
//
//    }

    public @property Environment environment()
    {
        return this._env;
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
        SQLUINTEGER value_ptr = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.AccessMode, cast(pointer_t)&value_ptr);
    }

    public @property AccessMode access_mode()
    {
        SQLUINTEGER value_ptr = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.AccessMode, cast(pointer_t)&value_ptr);
        return to!AccessMode(value_ptr);
    }

    public @property AsyncEnable async_enable()
    {
        SQLULEN value_ptr = SQLULEN.init;
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
            SQLULEN value_ptr = SQLULEN.init;
            this.getAttribute(ConnectionAttributes.AutoIPD, &value_ptr);
            output = (value_ptr == SQL_TRUE);
        }
        return output;
    }

    public @property void autocommit(bool input)
    {
        SQLUINTEGER value_ptr = input ? SQL_AUTOCOMMIT_ON : SQL_AUTOCOMMIT_OFF;
        this.setAttribute(ConnectionAttributes.Autocommit, cast(pointer_t) value_ptr);
    }

    public @property bool autocommit()
    {
        SQLUINTEGER value_ptr = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.Autocommit, &value_ptr);
        return (value_ptr == SQL_AUTOCOMMIT_ON);
    }

    //    public @property bool connection_dead()
    //    {
    //        
    //        this.getAttribute(ConnectionAttributes.ConnectionDead, 
    //        return true;
    //    }

    public @property uint connection_timeout()
    {
        SQLUINTEGER value_ptr = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.ConnectionTimeout, &value_ptr);
        return to!uint(value_ptr);
    }

    public @property void connection_timeout(uint input)
    {
        SQLUINTEGER value_ptr = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.ConnectionTimeout, &value_ptr);
    }

    public @property string current_catalog()
    {
        char[(2048 + 1)] value;
        value[] = '\0';

        SQLINTEGER value_len = value.length, str_len_ptr = SQLINTEGER.init;

        this.getAttribute(ConnectionAttributes.CurrentCatalog,
                cast(pointer_t) value.ptr, value_len, &str_len_ptr);
        return to!string(value[0 .. str_len_ptr]);
    }

    public @property void current_catalog(string input)
    {
        char[] value = to!(char[])(toStringz(input));
        //        value ~= '\0';
        SQLINTEGER len = value.length;
        this.setAttribute(ConnectionAttributes.CurrentCatalog, cast(pointer_t) value.ptr, len);
    }

    public @property uint login_timeout()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.LoginTimeout, &value);
        return to!uint(value);
    }

    /// before connect only
    private @property void login_timeout(uint input)
    {
        SQLUINTEGER value = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.LoginTimeout, cast(pointer_t) value);
    }

    public @property bool metadata_id()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.MetadataID, &value);
        return (value == SQL_TRUE);
    }

    public @property void metadata_id(bool input)
    {
        SQLUINTEGER value = input ? SQL_TRUE : SQL_FALSE;
        this.setAttribute(ConnectionAttributes.MetadataID, cast(pointer_t) value);
    }

    public @property ODBCCursors odbc_cursors()
    {
        SQLULEN value = SQLULEN.init;
        this.getAttribute(ConnectionAttributes.ODBCCursors, &value);
        return to!ODBCCursors(value);
    }

    /// set before connection only
    private @property void odbc_cursors(ODBCCursors input)
    {

        SQLULEN value = to!SQLULEN(input);
        this.setAttribute(ConnectionAttributes.ODBCCursors, &value);
    }

    public @property uint packet_size()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.PacketSize, cast(pointer_t) value);
        return to!uint(value);
    }

    /// set before connection only
    private @property void packet_size(uint input)
    {
        SQLUINTEGER value = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.PacketSize, &value);
    }

    public @property bool trace()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.Trace, &value);
        return (value == SQL_OPT_TRACE_ON);
    }

    public @property void trace(bool input)
    {
        SQLUINTEGER value = input ? SQL_OPT_TRACE_ON : SQL_OPT_TRACE_OFF;
        this.setAttribute(ConnectionAttributes.Trace, cast(pointer_t) value);
    }

    public @property string tracefile()
    {
        char[(2048 + 1)] value;
        value[] = '\0';
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

    //    public @property string translate_lib()
    //    {
    //        return "";
    //    }

    //    public @property void translate_lib(string input)
    //    {
    //
    //    }

    public @property TransactionIsolation transaction_isolation()
    {
        TransactionIsolation output = TransactionIsolation.Undefined;
        if (this.isAllocated)
        {
            SQLUINTEGER value = 0;
            this.getAttribute(ConnectionAttributes.TransactionIsolation, cast(pointer_t)&value);
            if (value > 0)
                output = to!TransactionIsolation(value);
        }

        //        foreach (v; EnumMembers!TransactionIsolation)
        //            if ((to!SQLUINTEGER(v) & value) == 0)
        //                output ~= v;

        return output;
    }

    public @property void transaction_isolation(TransactionIsolation input)
    {
        SQLUINTEGER value = to!SQLUINTEGER(input);
        //        foreach (i; input)
        //            value += to!SQLUINTEGER(i);
        this.setAttribute(ConnectionAttributes.TransactionIsolation, &value);
    }
}

private Connection setup_connect(uint login_timeout_ = 0,
        ODBCCursors odbc_cursors_ = ODBCCursors.UseDriver)
{
    Connection conn = new Connection();
    conn.login_timeout = login_timeout_;
    conn.odbc_cursors = odbc_cursors_;
    return conn;
}

Connection connect(string dsn, string uid = null, string pwd = null,
        uint login_timeout_ = 0, ODBCCursors odbc_cursors_ = ODBCCursors.UseDriver)
{
    Connection conn = setup_connect(login_timeout_, odbc_cursors_);
    conn.connect(dsn, uid, pwd);
    return conn;
}

Connection connect(string connection_string = null, uint login_timeout_ = 0,
        ODBCCursors odbc_cursors_ = ODBCCursors.UseDriver)
{
    Connection conn = setup_connect(login_timeout_, odbc_cursors_);
    if (connection_string !is null)
        conn.connect(connection_string);
    return conn;
}

unittest
{
    import std.stdio;

    Connection conn = connect();
    assert(conn.isAllocated);
    assert(conn.environment.isAllocated);

    writeln("Connection Unit Tests\n");
    writeln("After allocate:");
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

    conn.allocate();
    string conn_str = "DRIVER={SQLite3 ODBC Driver};Database={c:/mydb.db};LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;";
    conn.connect(conn_str);

    writeln("\nAfter Connect:");
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

    writeln("\n\n");
}
