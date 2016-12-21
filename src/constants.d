module dodbc.constants;

import dodbc.types;
import std.typecons : Tuple;

enum size_t max_dsn_length = SQL_MAX_DSN_LENGTH;
enum size_t max_option_string_length = SQL_MAX_OPTION_STRING_LENGTH;

/// SQL Defaults for various values
enum Defaults : size_t
{
    login_timeout = SQL_LOGIN_TIMEOUT_DEFAULT,
    query_timeout = SQL_QUERY_TIMEOUT_DEFAULT,
    max_rows = SQL_MAX_ROWS_DEFAULT,
    max_length = SQL_MAX_LENGTH_DEFAULT,
    rowset_size = SQL_ROWSET_SIZE_DEFAULT,
    keyset_size = SQL_KEYSET_SIZE_DEFAULT,
}

enum size_t default_login_timeout = SQL_LOGIN_TIMEOUT_DEFAULT;
enum size_t default_query_timeout = SQL_QUERY_TIMEOUT_DEFAULT;
enum size_t default_max_rows = SQL_MAX_ROWS_DEFAULT;
enum size_t default_max_length = SQL_MAX_LENGTH_DEFAULT;
enum size_t default_rowset_size = SQL_ROWSET_SIZE_DEFAULT;
enum size_t default_keyset_size = SQL_KEYSET_SIZE_DEFAULT;
// enum string default_trace_file = SQL_OPT_TRACE_FILE_DEFAULT;

/// SQL Return values / codes
enum SQLReturn : SQLRETURN
{
    Success = SQL_SUCCESS,
    SuccessWithInfo = SQL_SUCCESS_WITH_INFO,
    NoData = SQL_NO_DATA,
    Error = SQL_ERROR,
    InvalidHandle = SQL_INVALID_HANDLE,
    StillExecuting = SQL_STILL_EXECUTING,
    NeedData = SQL_NEED_DATA
}

enum HandleType : SQLSMALLINT
{
    Environment = SQL_HANDLE_ENV,
    Connection = SQL_HANDLE_DBC,
    Statement = SQL_HANDLE_STMT,
    Description = SQL_HANDLE_DESC,
}

enum EnvironmentAttributes : SQLINTEGER
{
    ODBCVersion = SQL_ATTR_ODBC_VERSION, // 200
    ConnectionPooling = SQL_ATTR_CONNECTION_POOLING, // 201
    ConnectionPoolMatch = SQL_ATTR_CP_MATCH, // 202
    NullTerminatedStrings = SQL_ATTR_OUTPUT_NTS,
}

enum ODBCVersion : SQLINTEGER
{
    v3 = SQL_OV_ODBC3, // 3UL
    v2 = SQL_OV_ODBC2, // 2UL
    v3_80 = 380UL, // SQL_OV_ODBC3_80, // 380UL
}

enum ConnectionPoolMatch : SQLUINTEGER
{
    StrictMatch = SQL_CP_STRICT_MATCH, // 0UL
    RelaxedMatch = SQL_CP_RELAXED_MATCH, // 1UL
    Default = StrictMatch
}

enum ConnectionPooling : SQLUINTEGER
{
    Off = 0UL, // SQL_CP_OFF, // OUL
    OnePerDriver = 1UL, // SQL_CP_ONE_PER_DRIVER, // 1UL
    OnePerEnvironment = 2UL, // SQL_CP_ONE_PER_HENV, // 2UL
    DriverAware,
    Default = OnePerDriver,
}

// dfmt off
enum ConnectionAttributes : SQLINTEGER
{
    AccessMode = SQL_ATTR_ACCESS_MODE, // 101
    Autocommit = SQL_ATTR_AUTOCOMMIT, // 102
    LoginTimeout = SQL_ATTR_LOGIN_TIMEOUT, // 103
    Trace = SQL_ATTR_TRACE, // 104
    Tracefile = SQL_ATTR_TRACEFILE, // 105
    TranslateLibrary = SQL_ATTR_TRANSLATE_LIB, // 106
    TranslateOption = SQL_ATTR_TRANSLATE_OPTION, // 107
    TransactionIsolation = SQL_ATTR_TXN_ISOLATION, // 108
    CurrentCatalog = SQL_ATTR_CURRENT_CATALOG, // 109
    ODBCCursors = SQL_ATTR_ODBC_CURSORS, // 110
    QuietMode = SQL_ATTR_QUIET_MODE, // 111
    PacketSize = SQL_ATTR_PACKET_SIZE, // 112
    ConnectionTimeout = SQL_ATTR_CONNECTION_TIMEOUT, // 113
    DisconnectBehavior = SQL_ATTR_DISCONNECT_BEHAVIOR, // 114
    ANSIApp = SQL_ATTR_ANSI_APP, // 115
    EnlistInDTC = SQL_ATTR_ENLIST_IN_DTC, // 1207
    EnlistInXA = SQL_ATTR_ENLIST_IN_XA, // 1208
    ConnectionDead = SQL_ATTR_CONNECTION_DEAD, // 1209
    ResetConnection = 116, // SQL_ATTR_RESET_CONNECTION, // 116
    AsyncDBCFunctionsEnable = 117, // SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE, // 117

    AsyncEnable = SQL_ATTR_ASYNC_ENABLE, 
    AutoIPD = SQL_ATTR_AUTO_IPD,

    MetadataID = SQL_ATTR_METADATA_ID,

    // AsyncDBCEvent = SQL_ATTR_ASYNC_DBC_EVENT,
    
    // AsyncDBCPcallback = SQL_ATTR_ASYNC_DBC_PCALLBACK,
    // AsyncDBCPcontext = SQL_ATTR_ASYNC_DBC_PCALLBACK,
    // DBCInfoToken = SQL_ATTR_DBC_INFO_TOKEN,
}
// dfmt on

enum AccessMode : SQLUINTEGER
{
    ReadWrite = SQL_MODE_READ_WRITE, // 0UL
    ReadOnly = SQL_MODE_READ_ONLY, // 1UL
}

enum AsyncEnable : SQLULEN
{
    Off = SQL_ASYNC_ENABLE_OFF,
    On = SQL_ASYNC_ENABLE_ON,
}

enum DisconnectBehavior
{
    ReturnToPool = 0UL, // SQL_DB_RETURN_TO_POOL, // 0UL
    Disconnect = 1UL, // SQL_DB_DISCONNECT, // 1UL
}

