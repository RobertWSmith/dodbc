module dodbc.result;

import dodbc.root;
import dodbc.cursor;

class Result
{
    private Cursor _crsr;

    public this(Cursor stmt)
    {
        this.cursor = stmt;
    }

    public ~this()
    {
    }

    public @property Cursor cursor()
    {
        return this._crsr;
    }

    private @property void cursor(Cursor input)
    {
        this._crsr = input;
    }

    public @property size_t rowset_size()
    {
        return 0;
    }

    public @property size_t affected_rows()
    {
        return 0;
    }

    public @property size_t rows()
    {
        return 0;
    }

    public @property size_t columns()
    {
        return 0;
    }

    public @property bool first()
    {
        return false;
    }

    public @property bool last()
    {
        return false;
    }

    public @property bool next()
    {
        return false;
    }

    public @property bool prior()
    {
        return false;
    }

    public bool async_next(handle_t event_handle = null)
    {
        return false;
    }

    public bool complete_next()
    {
        return false;
    }

    void get_ref(U : size_t, T)(U column, ref T result)
    {

    }

    void get_ref(U : string, T)(U column, ref T result)
    {

    }

    void get_ref(U : size_t, T)(U column, ref const(T) fallback_value, ref T result)
    {

    }

    void get_ref(U : string, T)(U column, ref const(T) fallback_value, ref T result)
    {

    }

    T get(U : size_t, T)(U column)
    {

    }

    T get(U : string, T)(U column)
    {

    }

    T get(U : size_t, T)(U column, ref const(T) fallback)
    {

    }

    T get(U : string, T)(U column, ref const(T) fallback)
    {

    }

    bool isNull(U : size_t)(U column)
    {
        return false;
    }

    bool isNull(U : string)(U column)
    {
        return false;
    }

    size_t column(string column)
    {
        return 0;
    }

    string column(size_t column)
    {
        return "undefined";
    }

    size_t column_size(U : size_t)(U column)
    {
        return 0;
    }

    size_t column_size(U : string)(U column)
    {
        return 0;
    }

    DataType column_datatype(U : size_t)(U column)
    {
        return DataType.init;
    }

    DataType column_datatype(U : string)(U column)
    {
        return DataType.init;
    }

    CDataType column_c_datatype(U : size_t)(U column)
    {
        return DataType.init;
    }

    CDataType column_c_datatype(U : string)(U column)
    {
        return DataType.init;
    }

    @property bool next_result()
    {
        return false;
    }

}
