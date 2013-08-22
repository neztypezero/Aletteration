//
//  AletterationBox.h
//  Aletteration
//
//  Created by David Nesbitt on 2/8/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"
#import "AletterationGameState.h"
#import "NezGeometry.h"

@class AletterationView, LetterBlock, SimpleObjLoader, AletterationBoxGeometry;

@interface AletterationBox : NSObject {
	size3 dimensions;
	
	AletterationBoxGeometry *lid;
	AletterationBoxGeometry *box;
	
	size3 letterBlockSize;
	NSMutableArray *lettersList;
	mat4 letterModelMatrix[TOTAL_LETTER_COUNT];
	mat4 originalBoxMatrix;
	mat4 originalLidMatrix;
	
	int currentAnimatingCount;
	id blocksFinishedDelegate;
	SEL blocksFinishedSelector;
	
	int stackToBoxCount;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray LetterList:(NSArray*)letterList midPoint:(vec3)pos boxColor:(color4uc)c;

-(void)layoutStacks;
-(void)layoutStacksAnimation:(id)finishedDelegate finishedSelector:(SEL)finishedSelector;
-(void)animateLetterBlockDidStop:(LetterBlock*)lb;

-(mat4)getResetStage1BoxMatrix;

-(void)resetAnimation:(id)finishedDelegate finishedSelector:(SEL)finishedSelector;

-(void)startMoveStacksToBoxAnimation:(float)duration;

-(void)setColor:(color4uc)color;

@property(nonatomic, readonly, assign) size3 letterBlockSize;

@end
