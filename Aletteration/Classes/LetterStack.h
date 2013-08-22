//
//  LetterStack.h
//  Aletteration
//
//  Created by David Nesbitt on 2/9/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezRectangle2D.h"
#import "Structures.h"
#import "NezVertexArray.h"

@class AletterationView, LetterBlock, NezAnimation;

@interface LetterStack : NSObject {
	vec3 midPoint;
	size3 letterBlockSize;
	char letter;

	NSMutableArray *letterBlockList;
	
	float nextZoffset;

	NezAnimation *countChangeAnimation;
	
	id animationStopDelegate;
	SEL animationStopSelector;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray letter:(char)theLetter midPoint:(vec3)pos size:(size3)size;

-(vec3)getNextLetterBlockPosition;
-(void)pushLetterBlock:(LetterBlock*)lb;

-(void)startFadeInAnimationWithDuration:(float)duration;
-(void)startFadeOutAnimationWithDuration:(float)duration;

-(void)startCountChangeAnimation;

-(void)startMoveToBoxAnimation:(float)duration Stage1Matrix:(mat4)matrix1 Stage2Matrix:(mat4)matrix2;

-(LetterBlock*)popLetterBlock;
-(BOOL)isFull;
-(int)getCount;

-(void)reset;

-(void)updateCounter;

-(BOOL)containsPoint:(vec4)point;

@property(nonatomic, readonly, getter = getCount) int count;
@property(nonatomic, readonly) NSMutableArray *letterBlockList;
@property (nonatomic, retain) NezRectangle2D *numberBox;

@property (nonatomic, retain) id animationStopDelegate;
@property (nonatomic, assign) SEL animationStopSelector;

@end
