module dodbc.description;

import dodbc.root;
import dodbc.cursor;

class Description : Root!(HandleType.Description)
{
    private Cursor _crsr;

    this(Cursor input)
    {
        this.cursor = input;
    }

    @property Cursor cursor()
    {
        return this._crsr;
    }

    @property void cursor(Cursor input)
    {
        this._crsr = input;
    }

    ODBCReturn setAttribute(SQLSMALLINT rec_number, SQLSMALLINT field_identifier,
            pointer_t value_ptr, SQLINTEGER buffer_length = 0)
    {
        return ret(SQLSetDescField(this._handle, rec_number, field_identifier,
                value_ptr, buffer_length));
    }

    ODBCReturn getAttribute(SQLSMALLINT rec_number, SQLSMALLINT field_identifier,
            pointer_t value_ptr, SQLINTEGER buffer_length = 0, SQLINTEGER* string_length_ptr = null)
    {
        return ret(SQLGetDescField(this._handle, rec_number, field_identifier,
                value_ptr, buffer_length, string_length_ptr));
    }
}
