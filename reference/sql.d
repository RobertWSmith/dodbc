/* Converted to D from sql.h by htod */
module sql;
//-----------------------------------------------------------------------------
// File:            sql.h
//
// Copyright:       Copyright (c) Microsoft Corporation
//
// Contents:        This is the the main include for ODBC Core functions.
//
// Comments:        preconditions: #include "windows.h"
//
//-----------------------------------------------------------------------------

//C     #ifndef __SQL
//C     #define __SQL

/*
* ODBCVER  Default to ODBC version number (0x0380).   To exclude
*          definitions introduced in version 3.8 (or above)
*          #define ODBCVER 0x0351 before #including <sql.h>
*/
//C     #ifndef ODBCVER
//C     #define ODBCVER 0x0380
//C     #endif
const ODBCVER = 0x0380;

//C     #ifndef __SQLTYPES
//C     #include "sqltypes.h"
import sqltypes;
