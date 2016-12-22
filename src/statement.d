module dodbc.statement;

import dodbc.types;
import dodbc.constants;
import dodbc.root;
import dodbc.connection;

import std.conv : to;
import std.string : toStringz;
import std.typecons : Nullable;

static import uuid = std.uuid;

//struct DataBinding
//{
//    ushort target_type;
//    ubyte[] value_ptr;
//    size_t buffer_length;
//    size_t string_len_or_ind;
//}

//alias Binding = DataBinding;

enum DescriptionType
{
    Column,
    Parameter
}

struct Description
{
    DescriptionType type;
    ushort number;
    string name;
    SQLType data_type;
    ushort data_size;
    short decimal_digits;
    SQLNullable nullable;

    this(DescriptionType typ, ushort colNbr, SQLCHAR* nm, SQLSMALLINT dataTyp,
            SQLUSMALLINT dataSz, SQLSMALLINT decimalDigits, SQLSMALLINT nullableInd)
    {
        this.type = typ;
        this.number = colNbr;

        string temp = str_conv(nm);

        this.name = temp;
        this.data_type = to!SQLType(dataTyp);
        this.data_size = to!ushort(dataSz);
        this.decimal_digits = to!short(decimalDigits);
        this.nullable = to!SQLNullable(nullableInd);
    }

}

struct SQLTypeInfo
{
    string type_name; // VARCHAR
    SQLType type; // SQLSMALLINT
    Nullable!size_t size; // SQLINTEGER
    string literal_prefix; // VARCHAR
    string literal_suffix; // VARCHAR
    string create_params; // VARCHAR
    bool nullable; // SQLSMALLINT
    bool case_sensitive; // SQLSMALLINT
    Searchable searchable; // SQLSMALLINT
    Nullable!bool unsigned_attribute; // SQLSMALLINT
    bool fixed_precision_and_scale; // SQLSMALLINT
    bool auto_unique_value; // SQLSMALLINT
    string local_type_name; // VARCHAR
    Nullable!short minimum_scale; //SQLSMALLINT
    Nullable!short maximum_scale; // SQLSMALLINT
    SQLType data_type; // SQLSMALLINT
    Nullable!short datetime_subcode; // SQLSMALLINT
    Nullable!size_t numeric_precision_radix; // SQLINTEGER
    Nullable!short inteval_precision; // SQLSMALLINT
}

class Statement : StatementHandle
{
    private Connection _conn;
    private handle_t _handle;
    private string[] _queries;

    package this(Connection conn)
    {
        super(generateUUID("Statement"));
        this.connection = conn;
        super.allocate(conn.handle);
    }

    public ~this()
    {
        // this.close();
        this.free();
    }

    public void free_statement(FreeStatement input)
    {
        this.sqlreturn = SQLFreeStmt(this.handle, input);
    }

    //    public void open()
    //    {
    //    }

    //    public void close()
    //    {
    //    }

    //    public void cancel()
    //    {
    //    }