enum ODBCCursors : SQLULEN
{
    UseIfNeeded = SQL_CUR_USE_IF_NEEDED, // 0UL
    UseODBC = SQL_CUR_USE_ODBC, // 1UL
    UseDriver = SQL_CUR_USE_DRIVER, // 2UL
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
enum StatementAttributes : SQLINTEGER
{
    QueryTimeout = SQL_ATTR_QUERY_TIMEOUT, // 0
    MaxRows = SQL_ATTR_MAX_ROWS, // 1
    Noscan = SQL_ATTR_NOSCAN, // 2
    MaxLength = SQL_ATTR_MAX_LENGTH, // 3
    AsyncEnable = SQL_ATTR_ASYNC_ENABLE, // 4
    RowBindType = SQL_ATTR_ROW_BIND_TYPE, // 5
    CursorType = SQL_ATTR_CURSOR_TYPE, // 6
    Concurrency = SQL_ATTR_CONCURRENCY, // 7
    KeysetSize = SQL_ATTR_KEYSET_SIZE, // 8
    RowsetSize = SQL_ROWSET_SIZE, // 9
    SimulateCursor = SQL_ATTR_SIMULATE_CURSOR, // 10
    RetrieveData = SQL_ATTR_RETRIEVE_DATA, // 11
    UseBookmarks = SQL_ATTR_USE_BOOKMARKS, // 12
    GetBookmark = SQL_GET_BOOKMARK, // 13
    RowNumber = SQL_ATTR_ROW_NUMBER, // 14
    EnableAutoIPD = SQL_ATTR_ENABLE_AUTO_IPD, // 15
    FetchBookmarkPointer = SQL_ATTR_FETCH_BOOKMARK_PTR, // 16
    ParameterBindOffsetPointer = SQL_ATTR_PARAM_BIND_OFFSET_PTR, // 17
    ParameterBindType = SQL_ATTR_PARAM_BIND_TYPE, // 18
    ParameterOperationPointer = SQL_ATTR_PARAM_OPERATION_PTR, // 19
    ParameterStatusPointer = SQL_ATTR_PARAM_STATUS_PTR, // 20
    ParametesProcessedPointer = SQL_ATTR_PARAMS_PROCESSED_PTR, // 21
    ParametersetSize = SQL_ATTR_PARAMSET_SIZE, // 22
    BindOffsetPointer = SQL_ATTR_ROW_BIND_OFFSET_PTR, // 23
    RowOperationPointer = SQL_ATTR_ROW_OPERATION_PTR, // 24
    RowStatusPointer = SQL_ATTR_ROW_STATUS_PTR, // 25
    RowsFetchedPointer = SQL_ATTR_ROWS_FETCHED_PTR, // 26
    RowArraySize = SQL_ATTR_ROW_ARRAY_SIZE, // 27

    AppRowDescription = SQL_ATTR_APP_ROW_DESC, // 10010
    AppParamDescription = SQL_ATTR_APP_PARAM_DESC, // 10011
    ImportRowDescription = SQL_ATTR_IMP_ROW_DESC, // 10012
    ImportParamDescription = SQL_ATTR_IMP_PARAM_DESC, // 10013
    CursorScrollable = SQL_ATTR_CURSOR_SCROLLABLE, // (-1)
    CursorSensitivity = SQL_ATTR_CURSOR_SENSITIVITY, // (-2)
}
// dfmt on

alias CursorAttributes = StatementAttributes;

enum AttributeIs
{
    Pointer = SQL_IS_POINTER, // (-4)
    Uinteger = SQL_IS_UINTEGER, // (-5)
    Integer = SQL_IS_INTEGER, // (-6)
    Usmallint = SQL_IS_USMALLINT, // (-7)
    Smallint = SQL_IS_SMALLINT, // (-8)
}

enum CursorScrollable
{
    NonScrollable = SQL_NONSCROLLABLE, // 0
    Scrollable = SQL_SCROLLABLE, // 1
}

enum CursorSensitivity
{
    Unspecified = SQL_UNSPECIFIED, // 0
    Insensitive = SQL_INSENSITIVE, // 1
    Sensitive = SQL_SENSITIVE, // 2
}

enum SimulateCursor
{
    NonUnique = SQL_SC_NON_UNIQUE, // 0UL
    TryUnique = SQL_SC_TRY_UNIQUE, // 1UL
    Unique = SQL_SC_UNIQUE, // 2UL
}

enum UseBookmarks
{
    Off = SQL_UB_OFF, // 0UL
    On = SQL_UB_ON, // 01UL
    Variable = SQL_UB_VARIABLE, // 2UL
}

// dfmt off
enum DescriptorFields
{
    Count = SQL_DESC_COUNT, // 1001
    Type = SQL_DESC_TYPE, // 1002
    Length = SQL_DESC_LENGTH, // 1003
    OctetLengthPointer = SQL_DESC_OCTET_LENGTH_PTR, // 1004
    Precision = SQL_DESC_PRECISION, // 1005
    Scale = SQL_DESC_SCALE, // 1006
    DatetimeIntervalCode = SQL_DESC_DATETIME_INTERVAL_CODE, // 1007
    Nullable = SQL_DESC_NULLABLE, // 1008
    IndicatorPointer = SQL_DESC_INDICATOR_PTR, // 1009
    DataPointer = SQL_DESC_DATA_PTR, // 1010
    Name = SQL_DESC_NAME, // 1011
    Unnamed = SQL_DESC_UNNAMED, // 1012
    OctetLength = SQL_DESC_OCTET_LENGTH, // 1013
    AllocationType = SQL_DESC_ALLOC_TYPE, // 1099

