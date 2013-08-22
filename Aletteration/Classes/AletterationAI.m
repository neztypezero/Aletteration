//
//  AletterationAI.m
//  Aletteration
//
//  Created by David Nesbitt on 2/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationAI.h"

typedef struct PrioritizationBlock {
	int length;
	int count;
	int score;
} PrioritizationBlock;
 
@implementation AletterationAI

-(id)initWithGameState:(AletterationGameState*)gs {
	if ((self = [super init])) {
		gameState = [gs retain];
		junkLine = -1;
	}
	return self;
}

-(int)pickLineForCurrentState {
	PrioritizationBlock priori[LINE_COUNT];
	
	int currentBestScore = 0;
	int currentBestLineIndex = junkLine;
	for (int i=0; i<LINE_COUNT; i++) {
		priori[i].score = priori[i].count+priori[i].length*5000;
	}
	for (int i=0; i<LINE_COUNT; i++) {
		if (priori[i].count > 0 && i != junkLine) {
			if (priori[i].score >= currentBestScore) {
				currentBestLineIndex = i;
				currentBestScore = priori[i].score;
			}
		}
	}
	if (currentBestLineIndex == -1) {
		for (int i=0; i<LINE_COUNT; i++) {
			if (priori[i].score >= currentBestScore) {
				currentBestScore = priori[i].score;
			}
		}
		for (int i=0; i<LINE_COUNT; i++) {
			if (priori[i].score <= currentBestScore) {
				currentBestLineIndex = i;
				currentBestScore = priori[i].score;
			}
		}
//		junkLine = currentBestLineIndex;
	}
	return currentBestLineIndex;
}

-(void)dealloc {
	[gameState release];
	[super dealloc];
}

@end
