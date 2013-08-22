//
//  AnimatedWord.h
//  Aletteration
//
//  Created by David Nesbitt on 2/15/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"

@class NezAnimation;
@class AnimatedCamera;
@class AletterationGameState;

@interface AnimatedWord : NSObject {
	vec3 movedDistance;
	NSArray *leterBlockArray;
	float remainingDistance;
	id finishedDelegate;
	SEL finishedSelector;
	NezAnimation *eyeToDefaultAni;
	NezAnimation *targetToDefaultAni;

	BOOL doesCameraTracking;
	
	AletterationGameState *gameState;
}

@property(nonatomic, retain) NSArray *leterBlockArray;
@property(nonatomic, assign) BOOL doesCameraTracking;
@property(readonly, getter=getWord) NSString *word;

-(void)startAnimatingToScoreBoard:(id)delegate finishedSelector:(SEL)selector;

@end
