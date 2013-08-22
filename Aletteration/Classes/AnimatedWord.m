//
//  AnimatedWord.m
//  Aletteration
//
//  Created by David Nesbitt on 2/15/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AnimatedWord.h"
#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "LetterBlock.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "ScoreBoard.h"
#import "AnimatedCamera.h"
#import "NezCamera.h"
#import "DisplayLine.h"
#import "NezOpenAL.h"
#import "NezCubicBezierAnimation.h"
#import "NezCubicBezier.h"


@interface AnimatedWord (private)

-(void)trackMidPoint;

-(void)animatingUp:(NezAnimation*)ani;
-(void)animatingDidFinish:(NezAnimation*)ani;
-(void)animatingToScoreBoard:(NezAnimation*)ani;
-(void)animatingToScoreBoardDidFinish:(NezAnimation*)ani;
-(void)startAnimatingToDefault;

@end

@implementation AnimatedWord

@synthesize leterBlockArray;
@synthesize doesCameraTracking;

-(id)init {
	if ((self = [super init])) {
		leterBlockArray = nil;
		gameState = [AletterationGameState instance];
		doesCameraTracking = YES;
	}
	return self;
}

-(void)trackMidPoint {
	if (!doesCameraTracking) {
		return;
	}
	int count = [leterBlockArray count];
	vec3 midPoint;
	if (count&1) { // odd number of letters
		LetterBlock *lb = [leterBlockArray objectAtIndex:count/2];
		midPoint = [lb getMidPoint];
	} else {
		LetterBlock *lb1 = [leterBlockArray objectAtIndex:count/2];
		vec3 mp1 = [lb1 getMidPoint];
		LetterBlock *lb2 = [leterBlockArray objectAtIndex:1+count/2];
		vec3 mp2 = [lb2 getMidPoint];
		midPoint.x = (mp1.x+mp2.x)/2.0f;
		midPoint.y = (mp1.y+mp2.y)/2.0f;
		midPoint.z = (mp1.z+mp2.z)/2.0f;
	}
	NezCamera *camera = [OpenGLES2Graphics instance].camera;
	vec3 camEye = [camera getEye];
	camEye.x = midPoint.x;
	camEye.y = midPoint.y;
	//camEye.z = midPoint.z;
	float eyeRatio = (1.0f/16.0f);
	float targetRatio = (1.0f/4.0f);
	
	if(remainingDistance > 0.25) {
		remainingDistance = [camera movePartialWithEyePos:&camEye EyeRatio:eyeRatio Target:&midPoint TargetRatio:targetRatio];
	} else {
		remainingDistance = [camera movePartialWithEyePos:&camEye EyeRatio:0.5 Target:&midPoint TargetRatio:0.5];
	}
	BOOL done = (remainingDistance < 0.01);
	if (done) {
		[camera setEye:camEye andTarget:midPoint];
	}
	[[OpenGLES2Graphics instance] setupMatricesQuick];
	return;
}

-(void)startAnimatingToScoreBoard:(id)delegate finishedSelector:(SEL)selector {
	finishedDelegate = delegate;
	finishedSelector = selector;
	remainingDistance = 1;
	int count = [leterBlockArray count];
	if (count > 0) {
		LetterBlock *lb = [leterBlockArray objectAtIndex:0];
		vec3 from = [lb getMidPoint];
		vec3 to = { from.x,from.y,from.z+2.5 };
		NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:from.z ToData:to.z Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animatingUp:) DidStopSelector:@selector(animatingDidFinish:)];
		
		vec3 midPoint = [[AletterationGameState instance].scoreBoard getScoreBoardPoint:[gameState.completedWordBlockList count]];
		
		ani->chainLink = [[NezAnimation alloc] initVec3WithFromData:to ToData:midPoint Duration:1.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animatingToScoreBoard:) DidStopSelector:@selector(animatingToScoreBoardDidFinish:)];

		[[NezAnimator instance] addAnimation:ani];
		[gameState.soundPlayer playSound:gameState.sounds->wordMove gain:1.0 pitch:1.0 loops:NO];
		[gameState.completedWordBlockList addObject:leterBlockArray];
	}
}

