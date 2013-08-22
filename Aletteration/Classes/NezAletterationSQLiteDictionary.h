//
//  NezSQLiteDictionary.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <sqlite3.h>

typedef union NezAletterationLetterCounter {
	int count[26];
} NezAletterationLetterCounter;

typedef enum NezAletterationDictionaryInputType {
	NEZ_DIC_INPUT_ISNOT_SET,
	NEZ_DIC_INPUT_ISNOTHING,
	NEZ_DIC_INPUT_ISPREFIX,
	NEZ_DIC_INPUT_ISWORD,
	NEZ_DIC_INPUT_ISBOTH,
	NEZ_DIC_INPUT_IS_NO_MORE,
} NezAletterationDictionaryInputType;

typedef struct InputLength {
	int prefixIndex;
	int prefixLength;
} InputLength;

typedef int (*SQLiteSelectCallback)(void*,int,char**,char**);

static const InputLength INPUT_ZERO = { 0,0 };

@interface NezAletterationSQLiteDictionary : NSObject

+(NezAletterationDictionaryInputType)getTypeWithInput:(char*)inputString LetterCounts:(NezAletterationLetterCounter)letterCounter;
+(long)getPrefixCountWithInput:(char*)ins LetterCounts:(NezAletterationLetterCounter)letterCounter;
+(long)getWordCountWithInput:(char*)ins LetterCounts:(NezAletterationLetterCounter)letterCounter;

+(long)getWordCountForTable:(char)firstLetter;
+(long)getWordsForwardForTable:(char)firstLetter FromWord:(const char*)startingWord Limit:(int)limit Callback:(SQLiteSelectCallback)callbackFunc CallbackArgument:(void*)arg;
+(long)getWordsBackwardForTable:(char)firstLetter FromWord:(const char*)startingWord Limit:(int)limit Callback:(SQLiteSelectCallback)callbackFunc CallbackArgument:(void*)arg;

@end
