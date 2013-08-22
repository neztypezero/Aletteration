//
//  AletterationPlayerInfo.m
//  Aletteration
//
//  Created by David Nesbitt on 5/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationPlayerInfo.h"
#import "AletterationGameState.h"
#import "LetterBlock.h"
#import <objc/runtime.h>

@implementation AletterationPlayerInfo

@synthesize ip;
@synthesize name;
@synthesize portrait;
@synthesize lineList;
@synthesize completedWordIndexList;
@synthesize turnIndex;
@synthesize gameOver;
@synthesize rank;
@synthesize canStart;

+(AletterationPlayerInfo*)blankInfo {
	return [[[AletterationPlayerInfo alloc] init] autorelease];
}

-(id)init {
	if((self = [super init])) {
		ip = nil;
		name = nil;
		portrait = nil;
		self.lineList = [NSArray arrayWithObjects:
            [NSMutableArray arrayWithCapacity:25], 
            [NSMutableArray arrayWithCapacity:25], 
            [NSMutableArray arrayWithCapacity:25], 
            [NSMutableArray arrayWithCapacity:25], 
            [NSMutableArray arrayWithCapacity:25], 
            [NSMutableArray arrayWithCapacity:25], 
            nil
        ];
		self.completedWordIndexList = [NSMutableArray arrayWithCapacity:25];
		
		completedStringList = nil;
		
		turnIndex = 0;
		gameOver = NO;
		rank = -1;
		canStart = NO;
	}
	return self;
}

-(void)setPortraitWithData:(NSData*)data {
	CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef image = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
	self.portrait = [UIImage imageWithCGImage:image];
	CGImageRelease(image);
	CGDataProviderRelease(imgDataProvider);
}

-(void)addLetterToLine:(int)index forTurn:(int)turn {
	if(index >= 0 && index < 6 && turnIndex == turn) {
        NSMutableArray *line = [lineList objectAtIndex:index];
        [line addObject:[NSNumber numberWithInt:turn]];
		turnIndex++;
	}
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
	if(ip != nil) {
		[aCoder encodeObject:ip forKey: @"ip"];
	}
	if(name != nil) {
		[aCoder encodeObject:name forKey: @"name"];
	}
	if(portrait != nil) {
		NSData *data = UIImageJPEGRepresentation(self.portrait, 1.0);
		[aCoder encodeObject:data forKey: @"portrait"];
	}
	[aCoder encodeObject:lineList forKey: @"lineList"];
	[aCoder encodeObject:completedWordIndexList forKey: @"completedWordList"];
	[aCoder encodeInt:turnIndex forKey:@"turnIndex"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super init])) {
		self.ip = [aDecoder decodeObjectForKey:@"ip"];
		self.name = [aDecoder decodeObjectForKey:@"name"];
		NSData *data = [[aDecoder decodeObjectForKey:@"portrait"] retain];
		if (data != nil) {
			[self setPortraitWithData:data];
		}
		[data release];
		self.lineList = [aDecoder decodeObjectForKey:@"lineList"];
		self.completedWordIndexList = [aDecoder decodeObjectForKey:@"completedWordList"];
		self.turnIndex = [aDecoder decodeIntegerForKey:@"turnIndex"];
		gameOver = NO;
		rank = -1;
	}
	return self;
}

-(int)getLongestWordLength {
	if(self.completedWordIndexList != nil) {
		int longestWordLength = 0;
		if ([self.completedWordIndexList count] > 0) {
			for (NSArray *indexArray in self.completedWordIndexList) {
				if (longestWordLength < [indexArray count]) {
					longestWordLength = [indexArray count];
				}
			}
		}
		return longestWordLength;
	}
	return 0;
}

-(NSArray*)getCompletedWordList {
	if(self.completedWordIndexList != nil) {
		if (completedStringList == nil) {
			completedStringList = [[NSMutableArray alloc] initWithCapacity:25];
		}
		if ([self.completedWordIndexList count] > 0 && [self.completedWordIndexList count] != [completedStringList count]) {
			[completedStringList removeAllObjects];
			char wordChars[91];
			AletterationGameState *gameState = [AletterationGameState instance];
			for (NSArray *indexArray in self.completedWordIndexList) {
				int i=0;
				for (NSNumber *index in indexArray) {
					LetterBlock *lb = [gameState.inGameLetterList objectAtIndex:[index intValue]];
					wordChars[i++] = lb.letter;
				}
				wordChars[i] = '\0';
				[completedStringList addObject:[NSString stringWithFormat:@"%s", wordChars]];
			}
		}
		return completedStringList;
	}
	return [NSArray arrayWithObjects: nil];
}

-(int)getScore {
	int score = 0;
	int bonusLetterCount = 0;
	int longestWordLength = 0;
	int longestWordCount = 0;
	
	if(self.completedWordIndexList != nil) {
		if ([self.completedWordIndexList count] > 0) {
			AletterationGameState *gameState = [AletterationGameState instance];
			for (NSArray *indexArray in self.completedWordIndexList) {
				int wordLength = [indexArray count];
				score += wordLength-3;
				for (NSNumber *index in indexArray) {
					LetterBlock *lb = [gameState.inGameLetterList objectAtIndex:[index intValue]];
					char c = lb.letter;
					if (c == 'j' || c == 'q' || c == 'x' || c == 'z') {
						bonusLetterCount++;
					}
				}
				if (wordLength > 7) {
					if (longestWordLength < wordLength) {
						longestWordLength = wordLength;
						longestWordCount = 1;
					} else if (longestWordLength == wordLength) {
						longestWordCount++;
					}
				}
			}
		}
	}
	if (bonusLetterCount == 4) {
		bonusLetterCount++;
	}
	return score+bonusLetterCount+(longestWordCount*2);
}

-(BOOL)isLetterUsed:(unichar)letter {
	if(self.completedWordIndexList != nil) {
		if ([self.completedWordIndexList count] > 0) {
			AletterationGameState *gameState = [AletterationGameState instance];
			for (NSArray *indexArray in self.completedWordIndexList) {
				for (NSNumber *index in indexArray) {
					LetterBlock *lb = [gameState.inGameLetterList objectAtIndex:[index intValue]];
					if (lb.letter == letter) {
						return YES;
					}
				}
			}
		}
	}
	return NO;
}

-(void)completeWord:(int)row wordLength:(int)wordLength {
	NSMutableArray *lineArray = [lineList objectAtIndex:row];
	NSRange range = NSMakeRange([lineArray count]-wordLength, wordLength);
	NSArray *line = [lineArray subarrayWithRange:range];
	[lineArray removeObjectsInRange:range];
	
	char wordChars[91];
	AletterationGameState *gameState = [AletterationGameState instance];
	int i=0;
	for (NSNumber *index in line) {
		LetterBlock *lb = [gameState.inGameLetterList objectAtIndex:[index intValue]];
		wordChars[i++] = lb.letter;
	}
	wordChars[i] = '\0';
	[self.completedWordIndexList addObject:line];
}

-(int)getCompletedWordCount {
	if(self.completedWordIndexList != nil) {
		return [self.completedWordIndexList count];
	} else {
		return 0;
	}
}

-(void)dealloc {
	self.ip = nil;
	self.name = nil;
	self.portrait = nil;
	self.lineList = nil;
	self.completedWordIndexList = nil;
	if (completedStringList != nil) {
		[completedStringList release];
	}
	[super dealloc];
}

@end
