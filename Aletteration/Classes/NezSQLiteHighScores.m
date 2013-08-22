//
//  NezSQLiteHighScores.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezSQLiteHighScores.h"
#import "NezSQLite.h"

int HighScoreSelectCallback(void *listPtr, int nColumns, char **values,char **columnNames) {
    NSMutableArray *hsList = (NSMutableArray*)listPtr;
    
    NSString *rowID = [NSString stringWithFormat:@"%s", values[0]];
    NSString *score = [NSString stringWithFormat:@"%s", values[1]];
    NSString *name = [NSString stringWithFormat:@"%s", values[2]];
    NSString *date = [NSString stringWithFormat:@"%s", values[3]];
    
    NezAletterationSQLiteHighScoreItem *hsi = [NezAletterationSQLiteHighScoreItem itemWithRowID:[rowID intValue] Score:[score intValue] Name:name Date:date];
    [hsList addObject:hsi];
    
	return 0;
}

int HighScoreWordSelectCallback(void *listPtr, int nColumns, char **values,char **columnNames) {
    NSMutableArray *hswList = (NSMutableArray*)listPtr;
    
    NSString *rowID = [NSString stringWithFormat:@"%s", values[0]];
    NSString *scoreID = [NSString stringWithFormat:@"%s", values[1]];
    NSString *word = [NSString stringWithFormat:@"%s", values[2]];
    
    NezSQLiteHighScoreWord *hsiw = [NezSQLiteHighScoreWord itemWithRowID:[rowID intValue] ScoreID:[scoreID intValue] Word:word];
    [hswList addObject:hsiw];
    
	return 0;
}

NezSQLiteHighScores *g_SQLiteHighScores;
sqlite3 *highScoreDatabase;

@implementation NezSQLiteHighScores

#define DB_HS_FILE_NAME @"highscores"

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_SQLiteHighScores = [[NezSQLiteHighScores alloc] init];
    }
}

-(id)init {
	if ((self = [super init])) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([paths count] > 0) {
			NSString *dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", DB_HS_FILE_NAME, DB_FILE_TYPE]];
			
			NSError *error;
			if (![fileManager fileExistsAtPath:dbPath]) {
				NSString *resourcePath = [[NSBundle mainBundle] pathForResource:DB_HS_FILE_NAME ofType:DB_FILE_TYPE inDirectory:DB_FOLDER];
				[fileManager copyItemAtPath:resourcePath toPath:dbPath error:&error];
			}
			if (sqlite3_open([dbPath UTF8String], &highScoreDatabase) == SQLITE_OK) {
			} else {
				self = nil;
			}
		}
	}
	return self;
}

+(NSArray*)getHighScoreListWithLimit:(int)topN {
    NSMutableArray *highScoreList = [NSMutableArray arrayWithCapacity:topN];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT ROWID,score,name,date(date, 'unixepoch', 'localtime') as date FROM t_highscores ORDER BY score DESC, date DESC, name LIMIT %d", topN];
    
    if (sqlite3_exec(highScoreDatabase, [sql UTF8String], HighScoreSelectCallback, (void*)highScoreList, NULL) == SQLITE_OK) {
        return highScoreList;
    } else {
        NSLog(@"%@", sql);
        return nil;
    }
}

+(NezAletterationSQLiteHighScoreItem*)getHighScoreWordListWithHighScoreItem:(NezAletterationSQLiteHighScoreItem*)hsi {
    hsi.wordList = [NSMutableArray arrayWithCapacity:16];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT ROWID,scoreid,word FROM t_hs_word_linker WHERE scoreid=%d ORDER BY word", hsi.rowID];
    
    if (sqlite3_exec(highScoreDatabase, [sql UTF8String], HighScoreWordSelectCallback, (void*)hsi.wordList, NULL) == SQLITE_OK) {
        return hsi;
    } else {
        NSLog(@"%@", sql);
        return nil;
    }
}

+(int)insertHighScoreWithPlayerName:(NSString*)playerName Score:(int)score WordList:(NSArray*)wordList {
    int error;
    error = ExecSQLStatement(highScoreDatabase, [[NSString stringWithFormat:@"BEGIN TRANSACTION;"] UTF8String]);
    if (!error) {
        error = ExecSQLStatement(highScoreDatabase, [[NSString stringWithFormat:@"INSERT INTO t_highscores(score,date,name) values('%d',strftime('%%s','now'),'%@');", score, playerName] UTF8String]);
        
        if (!error) {
            long sequence = 0;
            NSString *selectSequence = [NSString stringWithFormat:@"SELECT seq FROM sqlite_sequence WHERE name = 't_highscores'"];
            if (sqlite3_exec(highScoreDatabase, [selectSequence UTF8String], CountSelectCallback, &sequence, NULL) == SQLITE_OK) {
                for (NSString *word in wordList) {
                    error = ExecSQLStatement(highScoreDatabase, [[NSString stringWithFormat:@"INSERT INTO t_hs_word_linker(scoreid, word) values('%ld', '%@');", sequence, word] UTF8String]);
                    if (error) {
                        break;
                    }
                }
            } else {
                error = 1;
            }
        }
    }
    if (!error) {
        error = ExecSQLStatement(highScoreDatabase, [[NSString stringWithFormat:@"END TRANSACTION;"] UTF8String]);
    } else {
        error = ExecSQLStatement(highScoreDatabase, [[NSString stringWithFormat:@"ROLLBACK;"] UTF8String]);
    }
	return error;
}

-(void)dealloc {
	sqlite3_close(highScoreDatabase);
	[super dealloc];
}

@end

@implementation NezAletterationSQLiteHighScoreItem

+(NezAletterationSQLiteHighScoreItem*)itemWithRowID:(int)rowID Score:(int)score Name:(NSString*)name Date:(NSString*)date {
    return [[NezAletterationSQLiteHighScoreItem alloc] initWithRowID:rowID Score:score Name:name Date:date];
}

-(NezAletterationSQLiteHighScoreItem*)initWithRowID:(int)rowID Score:(int)score Name:(NSString*)name Date:(NSString*)date {
    if ((self = [self init])) {
        self.rowID = rowID;
        self.score = score;
        self.name = name;
        self.date = date;
        self.wordList = nil;
    }
    return self;
}

@end

@implementation NezSQLiteHighScoreWord

+(NezSQLiteHighScoreWord*)itemWithRowID:(int)rowID ScoreID:(int)scoreID Word:(NSString *)word {
    return [[NezSQLiteHighScoreWord alloc] initWithRowID:rowID ScoreID:scoreID Word:word];
}

-(NezSQLiteHighScoreWord*)initWithRowID:(int)rowID ScoreID:(int)scoreID Word:(NSString *)word {
    if ((self = [self init])) {
        self.rowID = rowID;
        self.scoreID = scoreID;
        self.word = word;
    }
    return self;
}

@end