    /// SQLTables
    public Prepared tables(string catalog = null, string schema = null,
            string table_name = null, string type = null)
    {
        alias sql_func = SQLTables;

        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;

            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
            this.insert_kwarg("type", type);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);
        SQLCHAR[] type_str = str_conv(type);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS, type_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLColumns
    public Prepared columns(string catalog = null, string schema = null,
            string table_name = null, string column_name = null)
    {
        alias sql_func = SQLColumns;

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);
        SQLCHAR[] column_str = str_conv(column_name);

        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;

            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
            this.insert_kwarg("column_name", column_name);
        }

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS, column_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLStatistics
    public Prepared statistics(string catalog = null, string schema = null,
            string table_name = null, StatisticsIndexType unique = StatisticsIndexType.All,
            StatisticsCardinalityPages cardinality_pages = StatisticsCardinalityPages.Quick)
    {
        alias sql_func = SQLStatistics;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
            this.insert_kwarg("unique", unique);
            this.insert_kwarg("cardinality_pages", cardinality_pages);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);
        SQLUSMALLINT unq = to!SQLUSMALLINT(unique);
        SQLUSMALLINT res = to!SQLUSMALLINT(cardinality_pages);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS, unq, res);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLSpecialColumns
    public Prepared special_columns(short identifier_type = SQL_ROWVER, string catalog = null, string schema = null,
            string table_name = null, short row_scope = SQL_SCOPE_CURROW,
            short nullable = SQL_NULLABLE)
    {
        alias sql_func = SQLSpecialColumns;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("identifier_type", identifier_type);
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
            this.insert_kwarg("row_scope", row_scope);
            this.insert_kwarg("nullable", nullable);
        }

        SQLSMALLINT id_type = to!SQLSMALLINT(identifier_type);
        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);
        SQLSMALLINT scp = to!SQLSMALLINT(row_scope);
        SQLSMALLINT nul = to!SQLSMALLINT(nullable);

        this.sqlreturn = sql_func((this.handle), id_type, catalog_str.ptr,
                SQL_NTS, schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS, scp, nul);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLPrimaryKeys
    public Prepared primary_keys(string catalog = null, string schema = null,
            string table_name = null)
    {
        alias sql_func = SQLPrimaryKeys;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLForeignKeys
    public Prepared foreign_keys(string pk_catalog = null, string pk_schema = null, string pk_table_name = null,
            string fk_catalog = null, string fk_schema = null, string fk_table_name = null)
    {
        alias sql_func = SQLForeignKeys;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("pk_catalog", pk_catalog);
            this.insert_kwarg("pk_schema", pk_schema);
            this.insert_kwarg("pk_table_name", pk_table_name);
            this.insert_kwarg("fk_catalog", fk_catalog);
            this.insert_kwarg("fk_schema", fk_schema);
            this.insert_kwarg("fk_table_name", fk_table_name);
        }

        SQLCHAR[] pk_catalog_str = str_conv(pk_catalog);
        SQLCHAR[] pk_schema_str = str_conv(pk_schema);
        SQLCHAR[] pk_table_str = str_conv(pk_table_name);
        SQLCHAR[] fk_catalog_str = str_conv(fk_catalog);
        SQLCHAR[] fk_schema_str = str_conv(fk_schema);
        SQLCHAR[] fk_table_str = str_conv(fk_table_name);

        this.sqlreturn = sql_func((this.handle), pk_catalog_str.ptr, SQL_NTS,
                pk_schema_str.ptr, SQL_NTS, pk_table_str.ptr, SQL_NTS, fk_catalog_str.ptr,
                SQL_NTS, fk_schema_str.ptr, SQL_NTS, fk_table_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLTablePrivileges
    public Prepared table_privileges(string catalog = null, string schema = null,
            string table_name = null)
    {
        alias sql_func = SQLTablePrivileges;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLColumnPrivileges
    public Prepared column_privileges(string catalog = null, string schema = null,
            string table_name = null, string column_name = null)
    {
        alias sql_func = SQLColumnPrivileges;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("table_name", table_name);
            this.insert_kwarg("column_name", column_name);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] table_str = str_conv(table_name);
        SQLCHAR[] column_str = str_conv(column_name);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, table_str.ptr, SQL_NTS, column_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLProcedures
    public Prepared procedures(string catalog = null, string schema = null,
            string procedure_name = null)
    {
        alias sql_func = SQLProcedures;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("procedure_name", procedure_name);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] proc_str = str_conv(procedure_name);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, proc_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    /// SQLProcedureColumns
    public Prepared procedure_columns(string catalog = null, string schema = null,
            string procedure_name = null, string column_name = null)
    {
        alias sql_func = SQLProcedureColumns;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("catalog", catalog);
            this.insert_kwarg("schema", schema);
            this.insert_kwarg("procedure_name", procedure_name);
            this.insert_kwarg("column_name", column_name);
        }

        SQLCHAR[] catalog_str = str_conv(catalog);
        SQLCHAR[] schema_str = str_conv(schema);
        SQLCHAR[] proc_str = str_conv(procedure_name);
        SQLCHAR[] column_str = str_conv(column_name);

        this.sqlreturn = sql_func((this.handle), catalog_str.ptr, SQL_NTS,
                schema_str.ptr, SQL_NTS, proc_str.ptr, SQL_NTS, column_str.ptr, SQL_NTS);

        debug this.debugger();

        return new Prepared(this);
    }

    public Prepared prepare(string query)
    {
        alias sql_func = SQLPrepare;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("query", query);
        }

        this._queries ~= query;
        SQLCHAR[] sql = to!(SQLCHAR[])(toStringz(this._queries[$ - 1]));
        SQLINTEGER sql_len = query.length;

        this.sqlreturn = SQLPrepare(this.handle, sql.ptr, sql_len);

        debug this.debugger();

        return new Prepared(this);
    }

    package void execute()
    {
        alias sql_func = SQLExecute;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
        }

        this.sqlreturn = SQLExecute((this.handle));

        debug this.debugger();
    }

    private void p_getTypeInfo(SQLType type)
    {
        alias sql_func = SQLGetTypeInfo;

        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("type", type);
        }

        this.sqlreturn = sql_func(this.handle, to!SQLSMALLINT(type));

        debug this.debugger();
    }

    public SQLTypeInfo getTypeInfo(SQLType type)
    {
        SQLTypeInfo output;
        output.type = type;
        output.data_type = type;
        SQLLEN strlen_or_ind_ptr;
        SQLCHAR[256 + 1] char_buffer;
        SQLSMALLINT short_buffer;
        SQLINTEGER int_buffer;

        char_buffer[] = '\0';
        this.getData(1, SQL_C_CHAR, cast(pointer_t) char_buffer.ptr,
                to!SQLLEN(char_buffer.length - 1), &strlen_or_ind_ptr);
        output.type_name = to!string(char_buffer.ptr.fromStringz);

        short_buffer = 0;
        this.getData(2, SQL_C_SSHORT, cast(pointer_t)&short_buffer,
                to!SQLLEN(SQLSMALLINT.sizeof), &strlen_or_ind_ptr);
        output.type = to!SQLType(short_buffer);

        return output;
    }

    private void getData(SQLUSMALLINT col_or_param_nbr, SQLSMALLINT target_type,
            pointer_t value_ptr, SQLLEN buffer_len = 0, SQLLEN* strlen_or_ind_ptr = null)
    {
        alias sql_func = SQLGetData;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
            this.insert_kwarg("col_or_param_nbr", col_or_param_nbr);
            this.insert_kwarg("target_type", target_type);
            this.insert_kwarg("buffer_len", buffer_len);
        }

        this.sqlreturn = SQLGetData(this.handle, col_or_param_nbr, target_type,
                value_ptr, buffer_len, strlen_or_ind_ptr);

        debug this.debugger();
    }

    public @property Connection connection()
    {
        return this._conn;
    }

    private @property void connection(Connection input)
    {
        this._conn = input;
    }

    private void p_fetch()
    {
        alias sql_func = SQLFetch;
        debug
        {
            this.sql_function = fullyQualifiedName!sql_func;
        }

        this.sqlreturn = sql_func(this._handle);

        debug this.debugger();
    }

    public @property size_t timeout()
    {
        return 0;
    }

    public @property void timeout(size_t input)
    {
    }

}

