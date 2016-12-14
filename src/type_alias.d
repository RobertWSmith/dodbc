module dodbc.type_alias;

public import etc.c.odbc.sql;
public import etc.c.odbc.sqlext;
public import etc.c.odbc.sqltypes;

version (Windows) pragma(lib, "odbc32");

import core.stdc.config;

alias handle_t = SQLHANDLE;
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
