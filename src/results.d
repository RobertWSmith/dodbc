module dodbc.results;

version (Windows) import core.sys.windows.windows;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;
import etc.c.odbc.sqltypes;
import etc.c.odbc.sqlucode;

version (Windows) pragma(lib, "odbc32");

import dodbc.types;
import dodbc.constants;
import dodbc.root;
import dodbc.connection;

import std.conv : to;
import std.string : toStringz;
import std.typecons : Nullable;

static import uuid = std.uuid;