    ArraySize = SQL_DESC_ARRAY_SIZE, // 20
    ArrayStatusPointer = SQL_DESC_ARRAY_STATUS_PTR, // 21
    AutoUniqueValue = SQL_DESC_AUTO_UNIQUE_VALUE, // 11
    BaseColumnName = SQL_DESC_BASE_COLUMN_NAME, // 22
    BaseTableName = SQL_DESC_BASE_TABLE_NAME, // 23
    BindOffsetPointer = SQL_DESC_BIND_OFFSET_PTR, // 24
    BindType = SQL_DESC_BIND_TYPE, // 25
    CaseSensitive = SQL_DESC_CASE_SENSITIVE, // 12
    CatalogName = SQL_DESC_CATALOG_NAME, // 17
    ConciseType = SQL_DESC_CONCISE_TYPE, // 2
    DatetimeIntervalPrecision = SQL_DESC_DATETIME_INTERVAL_PRECISION, // 26
    DisplaySize = SQL_DESC_DISPLAY_SIZE, // 6
    FixedPrecisionScale = SQL_DESC_FIXED_PREC_SCALE, // 9
    Label = SQL_DESC_LABEL, // 18
    LiteralPrefix = SQL_DESC_LITERAL_PREFIX, // 27
    LiteralSuffix = SQL_DESC_LITERAL_SUFFIX, // 28
    LocalTypeName = SQL_DESC_LOCAL_TYPE_NAME, // 29
    MaximumScale = SQL_DESC_MAXIMUM_SCALE, // 31
    MinimumScale = SQL_DESC_MINIMUM_SCALE, // 31
    NumericPrecisionRadix = SQL_DESC_NUM_PREC_RADIX, // 32
    ParameterType = SQL_DESC_PARAMETER_TYPE, // 33
    RowsProcessedPointer = SQL_DESC_ROWS_PROCESSED_PTR, // 34
    RowVersion = SQL_DESC_ROWVER, // 35
    SchemaName = SQL_DESC_SCHEMA_NAME, // 16
    Searchable = SQL_DESC_SEARCHABLE, // 13
    TypeName = SQL_DESC_TYPE_NAME, // 14
    TableName = SQL_DESC_TABLE_NAME, // 15
    Unsigned = SQL_DESC_UNSIGNED, // 8
    Updateable = SQL_DESC_UPDATABLE, // 10
}
// dfmt on

// dfmt off
enum DiagnosticsFields
{
    ReturnCode = SQL_DIAG_RETURNCODE, // 1
    Number = SQL_DIAG_NUMBER, // 2
    RowCount = SQL_DIAG_ROW_COUNT, // 3
    SQLState = SQL_DIAG_SQLSTATE, // 4
    Native = SQL_DIAG_NATIVE, // 5
    MessageText = SQL_DIAG_MESSAGE_TEXT, // 6
    DynamicFunction = SQL_DIAG_DYNAMIC_FUNCTION, // 7
    ClassOrigin = SQL_DIAG_CLASS_ORIGIN, // 8
    SubclassOrigin = SQL_DIAG_SUBCLASS_ORIGIN, // 9
    ConnectionName = SQL_DIAG_CONNECTION_NAME, // 10
    ServerName = SQL_DIAG_SERVER_NAME, // 11
    DynamicFunctionCode = SQL_DIAG_DYNAMIC_FUNCTION_CODE, // 12
    CursorRowCount = SQL_DIAG_CURSOR_ROW_COUNT, // (-1249)
    RowNumber = SQL_DIAG_ROW_NUMBER, // (-1248)
    ColumnNumber = SQL_DIAG_COLUMN_NUMBER, // (-1247)
}
// dfmt on

enum DiagnosticsRowNumber
{
    NoNumber = SQL_NO_ROW_NUMBER, // (-1)
    NumberUnknown = SQL_ROW_NUMBER_UNKNOWN, // (-2)
}

alias DiagnosticsColumnNumber = DiagnosticsRowNumber;

// dfmt off
enum DiagnosticsDynamicFunction
{
    AlterDomain = 3, // SQL_DIAG_ALTER_DOMAIN, // 3
    AlterTable = 4, // SQL_DAIG_ALTER_TABLE, // 4
    Call = 7, // SQL_DAIG_CALL, // 7
    CreateAssertion = 6, // SQL_DAIG_CREATE_ASSERTION, // 6
    CreateCharacterSet = 8, // SQL_DAIG_CREATE_CHARACTER_SET, // 8
    CreateCollation = 10, // SQL_DAIG_CREATE_COLLATION, // 10
    CreateDomain = 23, // SQL_DAIG_CREATE_DOMAIN, // 23
    CreateIndex = (-1), // SQL_DAIG_CREATE_INDEX, // (-1)
    CreateSchema = 64, // SQL_DAIG_CREATE_SCHEMA, // 64
    CreateTable = 77, // SQL_DAIG_CREATE_TABLE, // 77
    CreateTranslation = 79, // SQL_DAIG_CREATE_TRANSLATION, // 79
    CreateView = 84, // SQL_DAIG_CREATE_VIEW, // 84
    DeleteWhere = 19, // SQL_DAIG_DELETE_WHERE, // 19
    DropAssertion = 24, // SQL_DAIG_DROP_ASSERTION, // 24
    DropCharacterSet = 25, // SQL_DAIG_DROP_CHARACTER_SET, // 25
    DropCollation = 26, // SQL_DAIG_DROP_COLLATION, // 26
    DropDomain = 27, // SQL_DAIG_DROP_DOMAIN, // 27
    DropIndex = (-2), // SQL_DAIG_DROP_INDEX, // (-2)
    DropSchema = 31, // SQL_DAIG_DROP_SCHEMA, // 31
    DropTable = 32, // SQL_DAIG_DROP_TABLE, // 32
    DropTranslation = 33, // SQL_DAIG_DROP_TRANSLATION, // 33
    DropView = 36, // SQL_DAIG_DROP_VIEW, // 36
    DynamicDeleteCursor = 38, // SQL_DAIG_DYNAMIC_DELETE_CURSOR, // 38
    DynamicUpdateCursor = 81, // SQL_DAIG_DYNAMIC_UPDATE_CURSOR, // 81
    Grant = 48, // SQL_DAIG_GRANT, // 48
    Insert = 50, // SQL_DAIG_INSERT, // 50
    Revoke = 59, // SQL_DAIG_REVOKE, // 59
    SelectCursor = 85, // SQL_DAIG_SELECT_CURSOR, // 85
    UnknownStatement = 0, // SQL_DAIG_UNKNOWN_STATEMENT, // 0
    UpdateWhere = 82, // SQL_DAIG_UPDATE_WHERE, // 82
}
// dfmt on

enum SQLType
{
    Unknown = SQL_UNKNOWN_TYPE, // 0

    TinyInteger = SQL_TINYINT, // (-6)
    SmallInteger = SQL_SMALLINT, // 5
    Integer = SQL_INTEGER, // 4
    BigInteger = SQL_BIGINT, // (-5)

    Numeric = SQL_NUMERIC, // 2
    Decimal = SQL_DECIMAL, // 3

    Float = SQL_FLOAT, // 6
    Double = SQL_DOUBLE, // 8
    Real = SQL_REAL, // 7

    Char = SQL_CHAR, // 1
    Varchar = SQL_VARCHAR, // 12
    LongVarchar = SQL_LONGVARCHAR, // (-1)
    Unicode = SQL_UNICODE, //SQL_WCHAR, //SQL_UNICODE
    UnicodeVarchar = SQL_UNICODE_VARCHAR, //SQL_WVARCHAR, //SQL_UNICODE_VARCHAR
    UnicodeLongvarchar = SQL_UNICODE_LONGVARCHAR, //SQL_WLONGVARCHAR, //SQL_UNICODE_LONGVARCHAR
    UnicodeChar = SQL_UNICODE_CHAR, //SQL_WCHAR, //SQL_UNICODE_CHAR

    // Date = SQL_DATE, // 9
    // Time = SQL_TIME, // 10
    // Datetime = SQL_DATETIME, // 9
    // Timestamp = SQL_TIMESTAMP, // 11
    Date = SQL_TYPE_DATE, // 91
    Time = SQL_TYPE_TIME, // 92
    Timestamp = SQL_TYPE_TIMESTAMP, // 93

    Interval = SQL_INTERVAL, // 10

    Binary = SQL_BINARY, // (-2)
    Varbinary = SQL_VARBINARY, // (-3)
    LongVarbinary = SQL_LONGVARBINARY, // (-4)

