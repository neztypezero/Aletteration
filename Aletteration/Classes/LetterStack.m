//
//  LetterStack.m
//  Aletteration
//
//  Created by David Nesbitt on 2/9/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "LetterStack.h"
#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "LetterBlock.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "Math.h"

static const color4uc COLOR_TRANSPARENT = {255, 0, 0, 255};

#define NUMBER_SQUARE_SCALE 0.5f

@implementation LetterStack

@synthesize letterBlockList;
@synthesize animationStopDelegate;
@synthesize animationStopSelector;

-(id)initWithVertexArray:(NezVertexArray*)vertexArray letter:(char)theLetter midPoint:(vec3)pos size:(size3)size {
	if ((self = [super init])) {
		animationStopDelegate = nil;
		animationStopSelector = nil;
		
		letter = theLetter;
		midPoint = pos;
		
		nextZoffset = 0;
		letterBlockSize = size;
		
		letterBlockList = [[NSMutableArray arrayWithCapacity:[[AletterationGameState instance] getNumberForLetter:letter]] retain];

		mat4 mat = {
			{size.w*NUMBER_SQUARE_SCALE, 0.0, 0.0, 0.0}, // x column
			{0.0, size.h*NUMBER_SQUARE_SCALE, 0.0, 0.0}, // y column
			{0.0, 0.0, 1.0, 0.0}, // z column
			{midPoint.x, midPoint.y-size.h*.95, midPoint.z-size.d, 1.0}, // w column
		};
		self.numberBox = [[NezRectangle2D alloc] initWithVertexArray:vertexArray modelMatrix:mat color:COLOR_TRANSPARENT];
		[self.numberBox setUV:[[AletterationGameState instance] getTextureCoordinatesForNumber:0]];
		[self.numberBox setMix:0.0];
	}
	return self;
}

-(vec3)getNextLetterBlockPosition {
//	float maxJitter = letterBlockSize.w/16.0f;
//	float halfMaxJitter = maxJitter/2.0f;
			
	vec3 p = {
		midPoint.x,
		midPoint.y,
		midPoint.z+nextZoffset+letterBlockSize.d/2.0f
	};
	nextZoffset += letterBlockSize.d;
	return p;
}

-(void)pushLetterBlock:(LetterBlock*)lb {
	[letterBlockList addObject:lb];
	[self.numberBox setUV:[[AletterationGameState instance] getTextureCoordinatesForNumber:[letterBlockList count]]];
}

-(LetterBlock*)popLetterBlock {
	if ([letterBlockList count] > 0) {
		LetterBlock *lb = [[letterBlockList lastObject] retain];
		[letterBlockList removeLastObject];
		return lb;
	}
	return nil;
}

-(void)startFadeInAnimationWithDuration:(float)duration {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:duration EasingFunction:easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateFade:) DidStopSelector:@selector(animateFadeDidStop:)];
	[[NezAnimator instance] addAnimation:ani];
}

-(void)startFadeOutAnimationWithDuration:(float)duration {
	if (self.numberBox.mix > 0) {
		NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:self.numberBox.mix ToData:0.0 Duration:duration EasingFunction:easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateFade:) DidStopSelector:@selector(animateFadeDidStop:)];
		[[NezAnimator instance] addAnimation:ani];
	}
}

-(void)animateFade:(NezAnimation*)ani {
	[self.numberBox setMix:ani->newData[0]];
}

-(void)animateFadeDidStop:(NezAnimation*)ani {
	[ani release];
	if (animationStopDelegate != nil && animationStopSelector != nil) {
		[animationStopDelegate performSelector:animationStopSelector withObject:self];
	}
}

-(void)startCountChangeAnimation {
	if (countChangeAnimation == nil) {
		vec2 from = {
			1.0,
			1.0,
		};
		vec2 to = {
			0.0,
			2.0,
		};
		countChangeAnimation = [[NezAnimation alloc] initVec2WithFromData:from ToData:to Duration:0.3 EasingFunction:easeInCubic CallbackObject:self UpdateSelector:@selector(animateCountChange:) DidStopSelector:@selector(animateCountChangeDidStop:)];
		[[NezAnimator instance] addAnimation:countChangeAnimation];
	}
}

-(void)animateCountChange:(NezAnimation*)ani {
	[self.numberBox setMix:ani->newData[0]];
	[self.numberBox setScale:letterBlockSize.w*ani->newData[1]*NUMBER_SQUARE_SCALE];
}

