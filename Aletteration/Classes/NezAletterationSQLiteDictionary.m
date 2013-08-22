//
//  NezSQLiteDictionary.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAletterationSQLiteDictionary.h"
#import "NezSQLite.h"

#define DB_DIC_FILE_NAME @"words"

NezAletterationSQLiteDictionary *g_NezSQLiteDictionary;
sqlite3 *database;

@implementation NezAletterationSQLiteDictionary

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_NezSQLiteDictionary = [[NezAletterationSQLiteDictionary alloc] init];
    }
}

-(id)init {
	if ((self = [super init])) {
		NSString *resourcePath = [[NSBundle mainBundle] pathForResource:DB_DIC_FILE_NAME ofType:DB_FILE_TYPE inDirectory:DB_FOLDER];
		if (sqlite3_open([resourcePath UTF8String], &database) == SQLITE_OK) {
		} else {
			self = nil;
		}
	}
	return self;
}

+(NezAletterationDictionaryInputType)getTypeWithInput:(char*)ins LetterCounts:(NezAletterationLetterCounter)letterCounter {
	long prefixCount = [NezAletterationSQLiteDictionary getPrefixCountWithInput:ins LetterCounts:letterCounter];
	if (prefixCount > 0) {
		long wordCount = [NezAletterationSQLiteDictionary getWordCountWithInput:ins LetterCounts:letterCounter];
		if (wordCount == 1) {
			if (prefixCount == 1) {
				return NEZ_DIC_INPUT_ISWORD;
			} else {
				return NEZ_DIC_INPUT_ISBOTH;
			}
		}
		return NEZ_DIC_INPUT_ISPREFIX;
	}
	return NEZ_DIC_INPUT_ISNOTHING;
}

+(long)getPrefixCountWithInput:(char*)ins LetterCounts:(NezAletterationLetterCounter)letterCounter {
	long prefixCount = 0;
	int *letters = letterCounter.count;
	for (int i=0; ins[i]; i++) {
		letters[ins[i]-'a']++;
	}
	NSString *selectPrefixCountSQL = [NSString stringWithFormat:@"SELECT COUNT(word) FROM t_%c WHERE word LIKE '%s%%' AND count >= 4 AND a <= %d AND b <= %d AND c <= %d AND d <= %d AND e <= %d AND f <= %d AND g <= %d AND h <= %d AND i <= %d AND j <= %d AND k <= %d AND l <= %d AND m <= %d AND n <= %d AND o <= %d AND p <= %d AND q <= %d AND r <= %d AND s <= %d AND t <= %d AND u <= %d AND v <= %d AND w <= %d AND x <= %d AND y <= %d AND z <= %d;", ins[0], ins, letters[0], letters[1], letters[2], letters[3], letters[4], letters[5], letters[6], letters[7], letters[8], letters[9], letters[10], letters[11], letters[12], letters[13], letters[14], letters[15], letters[16], letters[17], letters[18], letters[19], letters[20], letters[21], letters[22], letters[23], letters[24], letters[25]];
	if (sqlite3_exec(database, [selectPrefixCountSQL UTF8String], CountSelectCallback, &prefixCount, NULL) == SQLITE_OK) {
		return prefixCount;
	}
	return -1;
}

+(long)getWordCountWithInput:(char*)ins LetterCounts:(NezAletterationLetterCounter)letterCounter {
	long wordCount = 0;
	int *letters = letterCounter.count;
	for (int i=0; ins[i]; i++) {
		letters[ins[i]-'a']++;
	}
	NSString *selectWordCountSQL = [NSString stringWithFormat:@"SELECT COUNT(word) FROM t_%c WHERE word = '%s' AND count >= 4 AND a <= %d AND b <= %d AND c <= %d AND d <= %d AND e <= %d AND f <= %d AND g <= %d AND h <= %d AND i <= %d AND j <= %d AND k <= %d AND l <= %d AND m <= %d AND n <= %d AND o <= %d AND p <= %d AND q <= %d AND r <= %d AND s <= %d AND t <= %d AND u <= %d AND v <= %d AND w <= %d AND x <= %d AND y <= %d AND z <= %d;", ins[0], ins, letters[0], letters[1], letters[2], letters[3], letters[4], letters[5], letters[6], letters[7], letters[8], letters[9], letters[10], letters[11], letters[12], letters[13], letters[14], letters[15], letters[16], letters[17], letters[18], letters[19], letters[20], letters[21], letters[22], letters[23], letters[24], letters[25]];
	if (sqlite3_exec(database, [selectWordCountSQL UTF8String], CountSelectCallback, &wordCount, NULL) == SQLITE_OK) {
		return wordCount;
	}
	return -1;
}

+(long)getWordsForwardForTable:(char)firstLetter FromWord:(const char*)startingWord Limit:(int)limit Callback:(SQLiteSelectCallback)callbackFunc CallbackArgument:(void*)arg {
	NSString *selectWordCountSQL = [NSString stringWithFormat:@"SELECT word FROM t_%c WHERE word > '%s' ORDER BY word LIMIT %d;", firstLetter, startingWord, limit];
	if (sqlite3_exec(database, [selectWordCountSQL UTF8String], callbackFunc, arg, NULL) == SQLITE_OK) {
		return 0;
	}
	return -1;
}

+(long)getWordsBackwardForTable:(char)firstLetter FromWord:(const char*)startingWord Limit:(int)limit Callback:(SQLiteSelectCallback)callbackFunc CallbackArgument:(void*)arg {
	NSString *selectWordCountSQL = [NSString stringWithFormat:@"SELECT word FROM t_%c WHERE word < '%s' ORDER BY word DESC LIMIT %d;", firstLetter, startingWord, limit];
	if (sqlite3_exec(database, [selectWordCountSQL UTF8String], callbackFunc, arg, NULL) == SQLITE_OK) {
		return 0;
	}
	return -1;
}

+(long)getWordCountForTable:(char)firstLetter {
	long wordCount = 0;
	NSString *selectWordCountSQL = [NSString stringWithFormat:@"SELECT COUNT(word) FROM t_%c;", firstLetter];
	if (sqlite3_exec(database, [selectWordCountSQL UTF8String], CountSelectCallback, &wordCount, NULL) == SQLITE_OK) {
		return wordCount;
	}
	return -1;
}

@end