    Bit = SQL_BIT, // (-7)
    GUID = SQL_GUID, // (-11)
    Null = SQL_TYPE_NULL,
}

//alias ODBCDataType = SQLType;

version (X86)
{
    private enum p_Bookmark = SQL_C_BOOKMARK; // SQL_C_UBIGINT,
}
else
{
    private enum p_Bookmark = SQL_C_UBIGINT; // SQL_C_UBIGINT,
}

enum LocalType
{
    Default = SQL_C_DEFAULT, // 99
    GUID = SQL_C_GUID, // SQL_GUID
    Null = SQL_TYPE_NULL,
    Char = SQL_C_CHAR, // SQL_CHAR (SQL Types: CHAR, VARCHAR, DECIMAL, NUMERIC)
    Long = SQL_C_LONG, // SQL_INTEGER (INTEGER)
    Short = SQL_C_SHORT, // SQL_SMALLINT (SMALLINT)
    Float = SQL_REAL, // SQL_C_REAL, // SQL_REAL (REAL)
    Double = SQL_C_DOUBLE, // SQL_DOUBLE (FLOAT, DOUBLE)
    Numeric = SQL_C_NUMERIC, // SQL_NUMERIC
    SignedOffset = SQL_SIGNED_OFFSET, // (-20)
    UnsignedOffset = SQL_UNSIGNED_OFFSET, // (-22)
    Date = SQL_C_DATE, // SQL_DATE
    Time = SQL_C_TIME, // SQL_TIME
    Timestamp = SQL_C_TIMESTAMP, // SQL_TIMESTAMP
    DateType = SQL_C_TYPE_DATE, // SQL_TYPE_DATE
    TimeType = SQL_C_TYPE_TIME, // SQL_TYPE_TIME
    TimestampType = SQL_C_TYPE_TIMESTAMP, // SQL_TYPE_TIMESTAMP
    IntervalYear = SQL_C_INTERVAL_YEAR, // SQL_INTERVAL_YEAR
    IntervalMonth = SQL_C_INTERVAL_MONTH, // SQL_INTERVAL_MONTH
    IntervalDay = SQL_C_INTERVAL_DAY, // SQL_INTERVAL_DAY
    IntervalHour = SQL_C_INTERVAL_HOUR, // SQL_INTERVAL_HOUR
    IntervalMinute = SQL_C_INTERVAL_MINUTE, // SQL_INTERVAL_MINUTE
    IntervalSecond = SQL_C_INTERVAL_SECOND, // SQL_INTERVAL_SECOND
    IntervalYearToMonth = SQL_C_INTERVAL_YEAR_TO_MONTH, // SQL_INTERVAL_YEAR_TO_MONTH
    IntervalDayToHour = SQL_C_INTERVAL_DAY_TO_HOUR, // SQL_INTERVAL_DAY_TO_HOUR
    IntervalDayToMinute = SQL_C_INTERVAL_DAY_TO_MINUTE, // SQL_INTERVAL_DAY_TO_MINUTE
    IntervalDayToSecond = SQL_C_INTERVAL_DAY_TO_SECOND, // SQL_INTERVAL_DAY_TO_SECOND
    IntervalHourToMinute = SQL_C_INTERVAL_HOUR_TO_MINUTE, // SQL_INTERVAL_HOUR_TO_MINUTE
    IntervalHourToSecond = SQL_C_INTERVAL_HOUR_TO_SECOND, // SQL_INTERVAL_HOUR_TO_SECOND
    IntervalMinuteToSecond = SQL_C_INTERVAL_MINUTE_TO_SECOND, // SQL_INTERVAL_MINUTE_TO_SECOND
    Binary = SQL_C_BINARY, // SQL_BINARY
    Bit = SQL_C_BIT, // SQL_BIT
    SignedBigint = SQL_C_SBIGINT, // (SQL_BIGINT + SQL_SIGNED_OFFSET) - SIGNED BIGINT
    UnsignedBigint = SQL_C_UBIGINT, // (SQL_BIGINT + SQL_UNSIGNED_OFFSET) - UNSIGNED BIGINT
    Tinyint = SQL_C_TINYINT, // SQL_TINYINT
    SignedLong = SQL_C_SLONG, // (SQL_C_LONG + SQL_SIGNED_OFFSET) - SIGNED INTEGER
    SignedShort = SQL_C_SSHORT, // (SQL_C_SHORT + SQL_SIGNED_OFFSET) - SIGNED_SHORT
    SignedTinyint = SQL_C_STINYINT, // (SQL_TINYINT + SQL_SIGNED_OFFSET) - SIGNED TINYINT
    UnsignedLong = SQL_C_ULONG, // (SQL_C_LONG + SQL_UNSIGNED_OFFSET) - UNSIGNED INTEGER
    UnsignedShort = SQL_C_USHORT, // (SQL_C_SHORT + SQL_UNSIGNED_OFFSET) - UNSIGNED SHORT
    UnsignedTinyint = SQL_C_UTINYINT, // (SQL_TINYINT + SQL_UNSIGNED_OFFSET) - UNSIGNED TINYINT
    Bookmark = p_Bookmark,
    Varbookmark = SQL_C_BINARY,
}

//alias LocalDataType = LocalType;

//struct Buffer(SQLType st, LocalType lt)
//{
//    public enum sql_enum = st;
//    public enum local_enum = lt;
//    public alias buffer_type = ubyte[];
//    public alias local_type = ubyte[];
//}

enum IntervalType
{
    Year = SQL_INTERVAL_YEAR, // 101
    Month = SQL_INTERVAL_MONTH, // 102
    Day = SQL_INTERVAL_DAY, // 103
    Hour = SQL_INTERVAL_HOUR, // 104
    Minute = SQL_INTERVAL_MINUTE, // 105
    Second = SQL_INTERVAL_SECOND, // 106
    YearToMonth = SQL_INTERVAL_YEAR_TO_MONTH, // 107
    DayToHour = SQL_INTERVAL_DAY_TO_HOUR, // 108
    DayToMinute = SQL_INTERVAL_DAY_TO_MINUTE, // 109
    DayToSecond = SQL_INTERVAL_DAY_TO_SECOND, // 110
    HourToMinute = SQL_INTERVAL_HOUR_TO_MINUTE, // 111
    HourToSecond = SQL_INTERVAL_HOUR_TO_SECOND, // 112
    MinuteToSecond = SQL_INTERVAL_MINUTE_TO_SECOND, // 113
}

enum Concurrency : SQLULEN
{
    ReadOnly, // = SQL_CONCUR_READ_ONLY,
    Lock, // = SQL_CONCUR_LOCK,
    RowVersion, // = SQL_CONCUR_ROWVER,
    Values, // = SQL_CONCUR_VALUES,
}

enum FreeStatement : SQLUSMALLINT
{
    Close = SQL_CLOSE,
    Drop = SQL_DROP,
    Unbind = SQL_UNBIND,
    ResetParams = SQL_RESET_PARAMS,
}

// dfmt off
enum InfoType // SQLGetInfo
{
    AccessibleProcedures = SQL_ACCESSIBLE_PROCEDURES, // 
    AccessibleTables = SQL_ACCESSIBLE_TABLES, // 
    ActiveEnvironments = SQL_ACTIVE_ENVIRONMENTS, // 116
    ActiveConnections = 0, // SQL_ACTIVE_CONNECTIONS, // 0 -- MAX_DRIVER_CONNECTIONS
    ActiveStatements = 1, // SQL_ACTIVE_STATEMENTS, // 1 -- MAX_CONCURRENT_ACTIVITIES
    AggregateFunctions = SQL_AGGREGATE_FUNCTIONS, // 169

