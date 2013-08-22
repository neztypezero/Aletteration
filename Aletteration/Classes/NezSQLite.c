//
//  sqlite.c
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//
#include <stdio.h>
#include <stdlib.h>
#import <sqlite3.h>

int ExecSQLStatement(sqlite3 *database, const char *sql) {
    if (sqlite3_exec(database, sql, NULL, NULL, NULL) == SQLITE_OK) {
        return 0;
    } else {
        return 1;
    }
}

int CountSelectCallback(void *returnValue, int nColumns, char **values,char **columnNames) {
	if (nColumns == 1 && values[0] != NULL) {
		*((long*)returnValue) = strtol(values[0], NULL, 10);
	}
	return 0;
}
