//
//  NezAnimation.h
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#include "NezAnimationEasingFunction.h"
#include "Structures.h"

typedef enum LOOP_TYPES {
	NO_LOOP,
	LOOP_FORWARD,
	LOOP_PINGPONG,
} LOOP_TYPES;

@class NezAnimation;

@interface NezAnimation : NSObject {
@public //This is for speed. Basically using this class as a struct
	int dataLength;
	float *data;
	float *fromData;
	float *toData;
	float *newData;
	float delay;
	int repeatCount;
	int animationSlot;
	BOOL cancelled;
	BOOL removedWhenFinished;
	
	LOOP_TYPES loop;
	
	EasingFunctionPtr easingFunction;
	
	CFTimeInterval startTime;
	CFTimeInterval duration;
	CFTimeInterval elapsedTime;
	CFTimeInterval timeSinceLastUpdate;
	
	id updateObject;
	int *param1Ptr;
	int *param2Ptr;
	
	id callbackObject;
	SEL updateFrameSelector;
	SEL didStopSelector;
	
	NezAnimation *chainLink;
}
-(id)initWithFromData:(float*)fromDataPtr ToData:(float*)toDataPtr DataLength:(int)length Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;

-(id)initFloatWithFromData:(float)from ToData:(float)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;
-(id)initColor4fWithFromData:(color4f)from ToData:(color4f)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;
-(id)initVec2WithFromData:(vec2)from ToData:(vec2)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;
-(id)initVec3WithFromData:(vec3)from ToData:(vec3)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;
-(id)initVec4WithFromData:(vec4)from ToData:(vec4)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;
-(id)initMat4WithFromData:(mat4)from ToData:(mat4)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel;
	
@end
