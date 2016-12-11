module dodbc.interfaces;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;

import std.traits : isImplicitlyConvertible;
import std.typecons : Ternary;
import std.conv : to;
import std.string : fromStringz;

version (Windows) pragma(lib, "odbc32");

import dodbc.constants;
import dodbc.utilities;

interface IHandle
{
    public final @property immutable(bool) isAllocated()
    {
        return (this.handle).isAllocated;
    }

    public @property handle_t handle();
    public @property void handle(handle_t input);

    public ODBCReturn allocate();
    public ODBCReturn free();
}

interface IEnvironment : IHandle
{
    public enum SQLSMALLINT handle_type = SQL_HANDLE_ENV;

    public ODBCReturn setAttribute(EnvironmentAttributes attr,
            pointer_t value_ptr, SQLINTEGER string_length);
    public ODBCReturn getAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            SQLINTEGER buffer_length, SQLINTEGER* string_length_ptr);

    public @property Ternary null_terminated_strings();
    public @property void null_terminated_strings(U : bool)(U input);
    public @property void null_terminated_strings(U : Ternary)(U input);

    public @property ODBCVersion odbc_version();
    private @property void odbc_version(ODBCVersion input);

    public @property ConnectionPoolMatch connection_pool_match();
    public @property void connection_pool_match(ConnectionPoolMatch input);

}

interface IConnection : IHandle
{
    public ODBCReturn setAttribute(ConnectionAttributes attr,
            pointer_t value_ptr, SQLINTEGER string_length);
    public ODBCReturn getAttribute(ConnectionAttributes attr, pointer_t value_ptr,
            SQLINTEGER buffer_length, SQLINTEGER* string_length_ptr);
}

interface IStatement : IHandle
{
    public enum SQLSMALLINT handle_type = SQL_HANDLE_STMT;
    public ODBCReturn setAttribute(T)(StatementAttributes attr,
            pointer_t value_ptr, SQLINTEGER string_length);
    public ODBCReturn getAttribute(T)(StatementAttributes attr,
            pointer_t value_ptr, SQLINTEGER buffer_length, SQLINTEGER* string_length_ptr);
}

interface ITransaction
{
    public void start();
    public void end();
}
