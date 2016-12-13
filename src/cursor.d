module dodbc.cursor;

//import etc.c.odbc.sql;

import dodbc.root;
import dodbc.connection;
import dodbc.result;

import std.conv : to;

enum CursorAttributes : SQLINTEGER
{
    AsyncEnable,
    Concurrency,
}

enum DataTypes
{
    Undefined,
}

enum CDataTypes
{
    Undefined,
}

enum Concurrency : SQLULEN
{
    ReadOnly, //= SQL_CONCUR_READ_ONLY,
    Lock, //= SQL_CONCUR_LOCK,
    RowVersion, // = SQL_CONCUR_ROWVER,
    Values, //= SQL_CONCUR_VALUES,
}

enum FreeStatement : SQLUSMALLINT
{
    Close = SQL_CLOSE,
    Drop = SQL_DROP,
    Unbind = SQL_UNBIND,
    ResetParams = SQL_RESET_PARAMS,
}

class Cursor : Handle!(HandleType.Statement, SQLGetStmtAttr, SQLSetStmtAttr, CursorAttributes)
{
    private Connection _conn;
    private handle_t _handle;

    package this(Connection conn)
    {
        this.connection = conn;
    }

    public ~this()
    {
        this.close();
        this.free();
    }

    public ODBCReturn free_statement(FreeStatement input)
    {
        return ret(SQLFreeStmt(this.handle, input));
    }

    public ODBCReturn open()
    {
        return ODBCReturn.Success;
    }

    public ODBCReturn close()
    {
        return ODBCReturn.Success;
    }

    public ODBCReturn cancel()
    {
        return ODBCReturn.Success;
    }

    public ODBCReturn prepare(string query, size_t timeout = 0)
    {
        return ODBCReturn.Success;
    }

    public @property Connection connection()
    {
        return this._conn;
    }

    private @property void connection(Connection input)
    {
        this._conn = input;
    }

    private ODBCReturn p_fetch()
    {
        return ret(SQLFetch(this._handle));
    }

    public @property size_t timeout()
    {
        return 0;
    }

    public @property void timeout(size_t input)
    {
    }

    public @property size_t n_rows()
    {
        SQLLEN row_cnt = 0;
        SQLRowCount(this._handle, &row_cnt);
        return to!size_t(row_cnt);
    }

    public @property size_t n_params()
    {
        SQLSMALLINT param_cnt = 0;
        SQLNumParams(this._handle, &param_cnt);
        return to!size_t(param_cnt);
    }

    public @property size_t n_cols()
    {
        SQLSMALLINT col_cnt = 0;
        SQLNumResultCols(this._handle, &col_cnt);
        return to!size_t(col_cnt);
    }

    public ODBCReturn prepare(string sql)
    {
        SQLCHAR[] sql_ = toStringz(to!(SQLCHAR[])(sql));
        return ret(SQLPrepare(this._handle, sql_.ptr, SQL_NTS));
    }

    public ODBCReturn execute()
    {
        return ret(SQLExecute(this._handle));
    }

    public ODBCReturn execute_direct(string sql)
    {
        ODBCReturn output = this.prepare(sql);
        output = this.execute();
        return output;
    }
}