    AlterTable = SQL_ALTER_TABLE, // 
    AlterDomain = SQL_ALTER_DOMAIN, // 117

    AsyncMode = SQL_ASYNC_MODE, // 10021
    AsyncDBCFunctions = 10023, // SQL_ASYNC_DBC_FUNCTIONS, // 10023

    BatchRowCount = SQL_BATCH_ROW_COUNT, // 120
    BatchSupport = SQL_BATCH_SUPPORT, // 121
    BookmarkPersistence = 82, // SQL_BOOKMARK_PERSISTENCE, // 82

    CatalogLocation = SQL_CATALOG_LOCATION, // SQL_QUALIFIER_LOCATION
    CatalogNameSeparator = SQL_CATALOG_NAME_SEPARATOR, // SQL_QUALIFIER_NAME_SEPARATOR
    CatalogTerm = SQL_CATALOG_TERM, // SQL_QUALIFIER_TERM
    CatalogUsage = SQL_CATALOG_USAGE, // SQL_QUALIFIER_USAGE
    CatalogName = SQL_CATALOG_NAME, // 10003

    ColumnAlias = 87, // SQL_COLUMN_ALIAS, // 87
    ConcatNullBehavior = 22, // SQL_CONCAT_NULL_BEHAVIOR, // 22
    CorrelationName = 74, // SQL_CORRELATION_NAME, // 74
    CollationSequence = SQL_COLLATION_SEQ,

    ConvertFunctions = 48, // SQL_CONVERT_FUNCTIONS, // 48
    ConvertBigint = 53, // SQL_CONVERT_BIGINT, // 53
    ConvertBinary = 54, // SQL_CONVERT_BINARY, // 54
    ConvertBit = 55, // SQL_CONVERT_BIT, // 55
    ConvertChar = 56, // SQL_CONVERT_CHAR, // 56
    ConvertDate = 57, // SQL_CONVERT_DATE, // 57
    ConvertDecimal = 58, // SQL_CONVERT_DECIMAL, // 58
    ConvertDouble = 59, // SQL_CONVERT_DOUBLE, // 59
    ConvertFloat = 60, // SQL_CONVERT_FLOAT, // 60
    ConvertGUID = 173, /// SQL_CONVERT_GUID, // 173
    ConvertInteger = 61, // SQL_CONVERT_INTEGER, // 61
    ConvertLongvarchar = 62, // SQL_CONVERT_LONGVARCHAR, // 62
    ConvertNumeric = 63, // SQL_CONVERT_NUMERIC, // 63
    ConvertReal = 64, // SQL_CONVERT_REAL, // 64
    ConvertSmallint = 65, // SQL_CONVERT_SMALLINT, // 65
    ConvertTime = 66, // SQL_CONVERT_TIME, // 66
    ConvertTimestamp = 67, // SQL_CONVERT_TIMESTAMP, // 67
    ConvertTinyint = 68, // SQL_CONVERT_TINYINT, // 68
    ConvertVarbinary = 69, // SQL_CONVERT_VARBINARY, // 69
    ConvertVarchar = 70, // SQL_CONVERT_VARCHAR, // 70
    ConvertLongvarbinary = 71, // SQL_CONVERT_LONGVARBINARY, // 71
    ConvertWchar = SQL_CONVERT_WCHAR, // 122
    ConvertIntervalDayTime = SQL_CONVERT_INTERVAL_DAY_TIME, // 123
    ConvertIntervalYearMonth = SQL_CONVERT_INTERVAL_YEAR_MONTH, // 124
    ConvertWlongvarchar = SQL_CONVERT_WLONGVARCHAR, // 125
    ConvertWvarchar = SQL_CONVERT_WVARCHAR, // 126

    CreateAssertion = SQL_CREATE_ASSERTION, // 127  
    CreateCharacterSet = SQL_CREATE_CHARACTER_SET, // 128
    CreateDomain = SQL_CREATE_DOMAIN, // 130
    CreateSchema = SQL_CREATE_SCHEMA, // 131
    Createtable = SQL_CREATE_TABLE, // 132
    CreateTranslation = SQL_CREATE_TRANSLATION, // 133
    CreateView = SQL_CREATE_VIEW, // 134

    CursorCommitBehavior = SQL_CURSOR_COMMIT_BEHAVIOR, // 
    CursorSensitivity = SQL_CURSOR_SENSITIVITY, // 
    CursorRollbackBehavior = 24, // SQL_CURSOR_ROLLBACK_BEHAVIOR, // 24

    DataSourceName = SQL_DATA_SOURCE_NAME, // 
    DataSourceReadOnly = SQL_DATA_SOURCE_READ_ONLY, // 
    DatetimeLiterals = SQL_DATETIME_LITERALS, // 119

    DBMSName = SQL_DBMS_NAME, // 
    DBMSVersion = SQL_DBMS_VER, DDLIndex = SQL_DDL_INDEX, // 170 
    DefaultTransactionIsolation = SQL_DEFAULT_TXN_ISOLATION, // 
    DescribeParameter = SQL_DESCRIBE_PARAMETER, DMVersion = SQL_DM_VER, // 171

    DriverConnection = 3, // SQL_DRIVER_HDBC, // 3
    DriverEnvironment = 4, // SQL_DRIVER_HENV, // 4
    DriverLibraryHandle = 76, // SQL_DRIVER_HLIB, // 76
    DriverODBCVersion = 77, // SQL_DRIVER_ODBC_VER, // 77
    DriverStatement = 5, // SQL_DRIVER_HSTMT, // 5
    DriverName = 6, // SQL_DRIVER_NAME, // 6
    DriverVersion = 7, // SQL_DRIVER_VER, // 7

    DropAssertion = SQL_DROP_ASSERTION, // 136
    DropCharacterSet = SQL_DROP_CHARACTER_SET, // 137
    DropCollation = SQL_DROP_COLLATION, // 138
    DropDomain = SQL_DROP_DOMAIN, // 139
    DropSchema = SQL_DROP_SCHEMA, // 140
    DropTable = SQL_DROP_TABLE, // 141
    DropTranslation = SQL_DROP_TRANSLATION, // 142
    DropView = SQL_DROP_VIEW, // 143

    DynamicCursorAttributes1 = SQL_DYNAMIC_CURSOR_ATTRIBUTES1, // 144
    DynamicCursorAttributes2 = SQL_DYNAMIC_CURSOR_ATTRIBUTES2, // 145

