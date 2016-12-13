module dodbc.constants;

import dodbc.type_alias;

enum ODBCReturn : return_type
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
