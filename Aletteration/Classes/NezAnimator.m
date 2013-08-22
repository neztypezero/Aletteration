//
//  NezAnimator.m
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimator.h"
#import "NezAnimation.h"

//This class is NOT thread safe!!!

NezAnimator *g_NezAnimator;

@implementation NezAnimator

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_NezAnimator = [[NezAnimator alloc] init];
    }
}

+(NezAnimator*)instance {
	return(g_NezAnimator);
}

-(id)init {
	if ((self=[super init])) {
		animationList = [[NSMutableArray arrayWithCapacity:128] retain];
		addedList = [[NSMutableArray arrayWithCapacity:128] retain];
		removedList = [[NSMutableArray arrayWithCapacity:128] retain];
	}
	return self;
}

-(void)addAnimation:(NezAnimation*)animation {
	animation->startTime = -1;
	[addedList addObject:animation];
}

-(void)removeAnimation:(NezAnimation*)animation {
	[removedList addObject:animation];
}

-(void)cancelAnimation:(NezAnimation*)animation {
	animation->cancelled = YES;
	[removedList addObject:animation];
}

-(void)updateWithCurrentTime:(CFTimeInterval)time {
	CFTimeInterval timeSinceLastUpdate = time-currentTime;
	currentTime = time;
	if ([removedList count] > 0) {
		[animationList removeObjectsInArray:removedList];
		[removedList removeAllObjects];
	}
	if ([addedList count] > 0) {
		[animationList addObjectsFromArray:addedList];
		[addedList removeAllObjects];
	}
	for (NezAnimation *ani in animationList) {
		if (!ani->cancelled) {
			if (ani->startTime < 0) {
				ani->startTime = currentTime+ani->delay;
			}
			ani->elapsedTime = currentTime-ani->startTime;
			ani->timeSinceLastUpdate = timeSinceLastUpdate;
			if (ani->elapsedTime >= ani->duration) {
				ani->elapsedTime = ani->duration;
				for (int i=0; i<ani->dataLength; i++) {
					ani->newData[i] = ani->toData[i];
				}
				if (--ani->repeatCount > 0 || ani->loop == LOOP_FORWARD) {
					[ani->callbackObject performSelector:ani->updateFrameSelector withObject:ani];
					ani->startTime = currentTime+ani->delay;
				} else if(ani->loop == LOOP_PINGPONG) {
					[ani->callbackObject performSelector:ani->updateFrameSelector withObject:ani];
					ani->startTime = currentTime+ani->delay;

					float *toData = ani->fromData;
					float *fromData = ani->toData;
					
					ani->toData = toData;
					ani->fromData = fromData;
				} else {
					[ani->callbackObject performSelector:ani->updateFrameSelector withObject:ani];
					if (ani->chainLink) {
						[self addAnimation:ani->chainLink];
						ani->chainLink->startTime = currentTime+ani->chainLink->delay;
					}
					if (ani->removedWhenFinished) {
						[self removeAnimation:ani];
					}
					if (ani->didStopSelector) {
						[ani->callbackObject performSelector:ani->didStopSelector withObject:ani];
					}
				}
			} else if(ani->elapsedTime >= 0) {
				for (int i=0; i<ani->dataLength; i++) {
					ani->newData[i] = ani->easingFunction(ani->elapsedTime, ani->fromData[i], ani->toData[i]-ani->fromData[i], ani->duration);
				}
				[ani->callbackObject performSelector:ani->updateFrameSelector withObject:ani];
			}
		}
	}
}

-(void)dealloc {
	//NSLog(@"dealloc:NezAnimator");
	[animationList removeAllObjects];
	[animationList release];
	[addedList removeAllObjects];
	[addedList release];
	[removedList removeAllObjects];
	[removedList release];
	[super dealloc];
}

@end
