//
//  AletterationPlayerInfo.h
//  Aletteration
//
//  Created by David Nesbitt on 5/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AletterationPlayerInfo : NSObject<NSCoding> {
	NSString *ip;
  	NSString *name;
	UIImage *portrait;

	NSArray *lineList;
	int turnIndex;
	BOOL gameOver;
	int rank;
	BOOL canStart;
	
	NSMutableArray *completedStringList;
}

@property(nonatomic,copy) NSString *ip;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,retain) UIImage *portrait;
@property(nonatomic,retain) NSArray *lineList;
@property(nonatomic,retain) NSMutableArray *completedWordIndexList;
@property(nonatomic,assign) int turnIndex;
@property(nonatomic,assign) BOOL gameOver;
@property(nonatomic,assign) BOOL canStart;
@property(nonatomic,assign) int rank;

@property(nonatomic,readonly,getter = getScore) int score;
@property(nonatomic,readonly,getter = getCompletedWordCount) int completedWordCount;
@property(nonatomic,readonly,getter = getCompletedWordList) NSArray *completedWordList;

+(AletterationPlayerInfo*)blankInfo;

-(void)setPortraitWithData:(NSData*)data;

-(void)addLetterToLine:(int)index forTurn:(int)turn;
-(void)completeWord:(int)row wordLength:(int)wordLength;

-(BOOL)isLetterUsed:(unichar)letter;

-(int)getLongestWordLength;

@end
