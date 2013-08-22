//
//  NezSQLite.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#ifndef Aletteration2_NezSQLite_h
#define Aletteration2_NezSQLite_h

#import <sqlite3.h>

#define DB_FILE_TYPE @"sqlite"
#define DB_FOLDER @"DB"

int ExecSQLStatement(sqlite3 *database, const char *sql);
int CountSelectCallback(void *returnValue, int nColumns, char **values,char **columnNames);

#endif
