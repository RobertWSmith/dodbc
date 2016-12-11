module dodbc.utilities;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;

import std.traits : isImplicitlyConvertible;
import std.typecons : Ternary;
import std.conv : to;
import std.string : fromStringz;

version (Windows) pragma(lib, "odbc32");

import dodbc.constants;
import dodbc.interfaces;

alias handle_t = SQLHANDLE;
alias pointer_t = SQLPOINTER;

bool isAllocated(handle_t handle)
{
    return !(handle == SQL_NULL_HANDLE);
}

string[] diagnose(HandleType ht, handle_t handle)
{
    string[] output;
    if (isAllocated(handle))
    {
        string temp_output;
        SQLSMALLINT rec = 0;
        SQLCHAR[7] state;
        SQLINTEGER native_err = 0;
        SQLCHAR[SQL_MAX_MESSAGE_LENGTH + 1] message;
        SQLSMALLINT buffer_length, text_length;
        ODBCReturn ret = ODBCReturn.Success;

        while (ret != ODBCReturn.NoData)
        {
            rec++;
            state[] = '\0';
            message[] = '\0';
            buffer_length = message.length - 1;
            text_length = 0;
            ret = to!ODBCReturn(SQLGetDiagRec(ht, handle, rec, state.ptr,
                    &native_err, message.ptr, buffer_length, &text_length));
            temp_output = to!string(native_err) ~ " [" ~ to!string(
                    fromStringz(state.ptr)) ~ "] " ~ to!string(fromStringz(message.ptr));
            output ~= temp_output;
        }
    }
    return output;
}