-(void)updateCounter {
	if ([letterBlockList count] == 0) {
		[self.numberBox setScale:0.01];
	} else {
		[self.numberBox setUV:[[AletterationGameState instance] getTextureCoordinatesForNumber:[letterBlockList count]]];
	}
}

-(void)animateCountChangeDidStop:(NezAnimation*)ani {
	[countChangeAnimation release];
	if ([letterBlockList count] == 0) {
		countChangeAnimation = nil;
		[self.numberBox setScale:0.01];
	} else {
		[self updateCounter];
		vec2 from = {
			0.0,
			2.0,
		};
		vec2 to = {
			1.0,
			1.0,
		};
		countChangeAnimation = [[NezAnimation alloc] initVec2WithFromData:from ToData:to Duration:0.3 EasingFunction:easeOutCubic CallbackObject:self UpdateSelector:@selector(animateCountChange:) DidStopSelector:@selector(animateCountChangeDidStop2:)];
		[[NezAnimator instance] addAnimation:countChangeAnimation];
	}

}

-(void)animateCountChangeDidStop2:(NezAnimation*)ani {
	[countChangeAnimation release];
	countChangeAnimation = nil;
	if (animationStopDelegate != nil && animationStopSelector != nil) {
		[animationStopDelegate performSelector:animationStopSelector withObject:self];
	}
}

-(void)startMoveToBoxAnimation:(float)duration Stage1Matrix:(mat4)matrix1 Stage2Matrix:(mat4)matrix2 {
	mat4 mat = IDENTITY_MATRIX;
	mat.w.x = midPoint.x;
	mat.w.y = midPoint.y;
	mat.w.z = midPoint.z;
	
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&mat.x.x ToData:&matrix1.x.x DataLength:sizeof(mat4) Duration:duration/2.0 EasingFunction:&easeOutCubic CallbackObject:self UpdateSelector:@selector(animateMoveToBox:) DidStopSelector:@selector(animateMoveToBoxDidStop1:)];
	ani->chainLink = [[NezAnimation alloc] initWithFromData:&matrix1.x.x ToData:&matrix2.x.x DataLength:sizeof(mat4) Duration:duration/2.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateMoveToBox:) DidStopSelector:@selector(animateMoveToBoxDidStop2:)];
	[[NezAnimator instance] addAnimation:ani];
}

-(void)animateMoveToBox:(NezAnimation*)ani {
	float depth = [[AletterationGameState instance] getBlockDepth];
	mat4 offsetMatrix = IDENTITY_MATRIX;
	offsetMatrix.w.z = ([letterBlockList count]-1)*depth;
	mat4 *mat = (mat4*)ani->newData;
	
	for (LetterBlock *lb in letterBlockList) {
		mat4 lbMat;
		MatrixMultiply(mat, &offsetMatrix, &lbMat);
		[lb setModelMaxtrix:&lbMat];
		offsetMatrix.w.z -= depth;
	}
}

-(void)animateMoveToBoxDidStop1:(NezAnimation*)ani {
	[ani release];
}

-(void)animateMoveToBoxDidStop2:(NezAnimation*)ani {
	[ani release];
	if (animationStopDelegate != nil && animationStopSelector != nil) {
		[animationStopDelegate performSelector:animationStopSelector withObject:self];
	}
}

-(BOOL)isFull {
	return([letterBlockList count] == [[AletterationGameState instance] getCountForLetter:letter]);
}

-(int)getCount {
	return [letterBlockList count];
}

-(void)reset {
	[letterBlockList removeAllObjects];
	[self.numberBox setUV:[[AletterationGameState instance] getTextureCoordinatesForNumber:0]];
	[self.numberBox setMix:0.0];
	[self.numberBox setScale:letterBlockSize.w*NUMBER_SQUARE_SCALE];
	nextZoffset = 0;
}

-(BOOL)containsPoint:(vec4)point {
	if ([letterBlockList count] > 0) {
		LetterBlock *lb = [letterBlockList objectAtIndex:0];
		return [lb containsPoint:point];
	}
	return NO;
}

-(void)dealloc {
	//NSLog(@"dealloc:LetterStack");
	[letterBlockList removeAllObjects];
	[letterBlockList release];
	self.numberBox = nil;
	[super dealloc];
}

@end
