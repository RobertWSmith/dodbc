module dodbc.transaction;

import dodbc.root;
import dodbc.connection;
import dodbc.cursor;

import std.uuid;

class Transaction
{
    private Connection _conn;
    private Cursor[] _crsr;
    private UUID _id;

    this(Connection conn, UUID id = randomUUID())
    {
        this.id = id;
        this.connection = conn;
        this.start();
    }

    ~this()
    {
        this.end();
    }

    public @property Connection connection()
    {
        return this._conn;
    }

    private @property void connection(Connection input)
    {
        this._conn = input;
    }

    public @property UUID id()
    {
        return this._id;
    }

    public @property void id(UUID input)
    {
        this._id = input;
    }

    bool start()
    {
        return false;
    }

    bool end()
    {
        return false;
    }

    bool commit()
    {
        return false;
    }

    bool rollback()
    {
        return false;
    }
}
