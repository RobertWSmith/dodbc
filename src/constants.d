module dodbc.constants;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;

alias SQLULEN = ulong;
alias SQLLEN = long;

enum ODBCReturn : SQLRETURN
{
    Success = SQL_SUCCESS,
    SuccessWithInfo = SQL_SUCCESS_WITH_INFO,
    NoData = SQL_NO_DATA,
    Error = SQL_ERROR,
    InvalidHandle = SQL_INVALID_HANDLE,
    StillExecuting = SQL_STILL_EXECUTING,
    NeedData = SQL_NEED_DATA
}

enum StringLengths : SQLINTEGER
{
    NullTerminatedString = SQL_NTS,
    IsPointer = SQL_IS_POINTER,
    IsInteger = SQL_IS_INTEGER,
    IsUnsigned = SQL_IS_UINTEGER,
    Undefined,
}

enum HandleType : SQLSMALLINT
{
    Environment = SQL_HANDLE_ENV,
    Connection = SQL_HANDLE_DBC,
    Statement = SQL_HANDLE_STMT,
    Description = SQL_HANDLE_DESC,
    Undefined,
}

enum EnvironmentAttributes : SQLINTEGER
{
    ODBCVersion = SQL_ATTR_ODBC_VERSION,
    ConnectionPooling = SQL_ATTR_CONNECTION_POOLING,
    ConnectionPoolMatch = SQL_ATTR_CP_MATCH,
    NullTerminatedStrings = SQL_ATTR_OUTPUT_NTS,
    Undefined,
}

enum ODBCVersion : SQLINTEGER
{
    v3 = SQL_OV_ODBC3,
    v2 = SQL_OV_ODBC2,
    Undefined,
}

enum ConnectionPoolMatch : SQLUINTEGER
{
    StrictMatch = SQL_CP_STRICT_MATCH,
    RelaxedMatch = SQL_CP_RELAXED_MATCH,
    Undefined,
}

enum ConnectionPooling : SQLUINTEGER
{
    Off, // = SQL_CP_OFF,
    OnePerDriver,
    OnePerEnvironment,
    DriverAware,
    Undefined,
}

// AsyncDBCEvent = SQL_ATTR_ASYNC_DBC_EVENT,
// AsyncDBCFunctionsEnable = SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE,
// AsyncDBCPcallback = SQL_ATTR_ASYNC_DBC_PCALLBACK,
// AsyncDBCPcontext = SQL_ATTR_ASYNC_DBC_PCALLBACK,
// DBCInfoToken = SQL_ATTR_DBC_INFO_TOKEN,
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
}

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

enum StatementAttributes : SQLINTEGER
{
    Undefined,
}

