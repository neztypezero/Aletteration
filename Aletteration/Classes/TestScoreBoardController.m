//
//  TestScoreBoardController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-09-24.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "TestScoreBoardController.h"
#import "AletterationGameState.h"
#import "LetterBlock.h"
#import "LetterStack.h"
#import "ScoreBoard.h"

char wordList[][16] = {
/*	"jelutong",
	"esurient",
	"tummy",
	"odeon",
	"quarrelling",
	"drapes",
	"oven",
	"wharf",
	"diva",
	"zestiest",
	"exam",
*/
	"plod",
	"trecento",
	"yearly",
	"flaunted",
	"sashes",
	"ajar",
	"queries",
	"rhodium",
	"kepi",
	"monthlies",
	"unzip",
};

@implementation TestScoreBoardController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)layoutStacksAnimationDidStop {
	float blockLength = gameState.blockLength; 
	
	[gameState setNextTurn];
	for (int i=0; i<sizeof(wordList)/sizeof(wordList[0]); i++) {
		NSMutableArray *word = [NSMutableArray arrayWithCapacity:16];
		int j=0;
		vec3 midPoint = [gameState.scoreBoard getScoreBoardPoint:i];
		while (wordList[i][j] != '\0') {
			LetterBlock *lb = [[gameState getStackForLetter:wordList[i][j]] popLetterBlock];
			[word addObject:lb];
			[lb setBoxWithMidPoint:&midPoint];
			midPoint.x += blockLength;
			[gameState.inGameLetterList addObject:lb];
			[gameState.localPlayerInfo addLetterToLine:0 forTurn:gameState.currentTurn];
			[gameState setNextTurn];

			j++;
		}
		[gameState.completedWordBlockList addObject:word];
		[gameState.localPlayerInfo completeWord:0 wordLength:[word count]];
	}
	[self doGameOver];
}

@end
