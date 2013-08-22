//
//  NezSQLiteHighScores.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

@interface NezAletterationSQLiteHighScoreItem : NSObject

@property (nonatomic, assign) int rowID;
@property (nonatomic, assign) int score;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *wordList;

+(NezAletterationSQLiteHighScoreItem*)itemWithRowID:(int)rowID Score:(int)score Name:(NSString*)name Date:(NSString*)date;
-(NezAletterationSQLiteHighScoreItem*)initWithRowID:(int)a_rowID Score:(int)a_score Name:(NSString*)a_name Date:(NSString*)a_date;

@end

@interface NezSQLiteHighScoreWord : NSObject

@property (nonatomic, assign) int rowID;
@property (nonatomic, assign) int scoreID;
@property (nonatomic, copy) NSString *word;

+(NezSQLiteHighScoreWord*)itemWithRowID:(int)rowID ScoreID:(int)score Word:(NSString*)name;
-(NezSQLiteHighScoreWord*)initWithRowID:(int)a_rowID ScoreID:(int)a_scoreID Word:(NSString *)a_word;

@end

@interface NezSQLiteHighScores : NSObject

+(NSArray*)getHighScoreListWithLimit:(int)topN;
+(NezAletterationSQLiteHighScoreItem*)getHighScoreWordListWithHighScoreItem:(NezAletterationSQLiteHighScoreItem*)hsi;
+(int)insertHighScoreWithPlayerName:(NSString*)playerName Score:(int)score WordList:(NSArray*)wordList;

@end