enum InfoType : SQLUSMALLINT
{
    AccessibleProcedures = SQL_ACCESSIBLE_PROCEDURES,
    AccessibleTables = SQL_ACCESSIBLE_TABLES,
    ActiveEnvironment = SQL_ACTIVE_ENVIRONMENTS,
    AggregateFunctions = SQL_AGGREGATE_FUNCTIONS,
    AlterDomain = SQL_ALTER_DOMAIN,
    AlterTable = SQL_ALTER_TABLE,
    AsyncMode = SQL_ASYNC_MODE,
    //    AsyncNotification = SQL_ASYNC_NOTIFICATION,
    BatchRowCount = SQL_BATCH_ROW_COUNT,
    BatchSupport = SQL_BATCH_SUPPORT,
    //    BookmarkPersistence = SQL_BOOKMARK_PERSISTENCE,
    CatalogLocation = SQL_CATALOG_LOCATION,
    CatalogName = SQL_CATALOG_NAME,
    CatalogNameSeparator = SQL_CATALOG_NAME_SEPARATOR,
    CatalogTerm = SQL_CATALOG_TERM,
    CatalogUsage = SQL_CATALOG_USAGE,
    CollationSequence = SQL_COLLATION_SEQ,
    //    ColumAlias = SQL_COLUMN_ALIAS,
    CursorCommitBehavior = SQL_CURSOR_COMMIT_BEHAVIOR,
    //    CursorRollbackBehavior = SQL_CURSOR_ROLLBACK_BEHAVIOR,
    CursorSensitivity = SQL_CURSOR_SENSITIVITY,
    DataSourceName = SQL_DATA_SOURCE_NAME,
    DataSourceReadOnly = SQL_DATA_SOURCE_READ_ONLY,
    //    DatabaseName = SQL_DATABASE_NAME,
    DatetimeLiterals = SQL_DATETIME_LITERALS,
    DBMSName = SQL_DBMS_NAME,
    DBMSVersion = SQL_DBMS_VER,
    DDLIndex = SQL_DDL_INDEX,
    DefaultTransactionIsolation = SQL_DEFAULT_TXN_ISOLATION,
    DescribeParameter = SQL_DESCRIBE_PARAMETER,
    DMVersion = SQL_DM_VER,
    //    DriverConnection = SQL_DRIVER_HDBC,
    //    DriverEnvironment = SQL_DRIVER_HENV,
    //    DriverName = SQL_DRIVER_NAME,
    //    DriverODBCVersion = SQL_DRIVER_ODBC_VER,
    //    DriverVersion = SQL_DRIVER_VER,
    DynamicCursorAttributes1 = SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
    DynamicCursorAttributes2 = SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
    //    ExpressionsInOrderBy = SQL_EXPRESSIONS_IN_ORDERBY,
    //    FileUsage = SQL_FILE_USAGE,
    ForwardOnlyCursorAttributes1 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
    ForwardOnlyCursorAttributes2 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
    GetDataExtensions = SQL_GETDATA_EXTENSIONS,
    //    GroupBy = SQL_GROUP_BY,
    IdentifierCase = SQL_IDENTIFIER_CASE,
    IdentifierQuoteCahr = SQL_IDENTIFIER_QUOTE_CHAR,
    IndexKeyworkds = SQL_INDEX_KEYWORDS,
    InfoSchemaViews = SQL_INFO_SCHEMA_VIEWS,
    InsertStatement = SQL_INSERT_STATEMENT,
    Integrity = SQL_INTEGRITY,
    KeysetCursorAttributes1 = SQL_KEYSET_CURSOR_ATTRIBUTES1,
    KeysetCursorAttributes2 = SQL_KEYSET_CURSOR_ATTRIBUTES2,
    //    Keywords = SQL_KEYWORDS,
    //    LikeEscapeClause = SQL_LIKE_ESCAPE_CLAUSE,
    MaxAsyncConcurrentStatements = SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,
    //    MaxBinaryLiteralLength = SQL_MAX_BINARY_LITERAL_LENGTH,
    //    MaxCatalogNameLength = SQL_MAX_CATALOG_NAME_LENGTH,
    //    MaxCharLiteralLength = SQL_MAX_CHAR_LITERAL_LENGTH,
    //    MaxColumnNameLength = SQL_MAX_COLUMN_NAME_LENGTH,
    MaxColumnsInGroupBy = SQL_MAX_COLUMNS_IN_GROUP_BY,
    MaxColumnsInIndex = SQL_MAX_COLUMNS_IN_INDEX, 
    MaxColumnsInOrderBy = SQL_MAX_COLUMNS_IN_ORDER_BY,
    MaxColumnsInSelect = SQL_MAX_COLUMNS_IN_SELECT,
    MaxColumnsInTable = SQL_MAX_COLUMNS_IN_TABLE,
    MaxConcurrentActivities = SQL_MAX_CONCURRENT_ACTIVITIES,
    //    MaxCursorNameLength = SQL_MAX_CURSOR_NAME_LENGTH,
    MaxDriverConnections = SQL_MAX_DRIVER_CONNECTIONS,
    //    MaxIdentifierLength = SQL_MAX_IDENTIFIER_LENGTH,
    MaxIndexSize = SQL_MAX_INDEX_SIZE, 
    //    MaxProcedureNameLength = SQL_MAX_PROCEDURE_NAME_LEN, 
    MaxRowSize = SQL_MAX_ROW_SIZE,
    //    MaxRowSizeIncludesLong = SQL_MAX_ROW_SIZE_INCLUDES_LONG,
        MaxSchemaNameLength = SQL_MAX_SCHEMA_NAME_LEN,
        MaxStatementLength = SQL_MAX_STATEMENT_LEN,
        MaxTableNameLength = SQL_MAX_TABLE_NAME_LEN,
        MaxTablesInSelect = SQL_MAX_TABLES_IN_SELECT,
        MaxUserNameLength = SQL_MAX_USER_NAME_LEN, //    MultipleResultSets = SQL_MULT_RESULT_SETS,
        //    MultipleActiveTransactions = SQL_MULTIPLE_ACTIVE_TXN,
        //    NeedLongDataLength = SQL_NEED_LONG_DATA_LEN,
        //    NonNullableColumns = SQL_NON_NULLABLE_COLUMNS,
        NullCollation = SQL_NULL_COLLATION,
        ODBCInterfaceConformance = SQL_ODBC_INTERFACE_CONFORMANCE,
        //    ODBCVersion = SQL_ODBC_VER, 
        OuterJoinCapabilities = SQL_OJ_CAPABILITIES,
        OrderByColumnsInSelect = SQL_ORDER_BY_COLUMNS_IN_SELECT,
        ParameterArrayRowCounts = SQL_PARAM_ARRAY_ROW_COUNTS,
        ParameterArraySelects = SQL_PARAM_ARRAY_SELECTS, //    ProcedureTerm = SQL_PROCEDURE_TERM, 
        //    Procedures = SQL_PROCEDURES,
        //    PositionOperations = SQL_POS_OPERATIONS,
        //    QuotedIdentifierCase = SQL_QUOTED_IDENTIFIER_CASE, 
        //    RowUpdates = SQL_ROW_UPDATES,
        SchemaTerm = SQL_SCHEMA_TERM,
        SchemaUsage = SQL_SCHEMA_USAGE,
        //    ScrollOptions = SQL_SCROLL_OPTIONS,
        SearchPatternEscape = SQL_SEARCH_PATTERN_ESCAPE,
        ServerName = SQL_SERVER_NAME, 
        SpecialCharacters = SQL_SPECIAL_CHARACTERS, 
        SQLConformance = SQL_SQL_CONFORMANCE,
        StaticCursorAttributes1 = SQL_STATIC_CURSOR_ATTRIBUTES1,
        StaticCursorAttributes2 = SQL_STATIC_CURSOR_ATTRIBUTES2,
        //    StringFunctions = SQL_STRING_FUNCTIONS, 
        //    Subqueries = SQL_SUBQUERIES,
        //    SystemFunctions = SQL_SYSTEM_FUNCTIONS, 
        //    TableTerm = SQL_TABLE_TERM,
        //        TimedateAddIntervals = SQL_TIMEDATE_ADD_INTERVALS,
        //        TimedateDiffIntervals = SQL_TIMEDATE_DIFF_INTERVALS, 
        //        TimedateFunctions = SQL_TIMEDATE_FUNCTIONS, 
        TransactionCapabilities = SQL_TXN_CAPABLE, TransactionIsolationOptions
        = SQL_TXN_ISOLATION_OPTION, Union = SQL_UNION, UserName = SQL_USER_NAME,
}

//AsyncDBCFucntions = SQL_ASYNC_DBC_FUNCTIONS,
//ConcatNullBehavior = SQL_CONCAT_NULL_BEHAVIOR,
//ConvertFunctions = SQL_CONVERT_FUNCTIONS,
//CorrelationName = SQL_CORRELATION_NAME,
//CreateAssertion = SQL_CREATE_ASSERTION,
//CreateCharacterSet = SQL_CREATE_CHARACTER_SET,
//CreateDomain = SQL_CREATE_DOMAIN,
//CreateSchema = SQL_CREATE_SCHEMA,
//Createtable = SQL_CREATE_TABLE,
//CreateTranslation = SQL_CREATE_TRANSLATION,
//CreateView = SQL_CREATE_VIEW,
//DriverAwarePoolingSupported = SQL_DRIVER_AWARE_POOLING_SUPPORTED,
