//
//  NezAnimator.h
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

@class NezAnimation;

@interface NezAnimator : NSObject {
	NSMutableArray *animationList;
	NSMutableArray *addedList;
	NSMutableArray *removedList;
	CFTimeInterval currentTime;
}

+(void)initialize;
+(NezAnimator*)instance;

-(id)init;

-(void)addAnimation:(NezAnimation*)animation;
-(void)removeAnimation:(NezAnimation*)animation;
-(void)cancelAnimation:(NezAnimation*)animation;

-(void)updateWithCurrentTime:(CFTimeInterval)currentTime;

@end