    ExpressionsInOrderBy = 27, // SQL_EXPRESSIONS_IN_ORDERBY, // 27

    FileUsage = 84, // SQL_FILE_USAGE, // 84
    ForwardOnlyCursorAttributes1 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1, // 146
    ForwardOnlyCursorAttributes2 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2, // 147

    GetDataExtensions = SQL_GETDATA_EXTENSIONS, // 
    GroupBy = 88, // SQL_GROUP_BY, // 88

    IdentifierCase = SQL_IDENTIFIER_CASE, // 
    IdentifierQuoteChar = SQL_IDENTIFIER_QUOTE_CHAR, // 
    IndexKeywords = 148, // SQL_INDEX_KEYWORKDS, // 148
    InformationSchemaViews = SQL_INFO_SCHEMA_VIEWS, // 149
    InsertStatement = SQL_INSERT_STATEMENT, // 172
    Integrity = SQL_INTEGRITY, // 73 

    Keywords = 89, // SQL_KEYWORDS, // 89 
    KeysetCursorAttributes1 = SQL_KEYSET_CURSOR_ATTRIBUTES1, // 150
    KeysetCursorAttributes2 = SQL_KEYSET_CURSOR_ATTRIBUTES2, // 151

    LikeEscapeClause = 113, // SQL_LIKE_ESCAPE_CLAUSE, // 113
    LockTypes = 78, // SQL_LOCK_TYPES, // 78

    MaxBinaryLiteralLength = 112, // SQL_MAX_BINARY_LITERAL_LEN, // 112
    MaxCharacterLiteralsLength = 108, // SQL_MAX_CHAR_LITERAL_LEN, // 108
    MaxRowSizeIncludesLong = 103, // SQL_MAX_ROW_SIZE_INCLUDES_LONG, // 103
    MaxOwnerNameLength = 32, // SQL_MAX_OWNER_NAME_LEN, // 32 -- MAX_SCHEMA_NAME_LEN
    MaxSchemaNameLength = SQL_MAX_SCHEMA_NAME_LEN, // SQL_MAX_OWNER_NAME_LEN
    MaxProcedureNameLength = 33, // SQL_MAX_PROCEDURE_NAME_LEN, // 33
    MaxQualifierNameLength = 34, // SQL_MAX_QUALIFIER_NAME_LEN, // 34 -- MAX_CATALOG_NAME_LEN

    MaxAsyncConcurrentStatements = SQL_MAX_ASYNC_CONCURRENT_STATEMENTS, // 10022
    // MaxColumnsInGroupBy = SQL_MAX_COLUMNS_IN_GROUP_BY, // 
    // MaxColumnsInIndex = SQL_MAX_COLUMNS_IN_INDEX, // 
    // MaxColumnsInOrderBy = SQL_MAX_COLUMNS_IN_ORDER_BY, // 
    // MaxColumnsInSelect = SQL_MAX_COLUMNS_IN_SELECT, // 
    // MaxColumnsInTable = SQL_MAX_COLUMNS_IN_TABLE, // 
    // MaxConcurrentActivities = SQL_MAX_CONCURRENT_ACTIVITIES, // 
    // MaxDriverConnections = SQL_MAX_DRIVER_CONNECTIONS, // 
    // MaxIndexSize = SQL_MAX_INDEX_SIZE,  // 
    // MaxRowSize = SQL_MAX_ROW_SIZE, // 
    // MaxBinaryLiteralLength = SQL_MAX_BINARY_LITERAL_LENGTH, // 
    // MaxCatalogNameLength = SQL_MAX_CATALOG_NAME_LENGTH, // 
    // MaxCharLiteralLength = SQL_MAX_CHAR_LITERAL_LENGTH, // 
    // MaxColumnNameLength = SQL_MAX_COLUMN_NAME_LENGTH, // 
    // MaxCursorNameLength = SQL_MAX_CURSOR_NAME_LENGTH, // 
    // MaxIdentifierLength = SQL_MAX_IDENTIFIER_LENGTH, // 
    // MaxStatementLength = SQL_MAX_STATEMENT_LEN,  // 
    // MaxTableNameLength = SQL_MAX_TABLE_NAME_LEN, // 
    // MaxTablesInSelect = SQL_MAX_TABLES_IN_SELECT, // 
    // MaxUserNameLength = SQL_MAX_USER_NAME_LEN, // 

    MultipleResultSets = 36, // SQL_MULT_RESULT_SETS, // 36
    MultipleActiveTransactions = 37, // SQL_MULTIPLE_ACTIVE_TXN, // 37

    NeedLongDataLength = 111, // SQL_NEED_LONG_DATA_LEN, // 111
    NonNullableColumns = 75, // SQL_NON_NULLABLE_COLUMNS, // 75
    NullCollation = SQL_NULL_COLLATION, // 
    NumericFunctions = 49, // SQL_NUMERIC_FUNCTIONS, // 49

    ODBC_SAG_CLI_Conformance = 15, // SQL_ODBC_SAG_CLI_CONFORMANCE, // 15
    ODBCApiConformance = 9, // SQL_ODBC_API_CONFORMANCE, // 9
    ODBCInterfaceConformance = SQL_ODBC_INTERFACE_CONFORMANCE, // 152
    ODBCVersion = 10, // SQL_ODBC_VER, // 10
    OuterJoinCapabilities = SQL_OJ_CAPABILITIES, // 65003
    OuterJoins = 38, // SQL_OUTER_JOINS, // 38
    OrderByColumnsInSelect = SQL_ORDER_BY_COLUMNS_IN_SELECT,
    OwnerTerm = SQL_OWNER_TERM, // 39
    OwnerUsage = SQL_OWNER_USAGE, // 91

    ParameterArrayRowCounts = SQL_PARAM_ARRAY_ROW_COUNTS, // 153
    ParameterArraySelects = SQL_PARAM_ARRAY_SELECTS, // 154
    PositionedStatements = 80, // SQL_POSITIONED_STATEMENTS, // 80
    Procedures = 21, // SQL_PROCEDURES, // 21
    ProcedureTerm = 40, // SQL_PROCEDURE_TERM, // 40

    QualifierLocation = SQL_QUALIFIER_LOCATION, // 114
    QualifierNameSeparator = SQL_QUALIFIER_NAME_SEPARATOR, // 41
    QualifierTerm = SQL_QUALIFIER_TERM, // 42
    QualifierUsage = SQL_QUALIFIER_USAGE, // 92
    QuotedIdentifierCase = 93, // SQL_QUOTED_IDENTIFIER_CASE, // 93

    RowUpdates = 11, // SQL_ROW_UPDATES, // 11