class Prepared : Identified
{
    private Statement _stmt;
    //    private Column[ushort] _columns;
    //    private Parameter[ushort] _parameters;

    @disable this();
    package this(Statement stmt)
    {
        this.statement = stmt;
    }

    public @property Statement statement()
    {
        return this._stmt;
    }

    public @property void statement(Statement input)
    {
        this._stmt = input;
    }

    public @property handle_t handle()
    {
        return (this.statement).handle;
    }

    public @property void sqlreturn(SQLRETURN input)
    {
        (this.statement).sqlreturn = input;
    }

    public @property SQLRETURN sqlreturn()
    {
        return (this.statement).sqlreturn;
    }

    public @property ushort n_params()
    {
        alias sql_func = SQLNumParams;
        debug
        {
            this.statement.sql_function = fullyQualifiedName!sql_func;
        }

        SQLSMALLINT params;
        this.sqlreturn = sql_func((this.handle), &params);

        debug this.statement.debugger();

        return to!ushort(params);
    }

    public @property ushort n_cols()
    {
        alias sql_func = SQLNumResultCols;
        debug
        {
            this.statement.sql_function = fullyQualifiedName!sql_func;
        }

        SQLSMALLINT cols;
        this.sqlreturn = sql_func((this.handle), &cols);

        debug this.statement.debugger();

        return to!ushort(cols);
    }

