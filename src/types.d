module dodbc.types;

version (Windows) public import core.sys.windows.windows;

public import etc.c.odbc.sql;
public import etc.c.odbc.sqlext;
public import etc.c.odbc.sqltypes;
public import etc.c.odbc.sqlucode;

version (Windows) pragma(lib, "odbc32");

import std.meta;
import std.traits;
import std.variant;

import core.stdc.config;

/// ODBC Handle Type alias
alias handle_t = SQLHANDLE;

/// ODBC opaque pointer type 
alias pointer_t = SQLPOINTER;

version (X86_64)
{
    alias SQLULEN = ulong;
    alias SQLLEN = long;
    alias BOOKMARK = SQLULEN;
}
else
{
    alias SQLULEN = uint;
    alias SQLLEN = int;
    alias BOOKMARK = SQLULEN;
}

//private enum comp(alias a, alias b) = (a).sizeof < (b).sizeof;

// dfmt off

// /// Sequence of Variant aliases to 
public alias SQLAliasSequence = 
    NoDuplicates!(
        AliasSeq!(
            SQLCHAR, SQLCHAR[],
            SQLWCHAR, SQLWCHAR[],
            SQLSMALLINT,  
            SQLUSMALLINT, 
            SQLINTEGER, 
            SQLUINTEGER,  
            SQLREAL,  
            SQLDOUBLE, 
            BOOKMARK, 
            // SQLBIGINT, 
            // SQLUBIGINT,
            SQL_DATE_STRUCT,
            SQL_TIME_STRUCT,  
            SQL_NUMERIC_STRUCT, 
            SQLGUID,  
            SQL_INTERVAL_STRUCT
        )
    );
// dfmt on

public alias SQLAlgebraic = Algebraic!(SQLAliasSequence);
public alias SQLVariant = Variant;

unittest
{
    import std.stdio;

    writefln("Max alias_seq size:      %s", maxSize!SQLAliasSequence);
}

//struct Bytes
//{
//    private ubyte[] _buffer;
//    private IMPL impl;
//
//    public this(size_t sz)
//    {
//        this.impl = IMPL(sz);
//    }
//
//    @disable this(this);
//
//    @property ubyte[] buffer()
//    {
//        return this._buffer;
//    }
//
//    @property void buffer(ubyte[] input)
//    {
//        long diff = input.length - this._buffer.length;
//
//        if (diff == 0 || diff < 0)
//        {
//            this._buffer[] = ubyte.init;
//            foreach (size_t ix, ubyte d; input)
//                this._buffer[iz] = d;
//        }
//        else
//        {
//            this._buffer = input.dup;
//        }
//    }
//}

//unittest
//{
//    ubyte[] data = new ubyte[8];
//    Bytes b = new Bytes();
//    Bytes c = new Bytes(data);
//}

//alias char_type = ubyte;
//alias schar_type = byte;

//alias date_type = char_type;
//alias time_type = char_type;
//alias timestamp_type = char_type;
//alias varchar_type = char_type;

//alias decimal_type = char_type;
//alias numeric_type = char_type;

//alias double_type = double;
//alias float_type = double;
//alias real_type = float;

//alias small_integer_type = short;
//alias usmall_integer_type = ushort;
//alias integer_type = c_long;
//alias uinteger_type = c_ulong;

//alias return_type = small_integer_type;

//alias len = integer_type;
//alias ulen = uinteger_type;
//alias row_position = small_integer_type;

//alias date_struct = DATE_STRUCT;
//alias time_struct = TIME_STRUCT;
//alias timestamp_struct = TIMESTAMP_STRUCT;