    SchemaTerm = SQL_SCHEMA_TERM, // SQL_OWNER_TERM 
    SchemaUsage = SQL_SCHEMA_USAGE, // SQL_OWNER_USAGE
    ScrollOptions = 44, // SQL_SCROLL_OPTIONS, // 44
    SearchPatternEscape = SQL_SEARCH_PATTERN_ESCAPE, // 
    ServerName = SQL_SERVER_NAME, // 
    SetPositionOperations = 79, // SQL_POS_OPERATIONS, // 79
    SpecialCharacters = SQL_SPECIAL_CHARACTERS, // 
    SQLConformance = 118, // SQL_SQL_CONFORMANCE, // 118
    StaticSensitivity = 83, // SQL_STATIC_SENSITIVITY, // 83
    StaticCursorAttributes1 = SQL_STATIC_CURSOR_ATTRIBUTES1, // 167
    StaticCursorAttributes2 = SQL_STATIC_CURSOR_ATTRIBUTES2, // 168  
    StringFunctions = 50, // SQL_STRING_FUNCTIONS, // 50
    Subqueries = 95, // SQL_SUBQUERIES, // 95
    SystemFunctions = 51, // SQL_SYSTEM_FUNCTIONS, // 51

    TableTerm = 45, // SQL_TABLE_TERM, // 45
    TimeDateAddIntervals = 109, // SQL_TIMEDATE_ADD_INTERVALS, // 109
    TimeDateDiffIntervals = 110, // SQL_TIMEDATE_DIFF_INTERVALS, // 110
    TimeDateFunctions = 52, // SQL_TIMEDATE_FUNCTIONS, // 52
    TransactionCapabilities = SQL_TXN_CAPABLE, // 
    TransactionIsolationOptions = SQL_TXN_ISOLATION_OPTION, // 

    Union = SQL_UNION, // 96
}
// dfmt on

enum AlterTableBitmasks
{
    AddColumnSingle = SQL_AT_ADD_COLUMN_SINGLE, // 0x00000020L
    AddColumnDefault = SQL_AT_ADD_COLUMN_DEFAULT, // 0x00000040L
    AddColumnCollation = SQL_AT_ADD_COLUMN_COLLATION, // 0x00000080L
    SetColumnDefault = SQL_AT_SET_COLUMN_DEFAULT, // 0x00000100L
    DropColumnDefault = SQL_AT_DROP_COLUMN_DEFAULT, // 0x00000200L
    DropColumnCascade = SQL_AT_DROP_COLUMN_CASCADE, // 0x00000400L
    DropColumnRestrict = SQL_AT_DROP_COLUMN_RESTRICT, // 0x00000800L
    AddTableConstraint = SQL_AT_ADD_TABLE_CONSTRAINT, // 0x00001000L
    DropTableConstraintCascade = SQL_AT_DROP_TABLE_CONSTRAINT_CASCADE, // 0x00002000L
    DropTableConstraintRestrict = SQL_AT_DROP_TABLE_CONSTRAINT_RESTRICT, // 0x00004000L
    ConstraintNameDefinition = SQL_AT_CONSTRAINT_NAME_DEFINITION, // 0x00008000L
    ConstraintInitiallyDeferred = SQL_AT_CONSTRAINT_INITIALLY_DEFERRED, // 0x00010000L
    ConstraintInitiallyImmediate = SQL_AT_CONSTRAINT_INITIALLY_IMMEDIATE, // 0x00020000L
    ConstraintDeferrable = SQL_AT_CONSTRAINT_DEFERRABLE, // 0x00040000L
    ConstraintNonDeferrable = SQL_AT_CONSTRAINT_NON_DEFERRABLE, // 0x00080000L
}

// dfmt off
alias AlterTableCapabilities = Tuple!(
    immutable(bool), "AddColumSingle", 
    immutable(bool), "AddColumnDefault",
    immutable(bool), "AddColumnCollation", 
    immutable(bool), "SetColumnDefault", 
    immutable(bool), "DropColumnDefault",
    immutable(bool), "DropColumnCascade", 
    immutable(bool), "DropColumnRestrict", 
    immutable(bool), "AddTableConstraint",
    immutable(bool), "DropTableConstraintClause", 
    immutable(bool), "DropTableConstraintRestrict", 
    immutable(bool), "ConstraintNameDefinition",
    immutable(bool), "ConstraintInitiallyDeferred", 
    immutable(bool), "ConstraintInitiallyImmediate",
    immutable(bool), "ConstraintDeferrable", 
    immutable(bool), "ConstraintNonDeferrable"
);
// dfmt on

enum ConvertBitmask
{
    Char = SQL_CVT_CHAR, // 0x00000001L
    Numeric = SQL_CVT_NUMERIC, // 0x00000002L
    Decimal = SQL_CVT_DECIMAL, // 0x00000004L
    Integer = SQL_CVT_INTEGER, // 0x00000008L
    Smallint = SQL_CVT_SMALLINT, // 0x00000010L
    Float = SQL_CVT_FLOAT, // 0x00000020L
    Real = SQL_CVT_REAL, // 0x00000040L
    Double = SQL_CVT_DOUBLE, // 0x00000080L
    Varchar = SQL_CVT_VARCHAR, // 0x00000100L
    Longvarchar = SQL_CVT_LONGVARCHAR, // 0x00000200L
    Binary = SQL_CVT_BINARY, // 0x00000400L
    Varbinary = SQL_CVT_VARBINARY, // 0x00000800L
    Bit = SQL_CVT_BIT, // 0x00001000L
    Tinyint = SQL_CVT_TINYINT, // 0x00002000L
    Bigint = SQL_CVT_BIGINT, // 0x00004000L
    Date = SQL_CVT_DATE, // 0x00008000L
    Time = SQL_CVT_TIME, // 0x00010000L
    Timestamp = SQL_CVT_TIMESTAMP, // 0x00020000L
    Longvarbinary = SQL_CVT_LONGVARBINARY, // 0x00040000L
    IntervalYearMonth = SQL_CVT_INTERVAL_YEAR_MONTH, // 0x00080000L
    IntervalDayTime = SQL_CVT_INTERVAL_DAY_TIME, // 0x00100000L
    Wchar = SQL_CVT_WCHAR, // 0x00200000L
    Wlongvarchar = SQL_CVT_WLONGVARCHAR, // 0x00400000L
    Wvarchar = SQL_CVT_WVARCHAR, // 0x00800000L
    GUID = 0x01000000L, // SQL_CVT_GUID, // 0x01000000L
}

// dfmt off
alias ConvertCapabilities = Tuple!(
    immutable(bool), "Char", 
    immutable(bool), "Numeric",
    immutable(bool), "Decimal", 
    immutable(bool), "Integer", 
    immutable(bool), "Smallint",
    immutable(bool), "Float", 
    immutable(bool), "Real", 
    immutable(bool), "Double",
    immutable(bool), "Varchar", 
    immutable(bool), "Longvarchar", 
    immutable(bool), "Binary",
    immutable(bool), "Bit", 
    immutable(bool), "Tinyint",
    immutable(bool), "Bigint", 
    immutable(bool), "Date", 
    immutable(bool), "Time", 
    immutable(bool), "Timestamp", 
    immutable(bool), "Longvarbinary", 
    immutable(bool), "IntervalYearMonth", 
    immutable(bool), "IntervalDayTime", 
    immutable(bool), "Wchar", 
    immutable(bool), "Wlongvarchar", 
    immutable(bool), "Wvarchar", 
    immutable(bool), "GUID"
);
// dfmt on

enum BindParameterTypes // SQLBindParameter
{
    DefaultParameter = SQL_DEFAULT_PARAM, // (-5)
    Ignore = SQL_IGNORE, // (-6)
}

enum data_length_at_execution_offset = SQL_LEN_DATA_AT_EXEC_OFFSET; // (-100)

T data_length_at_execution(T)(T length)
{
    return ((-length) + data_length_at_execution_offset);
}

enum ColumnAttributes : SQLUSMALLINT
{
    Count = SQL_COLUMN_COUNT, // 0
    Name = SQL_COLUMN_NAME, // 1
    Type = SQL_COLUMN_TYPE, // 2
    Length = SQL_COLUMN_LENGTH, // 3
    Precision = SQL_COLUMN_PRECISION, // 4
    Scale = SQL_COLUMN_SCALE, // 5
    DisplaySize = SQL_COLUMN_DISPLAY_SIZE, // 6 
    Nullable = SQL_COLUMN_NULLABLE, // 7
    Unsigned = SQL_COLUMN_UNSIGNED, // 8 
    Money = SQL_COLUMN_MONEY, // 9
    Updatable = SQL_COLUMN_UPDATABLE, // 10
    AutoIncrement = SQL_COLUMN_AUTO_INCREMENT, // 11
    CaseSensitive = SQL_COLUMN_CASE_SENSITIVE, // 12
    Searchable = SQL_COLUMN_SEARCHABLE, // 13
    TypeName = SQL_COLUMN_TYPE_NAME, // 14
    TableName = SQL_COLUMN_TABLE_NAME, // 15
    OwnerName = SQL_COLUMN_OWNER_NAME, // 16
    QualifierName = SQL_COLUMN_QUALIFIER_NAME, // 17 
    Label = SQL_COLUMN_LABEL, // 18
    CollationOptionsMax = SQL_COLATT_OPT_MAX, // SQL_COLUMN_LABEL
    CollationOptionsMin = SQL_COLATT_OPT_MIN, // SQL_COLUMN_COUNT
}

enum Updatable
{
    ReadOnly = SQL_ATTR_READONLY, // 0
    Write = SQL_ATTR_WRITE, // 1
    ReadWriteUnknown = SQL_ATTR_READWRITE_UNKNOWN, // 2
}

enum Searchable : SQLSMALLINT
{
    Unsearchable = SQL_PRED_NONE, // SQL_UNSEARCHABLE // 0
    LikeOnly = SQL_PRED_CHAR, // SQL_LIKE_ONLY // 1
    AllExceptLike = SQL_PRED_BASIC, // SQL_ALL_EXCEPT_LIKE // 2
    Searchable = SQL_SEARCHABLE, // 3
}

//enum Searchable // SQLColAttributes & SQLGetInfo
//{
//    Unsearchable = SQL_UNSEARCHABLE, // 0
//    LikeOnly = SQL_LIKE_ONLY, // 1
//    AllExceptLike = SQL_ALL_EXCEPT_LIKE, // 2
//    Searchable = SQL_SEARCHABLE, // 3
//}

enum SetPosition
{
    // Defines
    EntireRowset = SQL_ENTIRE_ROWSET, // 0

