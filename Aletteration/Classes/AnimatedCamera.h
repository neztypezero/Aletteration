//
//  AnimatedCamera.h
//  Aletteration
//
//  Created by David Nesbitt on 2/10/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezCamera.h"
#include "NezAnimationEasingFunction.h"

@interface AnimatedCamera : NezCamera {
	id animationStopDelegate;
	SEL animationStopSelector;
}

-(id)initWithEye:(vec3)eyePos Target:(vec3)lookAtTarget UpVector:(vec3)upVector;

-(void)animateToTarget:(vec3)t Duration:(float)duration;
-(void)animateToEye:(vec3)e Target:(vec3)t UpVector:(vec3)u Duration:(float)duration;
-(void)animateToEye:(vec3)e Target:(vec3)t UpVector:(vec3)u Duration:(float)duration EasingFunction:(EasingFunctionPtr)func;
-(void)animateToEye:(vec3)e Target:(vec3)t UpVector:(vec3)u Duration:(float)duration EasingFunction:(EasingFunctionPtr)func Delay:(float)delay;
-(void)stopAnimation;

@property(nonatomic, retain) id animationStopDelegate;
@property(nonatomic, assign) SEL animationStopSelector;

@end