    public @property ulong n_rows()
    {
        alias sql_func = SQLRowCount;
        debug
        {
            this.statement.sql_function = fullyQualifiedName!sql_func;
        }
        SQLLEN rows;
        this.sqlreturn = sql_func((this.handle), &rows);

        debug this.statement.debugger();

        return to!ulong(rows);
    }

    private void p_describeParam(SQLUSMALLINT parameter_nbr, SQLSMALLINT* data_type_ptr,
            SQLUSMALLINT* parameter_size_ptr, SQLSMALLINT* decimal_digits_ptr,
            SQLSMALLINT* nullable_ptr)
    {
        alias sql_func = SQLDescribeParam;
        debug
        {
            this.statement.sql_function = fullyQualifiedName!sql_func;
            this.statement.insert_kwarg("parameter_nbr", parameter_nbr);
        }

        this.sqlreturn = sql_func(this.handle, parameter_nbr, data_type_ptr,
                parameter_size_ptr, decimal_digits_ptr, nullable_ptr);

        debug this.statement.debugger();
    }

    public Description describeParameter(ushort columnNbr)
    {
        SQLCHAR[64 + 1] name;
        SQLSMALLINT name_len, data_type, decimal_digits, nullable;
        SQLUSMALLINT column_sz;

        this.p_describeParam(to!SQLUSMALLINT(columnNbr), &data_type,
                &column_sz, &decimal_digits, &nullable);

        return Description(DescriptionType.Parameter, columnNbr, name.ptr,
                data_type, column_sz, decimal_digits, nullable);
    }

    public Description[] describeParamters()
    {
        Description[] output = new Description[this.n_params];
        foreach (ushort ix; 1 .. (to!ushort(this.n_params) + 1))
        {
            output[ix - 1] = this.describeParameter(ix);
            debug
            {
                writefln("Index: %s\tParameter Description: %s", ix, output[(ix - 1)]);
            }
        }
        return output;
    }

    //    public Description describeParam(ushort parameter_nbr)
    //    {
    //        SQLUSMALLINT nbr = to!SQLUSMALLINT(parameter_nbr);
    //        SQLUSMALLINT sz;
    //        // SQLULEN sz;
    //        SQLSMALLINT typ, dig, nul;
    //
    //        this.p_describeParam(nbr, &typ, &sz, &dig, &nul);
    //        return Description(DescriptionType.Parameter, nbr, null,
    //                to!SQLType(typ), sz, dig, to!SQLNullable(nul));
    //    }

    private void p_describeColumn(SQLUSMALLINT columnNbr, SQLCHAR* columnNamePtr,
            SQLSMALLINT bufferLength, SQLSMALLINT* nameLengthPtr,
            SQLSMALLINT* dataTypePtr, SQLUSMALLINT* columnSizePtr,
            SQLSMALLINT* decimalDigitsPtr, SQLSMALLINT* nullablePtr)
    {
        alias sql_func = SQLDescribeCol;
        debug
        {
            this.statement.sql_function = fullyQualifiedName!sql_func;
            this.statement.insert_kwarg("columnNbr", columnNbr);
        }

        this.sqlreturn = SQLDescribeCol(this.handle, columnNbr, columnNamePtr, bufferLength,
                nameLengthPtr, dataTypePtr, columnSizePtr, decimalDigitsPtr, nullablePtr);

        debug this.statement.debugger();
    }

    public Description describeColumn(ushort columnNbr)
    {
        SQLCHAR[64 + 1] name;
        SQLSMALLINT name_len, data_type, decimal_digits, nullable;
        SQLUSMALLINT column_sz;
        //            this._columns[columnNbr] = new Column(this, columnNbr);
        this.p_describeColumn(to!SQLUSMALLINT(columnNbr), name.ptr,
                name.length - 1, &name_len, &data_type, &column_sz,
                &decimal_digits, &nullable);

        return Description(DescriptionType.Column, columnNbr, name.ptr,
                data_type, column_sz, decimal_digits, nullable);
    }