    // Operations
    Position = SQL_POSITION, // 0
    Refresh = SQL_REFRESH, // 1
    Update = SQL_UPDATE, // 2
    Delete = SQL_DELETE, // 3

    // Lock Options
    LockNoChange = SQL_LOCK_NO_CHANGE, // 0
    LockExclusive = SQL_LOCK_EXCLUSIVE, // 1
    LockUnlock = SQL_LOCK_UNLOCK, // 2
}

// /* Macros for SQLSetPos */
//#define SQL_POSITION_TO(hstmt,irow) SQLSetPos(hstmt,irow,SQL_POSITION,SQL_LOCK_NO_CHANGE)
//#define SQL_LOCK_RECORD(hstmt,irow,fLock) SQLSetPos(hstmt,irow,SQL_POSITION,fLock)
//#define SQL_REFRESH_RECORD(hstmt,irow,fLock) SQLSetPos(hstmt,irow,SQL_REFRESH,fLock)
//#define SQL_UPDATE_RECORD(hstmt,irow) SQLSetPos(hstmt,irow,SQL_UPDATE,SQL_LOCK_NO_CHANGE)
//#define SQL_DELETE_RECORD(hstmt,irow) SQLSetPos(hstmt,irow,SQL_DELETE,SQL_LOCK_NO_CHANGE)
//#define SQL_ADD_RECORD(hstmt,irow) SQLSetPos(hstmt,irow,SQL_ADD,SQL_LOCK_NO_CHANGE)

enum BulkOperations
{
    // Operations
    Add = SQL_ADD, // 4
    UpdateByBookmark = SQL_UPDATE_BY_BOOKMARK, // 5
    DeleteByBookmark = SQL_DELETE_BY_BOOKMARK, // 6
    FetchByBookmark = SQL_FETCH_BY_BOOKMARK, // 7
}

enum SpecialColumns
{
    BestRowID = SQL_BEST_ROWID, // 1
    RowVersion = SQL_ROWVER, // 2
}

enum Statistics
{
    Quick = SQL_QUICK, // 0
    Ensure = SQL_ENSURE, // 1
    TableStatistics = SQL_TABLE_STAT, // 0
}

enum ExtendedFetch
{
    // fFetchType
    FetchBookmark = SQL_FETCH_BOOKMARK, // 0

    // rgfRowStatus
    Success = SQL_ROW_SUCCESS, // 0
    Deleted = SQL_ROW_DELETED, // 1
    Updated = SQL_ROW_UPDATED, // 2
    Norow = SQL_ROW_NOROW, // 3
    Added = SQL_ROW_ADDED, // 4
    Error = SQL_ROW_ERROR, // 5
    SuccesWithInfo = SQL_ROW_SUCCESS_WITH_INFO, // 6

    Proceed = SQL_ROW_PROCEED, // 0
    Ignore = SQL_ROW_IGNORE, // 1
}

enum SQLNullable : SQLSMALLINT
{
    NoNulls = SQL_NO_NULLS,
    Nullable = SQL_NULLABLE,
    Unknown = SQL_NULLABLE_UNKNOWN,
}

/// Statements.statistics - unique argument
enum StatisticsIndexType : SQLUSMALLINT
{
    All = SQL_INDEX_ALL,
    Unique = SQL_INDEX_UNIQUE,
}

/// Statements.statistics - cardinality_pages argument
enum StatisticsCardinalityPages : SQLUSMALLINT
{
    Quick = SQL_QUICK,
    Ensure = SQL_ENSURE,
}