-(void)animatingUp:(NezAnimation*)ani {
	float z = ani->newData[0];
	for (LetterBlock *lb in leterBlockArray) {
		[lb offsetWithDX:0 DY:0 DZ:z-[lb getMidPoint].z];
	}
	[self trackMidPoint];
}

-(void)animatingDidFinish:(NezAnimation*)ani {
	[ani release];
}

-(void)animatingToScoreBoard:(NezAnimation*)ani {
	vec3 *midPoint = (vec3*)ani->newData;
	float blockLength = [AletterationGameState instance].blockLength; 
	for (LetterBlock *lb in leterBlockArray) {
		[lb setBoxWithMidPoint:midPoint];
		midPoint->x += blockLength;
	}
	[self trackMidPoint];
}

-(void)animatingToScoreBoardDidStop:(NezAnimation*)ani {
	[ani release];
	//NSLog(@"stopped!");
}

-(void)animatingToScoreBoardDidFinish:(NezAnimation*)ani {
	//NSLog(@"AnimatedWord:animatingToScoreBoardDidFinish");
	if (leterBlockArray) {
		self.leterBlockArray = nil;
//		if (gameState.isGameCompletelyOver) {
//			//NSLog(@"AnimatedWord:gameState.isGameCompletelyOver:%d %d", (int)finishedDelegate, (int)finishedSelector);
//			[finishedDelegate performSelector:finishedSelector];
//		} else {
			//NSLog(@"AnimatedWord:startAnimatingToDefault");
			[self startAnimatingToDefault];
//		}
	}
	[ani release];
}

-(void)startAnimatingToDefault {
	vec3 from = [[OpenGLES2Graphics instance].camera getTarget];
	vec3 to = {0, 0, 0};
	
	targetToDefaultAni = [[NezAnimation alloc] initWithFromData:&from.x ToData:&to.x DataLength:sizeof(vec3) Duration:1.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animatingTargetBackToDefault:) DidStopSelector:@selector(animatingBackToDefaultDidStop:)];
	[[NezAnimator instance] addAnimation:targetToDefaultAni];
	
	from = [[OpenGLES2Graphics instance].camera getEye];
	to.z = from.z;
	eyeToDefaultAni = [[NezAnimation alloc] initWithFromData:&from.x ToData:&to.x DataLength:sizeof(vec3) Duration:1.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animatingEyeBackToDefault:) DidStopSelector:@selector(animatingBackToDefaultDidStop:)];
	eyeToDefaultAni->delay = 0.3;
	[[NezAnimator instance] addAnimation:eyeToDefaultAni];
}

-(void)animatingTargetBackToDefault:(NezAnimation*)ani {
	vec3 *target = (vec3*)ani->newData;
	NezCamera *camera = [OpenGLES2Graphics instance].camera;
	[camera setTarget:target[0]];
	[[OpenGLES2Graphics instance] setupMatricesQuick];
}

-(void)animatingEyeBackToDefault:(NezAnimation*)ani {
	vec3 *eye = (vec3*)ani->newData;
	NezCamera *camera = [OpenGLES2Graphics instance].camera;
	[camera setEye:eye[0]];
	[[OpenGLES2Graphics instance] setupMatricesQuick];
}

-(void)animatingBackToDefaultDidStop:(NezAnimation*)ani {
	if(eyeToDefaultAni == ani) {
		eyeToDefaultAni = nil;
	}
	if(targetToDefaultAni == ani) {
		targetToDefaultAni = nil;
	}
	[ani release];
	if (eyeToDefaultAni == targetToDefaultAni) {
		if (finishedDelegate && finishedSelector) {
			[finishedDelegate performSelector:finishedSelector];
		}
	}
}

-(NSString*)getWord {
	char letters[91];
	int i=0;
	for (LetterBlock *lb in leterBlockArray) {
		letters[i++] = lb.letter;
	}
	letters[i] = '\0';
	NSString *word = [NSString stringWithFormat:@"%s", letters];
	return word;
}

-(void)dealloc {
	//NSLog(@"dealloc:AnimatedWord");
	self.leterBlockArray = nil;
	[super dealloc];
}

@end
