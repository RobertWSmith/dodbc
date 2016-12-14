module dodbc.cursor;

//import etc.c.odbc.sql;

import dodbc.root;
import dodbc.connection;
import dodbc.result;

import std.conv : to;
import std.string : toStringz;

version (Windows) pragma(lib, "oebc32");

struct Binding
{
    SQLSMALLINT display_size;
    char[] display_buffer;
    SQLLEN size_or_null;
    bool isCharacter;
    pointer_t data_buffer;
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

    public @property ushort n_params()
    {
        SQLSMALLINT params = 0;
        ODBCReturn ret = ret(SQLNumParams(this.handle, &params));
        return to!ushort(params);
    }

    public @property ushort n_cols()
    {
        SQLSMALLINT cols = 0;
        ODBCReturn ret = ret(SQLNumResultCols(this.handle, &cols));
        return to!ushort(cols);
    }

    public @property ulong n_rows()
    {
        SQLLEN rows = 0;
        ODBCReturn ret = ret(SQLRowCount(this.handle, &rows));
        return to!ulong(rows);
    }

    public ODBCReturn prepare(string sql)
    {
        SQLCHAR[] sql_ = to!(SQLCHAR[])(toStringz(sql));
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

    public ODBCReturn getColumnAttribute(size_t columnNbr,
            ColumnAttributes fieldIdentifier, pointer_t characterAttributePtr = null,
            SQLSMALLINT bufferLength = 0, SQLSMALLINT* stringLengthPtr = null,
            pointer_t numericAttributePtr = null)
    {
        ODBCReturn output = ret(SQLColAttribute(this.handle,
                to!SQLUSMALLINT(columnNbr), to!SQLUSMALLINT(fieldIdentifier),
                characterAttributePtr, bufferLength, stringLengthPtr, numericAttributePtr));
        return output;
    }

    private void allocate_column_binding(size_t column_idx)
    {
        Binding column;
        SQLLEN numeric_attr_ptr = 0;
        ODBCReturn output = this.getColumnAttribute(column_idx,
                ColumnAttributes.DisplaySize, null, 0, null, &numeric_attr_ptr);
        column.display_size = to!SQLSMALLINT(numeric_attr_ptr);
        numeric_attr_ptr = 0;
        output = this.getColumnAttribute(column_idx, ColumnAttributes.Type,
                null, 0, null, &numeric_attr_ptr);

    }

    private void allocate_parameter_binding(size_t param)
    {

    }

}
