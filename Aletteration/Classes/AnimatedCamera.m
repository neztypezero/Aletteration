//
//  AnimatedCamera.m
//  Aletteration
//
//  Created by David Nesbitt on 2/10/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AnimatedCamera.h"
#import "OpenGLES2Graphics.h"
#import "NezAnimator.h"
#import "AletterationAppDelegate.h"
#import "NezAnimation.h"

@implementation AnimatedCamera

@synthesize animationStopDelegate;
@synthesize animationStopSelector;

-(id)initWithEye:(vec3)eyePos Target:(vec3)lookAtTarget UpVector:(vec3)upVector {
	if ((self = [super initWithEye:eyePos Target:lookAtTarget UpVector:upVector])) {
		animationStopDelegate = nil;
		animationStopSelector = nil;
	}
	return self;
}

-(void)animateToTarget:(vec3)t Duration:(float)duration {
	vec3 e = t;
	e.z += [self getEyeTargetDistance];
	[self animateToEye:e Target:t UpVector:up Duration:duration EasingFunction:&easeInOutCubic];
}

-(void)animateToEye:(vec3)e Target:(vec3)t UpVector:(vec3)u Duration:(float)duration {
	[self animateToEye:e Target:t UpVector:u Duration:duration EasingFunction:&easeInOutCubic];
}

-(void)animateToEye:(vec3)e Target:(vec3)t UpVector:(vec3)u Duration:(float)duration EasingFunction:(EasingFunctionPtr)func {
	[self animateToEye:e Target:t UpVector:u Duration:duration EasingFunction:func Delay:0.0];
}

-(void)animateToEye:(vec3)e Target:(vec3)t UpVector:(vec3)u Duration:(float)duration EasingFunction:(EasingFunctionPtr)func Delay:(float)delay {
	float from[] = {
		eye.x, eye.y, eye.z,
		target.x, target.y, target.z,
		up.x, up.y, up.z, 
	};
	float to[] = {
		e.x, e.y, e.z,
		t.x, t.y, t.z,
		u.x, u.y, u.z, 
	};
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:from ToData:to DataLength:sizeof(float)*9 Duration:duration EasingFunction:func CallbackObject:self UpdateSelector:@selector(animation:) DidStopSelector:@selector(animationDidStop:)];
	ani->delay = delay;
	[[NezAnimator instance] addAnimation:ani];
}

-(void)stopAnimation {
//	[animationDelegate removeAnimation];
}

-(void)animation:(NezAnimation*)ani {
	vec3 *data = (vec3*)ani->newData;
	up = data[2];
	VectorNormalize(&up);
	
	eye = data[0];
	target = data[1];
	
	[self setupMatrix];
	[[OpenGLES2Graphics instance] setupMatricesQuick];
}

-(void)animationDidStop:(NezAnimation*)ani {
	[ani release];
	[self setupMatrix];
	[[OpenGLES2Graphics instance] setupMatrices];

	if (animationStopDelegate && animationStopSelector) {
		[animationStopDelegate performSelector:animationStopSelector];
	}
}

-(void)dealloc {
	//NSLog(@"dealloc:AnimatedCamera");
	[super dealloc];
}

@end
