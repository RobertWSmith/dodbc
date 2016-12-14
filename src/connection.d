module dodbc.connection;

import std.conv : to;
import std.typecons : Ternary, Tuple;
import std.traits : EnumMembers;
import std.string : toStringz, fromStringz;
import std.uuid;

import dodbc.root;
import dodbc.environment;
import dodbc.transaction;

class Connection : Handle!(HandleType.Connection, SQLGetConnectAttr,
        SQLSetConnectAttr, ConnectionAttributes)
{
    private Environment _env;
    private handle_t _handle = SQL_NULL_HANDLE;
    private string _connection_string;
    private Transaction[UUID] _transactions;

    package this()
    {
        super();
        this._env = environment_factory();
        this.allocate(((this.environment).handle));
    }

    public Transaction start()
    {
        UUID id = randomUUID();
        this._transactions[id] = new Transaction(this, id);
        this._transactions[id].start();
        return this._transactions[id];
    }

    public bool end(U : Transaction)(U input)
    {
        return this.end(input.id);
    }

    public bool end(U : UUID)(U input)
    {
        this._transactions[id].close();
        return this._transactions.remove(input);
    }

    public ODBCReturn getInfo(InfoType info_type, pointer_t value_ptr,
            SQLSMALLINT buffer_length = 0, SQLSMALLINT* string_length_ptr = null)
    {
        return to!ODBCReturn(SQLGetInfo((this.handle), to!SQLSMALLINT(info_type),
                value_ptr, buffer_length, string_length_ptr));
    }

    public ODBCReturn connect(string dsn, string uid, string pwd, handle_t event_handle = null)
    {
        string conn_str = "DSN={" ~ dsn ~ "};";
        if (uid !is null)
            conn_str ~= "UID={" ~ uid ~ "};";
        if (pwd !is null)
            conn_str ~= "PWD={" ~ pwd ~ "};";

        return this.connect(conn_str);
    }

    public ODBCReturn connect(string connection_string_ = null, handle_t event_handle = null)
    {
        this.disconnect();

        if (connection_string_ !is null)
            this.connection_string = connection_string_;

        SQLCHAR[] conn_str = to!(SQLCHAR[])(toStringz(this.connection_string));
        SQLSMALLINT conn_str_len = to!SQLSMALLINT(conn_str.length);
        SQLCHAR[2048 + 1] conn_str_out;
        conn_str_out[] = '\0';
        SQLSMALLINT buffer_length = conn_str_out.length - 1, out_conn_str_len = 0;
        ODBCReturn output = to!ODBCReturn(SQLDriverConnect(this.handle, cast(SQLHWND) null, conn_str.ptr, conn_str_len,
                conn_str_out.ptr, buffer_length, &out_conn_str_len, SQL_DRIVER_NOPROMPT));

        string cstr = to!string(fromStringz(conn_str_out.ptr));
        if (cstr.length > 0 && cstr != this.connection_string)
            this.connection_string = cstr.dup;
        return output;
    }

    public ODBCReturn disconnect()
    {
        return to!ODBCReturn(SQLDisconnect((this.handle)));
    }

    //    public void enable_async(handle_t event_handle)
    //    {
    //
    //    }

    //    public void async_complete()
    //    {
    //
    //    }

    public @property Environment environment()
    {
        return this._env;
    }

    private @property void connection_string(string input)
    {
        this._connection_string = input.dup;
    }

    public @property string connection_string()
    {
        return this._connection_string;
    }

    public @property void access_mode(AccessMode input)
    {
        SQLUINTEGER value_ptr = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.AccessMode, cast(pointer_t)&value_ptr);
    }

    public @property AccessMode access_mode()
    {
        SQLUINTEGER value_ptr = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.AccessMode, cast(pointer_t)&value_ptr);
        return to!AccessMode(value_ptr);
    }

    public @property AsyncEnable async_enable()
    {
        SQLULEN value_ptr = SQLULEN.init;
        this.getAttribute(ConnectionAttributes.AsyncEnable, &value_ptr);
        return to!AsyncEnable(value_ptr);
    }

    public @property void async_enable(AsyncEnable input)
    {
        SQLULEN value_ptr = to!SQLULEN(input);
        this.setAttribute(ConnectionAttributes.AsyncEnable, cast(pointer_t) value_ptr);
    }

    public @property Ternary auto_ipd()
    {
        Ternary output;
        if (this.isAllocated)
        {
            SQLULEN value_ptr = SQLULEN.init;
            this.getAttribute(ConnectionAttributes.AutoIPD, &value_ptr);
            output = (value_ptr == SQL_TRUE);
        }
        return output;
    }

    public @property void autocommit(bool input)
    {
        SQLUINTEGER value_ptr = input ? SQL_AUTOCOMMIT_ON : SQL_AUTOCOMMIT_OFF;
        this.setAttribute(ConnectionAttributes.Autocommit, cast(pointer_t) value_ptr);
    }

    public @property bool autocommit()
    {
        SQLUINTEGER value_ptr = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.Autocommit, &value_ptr);
        return (value_ptr == SQL_AUTOCOMMIT_ON);
    }

    //    public @property bool connection_dead()
    //    {
    //        
    //        this.getAttribute(ConnectionAttributes.ConnectionDead, 
    //        return true;
    //    }

    public @property uint connection_timeout()
    {
        SQLUINTEGER value_ptr = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.ConnectionTimeout, &value_ptr);
        return to!uint(value_ptr);
    }

    public @property void connection_timeout(uint input)
    {
        SQLUINTEGER value_ptr = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.ConnectionTimeout, &value_ptr);
    }

    public @property string current_catalog()
    {
        char[(2048 + 1)] value;
        value[] = '\0';

        SQLINTEGER value_len = value.length, str_len_ptr = SQLINTEGER.init;

        this.getAttribute(ConnectionAttributes.CurrentCatalog,
                cast(pointer_t) value.ptr, value_len, &str_len_ptr);
        return to!string(value[0 .. str_len_ptr]);
    }

    public @property void current_catalog(string input)
    {
        char[] value = to!(char[])(toStringz(input));
        //        value ~= '\0';
        SQLINTEGER len = value.length;
        this.setAttribute(ConnectionAttributes.CurrentCatalog, cast(pointer_t) value.ptr, len);
    }

    public @property uint login_timeout()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.LoginTimeout, &value);
        return to!uint(value);
    }

    /// before connect only
    private @property void login_timeout(uint input)
    {
        SQLUINTEGER value = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.LoginTimeout, cast(pointer_t) value);
    }

    public @property bool metadata_id()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.MetadataID, &value);
        return (value == SQL_TRUE);
    }

    public @property void metadata_id(bool input)
    {
        SQLUINTEGER value = input ? SQL_TRUE : SQL_FALSE;
        this.setAttribute(ConnectionAttributes.MetadataID, cast(pointer_t) value);
    }

    public @property ODBCCursors odbc_cursors()
    {
        SQLULEN value = SQLULEN.init;
        this.getAttribute(ConnectionAttributes.ODBCCursors, &value);
        return to!ODBCCursors(value);
    }

    /// set before connection only
    private @property void odbc_cursors(ODBCCursors input)
    {

        SQLULEN value = to!SQLULEN(input);
        this.setAttribute(ConnectionAttributes.ODBCCursors, &value);
    }

    public @property uint packet_size()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.PacketSize, cast(pointer_t) value);
        return to!uint(value);
    }

    /// set before connection only
    private @property void packet_size(uint input)
    {
        SQLUINTEGER value = to!SQLUINTEGER(input);
        this.setAttribute(ConnectionAttributes.PacketSize, &value);
    }

    public @property bool trace()
    {
        SQLUINTEGER value = SQLUINTEGER.init;
        this.getAttribute(ConnectionAttributes.Trace, &value);
        return (value == SQL_OPT_TRACE_ON);
    }

    public @property void trace(bool input)
    {
        SQLUINTEGER value = input ? SQL_OPT_TRACE_ON : SQL_OPT_TRACE_OFF;
        this.setAttribute(ConnectionAttributes.Trace, cast(pointer_t) value);
    }

    public @property string tracefile()
    {
        char[(2048 + 1)] value;
        value[] = '\0';
        SQLINTEGER value_len = value.length, str_len_ptr = 0;
        this.getAttribute(ConnectionAttributes.Tracefile,
                cast(pointer_t) value.ptr, value_len, &str_len_ptr);
        string output = to!string(value[0 .. str_len_ptr]);
        return output;
    }

    public @property void tracefile(string input)
    {
        char[] value = to!(char[])(input) ~ '\0';
        SQLINTEGER value_len = value.length;
        this.setAttribute(ConnectionAttributes.Tracefile, cast(pointer_t) value.ptr, value_len);
    }

    //    public @property string translate_lib()
    //    {
    //        return "";
    //    }

    //    public @property void translate_lib(string input)
    //    {
    //
    //    }

    public @property TransactionIsolation transaction_isolation()
    {
        TransactionIsolation output = TransactionIsolation.Undefined;
        if (this.isAllocated)
        {
            SQLUINTEGER value = 0;
            this.getAttribute(ConnectionAttributes.TransactionIsolation, cast(pointer_t)&value);
            if (value > 0)
                output = to!TransactionIsolation(value);
        }

        //        foreach (v; EnumMembers!TransactionIsolation)
        //            if ((to!SQLUINTEGER(v) & value) == 0)
        //                output ~= v;

        return output;
    }

    public @property void transaction_isolation(TransactionIsolation input)
    {
        SQLUINTEGER value = to!SQLUINTEGER(input);
        //        foreach (i; input)
        //            value += to!SQLUINTEGER(i);
        this.setAttribute(ConnectionAttributes.TransactionIsolation, &value);
    }
}