    public Description[] describeColumns()
    {
        Description[] output = new Description[this.n_cols];
        foreach (ushort ix; 1 .. (to!ushort(this.n_cols) + 1))
        {
            output[ix - 1] = this.describeColumn(ix);
            debug
            {
                writefln("Index: %s\tColumn Description: %s", ix, output[(ix - 1)]);
            }
        }
        return output;
    }

    public void execute()
    {
        (this.statement).execute();
    }
}

unittest
{
    writeln("Statement Tests:\n");
    // DSN is set up as a file on local directory: C:/testsqlite.sqlite
    //    string conn_str = "Driver={SQLite3 ODBC Driver};Database=C:\\testsqlite.sqlite;";
    string conn_str = "Driver={SQLite3 ODBC Driver};Database=:memory:;";
    Connection conn = connect(conn_str);
    writeln(typeid(conn));
    writeln(conn_str);

    string query = "SELECT 1;";
    Statement stmt = conn.statement();
    writeln(typeid(stmt));
    writeln(query);
    Prepared prepped = stmt.prepare(query);
    writeln(typeid(prepped));

    writefln("Number of Columns: %s", prepped.n_cols);
    writefln("Number of Parameters: %s", prepped.n_params);

    prepped.describeColumns();
    prepped.execute();

    writeln("End Statement Tests: \n\n");
}

//interface ColumnParameter
//{
//    public @property ushort number();
//    public @property Prepared prepared();
//    public @property handle_t handle();
//}
//
//class Column : ColumnParameter
//{
//    private Prepared _prepared;
//    private ushort _number;
//    private void[] _ptr;
//
//    @disable this();
//
//    package this(Prepared stmt, ushort columnNbr)
//    {
//        // assert(columnNbr <= stmt.n_cols,
//        // format("columnNbr must be <= the value returned by SQLNumResultCols(%s)",
//        // stmt.n_cols));
//        this._prepared = stmt;
//        this._number = columnNbr;
//    }
//
//    public @property ushort number()
//    {
//        return this._number;
//    }
//
//    public @property Prepared prepared()
//    {
//        return this._prepared;
//    }
//
//    public @property handle_t handle()
//    {
//        return ((this.prepared).handle);
//    }
//
//    private void getColAttribute(SQLUSMALLINT fieldIdentifier, pointer_t characterAttributePtr,
//            SQLSMALLINT bufferLength, SQLSMALLINT* stringLengthPtr, SQLLEN* numericAttributePtr)
//    {
//        this.prepared.sqlreturn = SQLColAttribute((this.handle), this.number, fieldIdentifier,
//                characterAttributePtr, bufferLength, stringLengthPtr, numericAttributePtr);
//    }
//
//    @property bool auto_unique_value()
//    {
//        SQLLEN attr;
//        this.getColAttribute(SQL_DESC_AUTO_UNIQUE_VALUE, null, 0, null, &attr);
//        return (attr == SQL_TRUE);
//    }
//
//    @property string base_column_name()
//    {
//        SQLCHAR[256 + 1] char_attr; // = new SQLCHAR[];
//        this.getColAttribute(SQL_DESC_BASE_COLUMN_NAME, char_attr.ptr,
//                char_attr.length - 1, null, null);
//        return to!string(char_attr.ptr.fromStringz);
//    }
//}
//
//class Parameter : ColumnParameter
//{
//    private Prepared _prepared;
//    private ushort _number;
//    private void[] _ptr;
//
//    @disable this();
//
//    package this(Prepared stmt, ushort parameterNbr)
//    {
//        assert(parameterNbr <= stmt.n_params,
//                format("parameterNbr must be <= the value returned by SQLNumParams(%s)",
//                    stmt.n_params));
//        this._prepared = stmt;
//        this._number = parameterNbr;
//    }
//
//    public @property ushort number()
//    {
//        return this._number;
//    }
//
//    public @property Prepared prepared()
//    {
//        return this._prepared;
//    }
//
//    public @property handle_t handle()
//    {
//        return ((this.prepared).handle);
//    }
//}