private Connection connection_factory(uint login_timeout_ = 0,
        ODBCCursors odbc_cursors_ = ODBCCursors.UseDriver)
{
    Connection conn = new Connection();
    conn.login_timeout = login_timeout_;
    conn.odbc_cursors = odbc_cursors_;
    return conn;
}

Connection connect(string dsn, string uid = null, string pwd = null,
        uint login_timeout_ = 0, ODBCCursors odbc_cursors_ = ODBCCursors.UseDriver)
{
    Connection conn = connection_factory(login_timeout_, odbc_cursors_);
    conn.connect(dsn, uid, pwd);
    return conn;
}

Connection connect(string connection_string = null, uint login_timeout_ = 0,
        ODBCCursors odbc_cursors_ = ODBCCursors.UseDriver)
{
    Connection conn = connection_factory(login_timeout_, odbc_cursors_);
    if (connection_string !is null)
        conn.connect(connection_string);
    return conn;
}

unittest
{
    import std.stdio;

    Connection conn = connect();
    assert(conn.isAllocated);
    assert(conn.environment.isAllocated);

    writeln("Connection Unit Tests\n");
    writeln("After allocate:");
    writefln("Connection String: %s", conn.connection_string);
    writefln("Access Mode: %s", conn.access_mode);
    writefln("Autocommit: %s", conn.autocommit);
    writefln("Connection Timeout: %s", conn.connection_timeout);
    writefln("Current Catalog: %s", conn.current_catalog);
    writefln("Login Timeout: %s", conn.login_timeout);
    writefln("Metadata ID: %s", conn.metadata_id);
    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    writefln("Packet Size: %s", conn.packet_size);
    writefln("Trace: %s", conn.trace);
    writefln("Tracefile: %s", conn.tracefile);
    writefln("Transaction Isolation: %s", conn.transaction_isolation);

    conn.free();
    writeln("\nAfter free:");
    writefln("Connection String: %s", conn.connection_string);
    writefln("Access Mode: %s", conn.access_mode);
    writefln("Autocommit: %s", conn.autocommit);
    writefln("Connection Timeout: %s", conn.connection_timeout);
    writefln("Current Catalog: %s", conn.current_catalog);
    writefln("Login Timeout: %s", conn.login_timeout);
    writefln("Metadata ID: %s", conn.metadata_id);
    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    writefln("Packet Size: %s", conn.packet_size);
    writefln("Trace: %s", conn.trace);
    writefln("Tracefile: %s", conn.tracefile);
    writefln("Transaction Isolation: %s", conn.transaction_isolation);

    conn.allocate();
    string conn_str = "DRIVER={SQLite3 ODBC Driver};Database={c:/mydb.db};LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;";
    conn.connect(conn_str);

    writeln("\nAfter Connect:");
    writefln("Connection String: %s", conn.connection_string);
    writefln("Access Mode: %s", conn.access_mode);
    writefln("Autocommit: %s", conn.autocommit);
    writefln("Connection Timeout: %s", conn.connection_timeout);
    writefln("Current Catalog: %s", conn.current_catalog);
    writefln("Login Timeout: %s", conn.login_timeout);
    writefln("Metadata ID: %s", conn.metadata_id);
    writefln("ODBC Cursors: %s", conn.odbc_cursors);
    writefln("Packet Size: %s", conn.packet_size);
    writefln("Trace: %s", conn.trace);
    writefln("Tracefile: %s", conn.tracefile);
    writefln("Transaction Isolation: %s", conn.transaction_isolation);

    writeln("\n\n");
}
