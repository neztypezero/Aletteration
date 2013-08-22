//
//  NezAnimation.m
//  Aletteration
//
//  Created by David Nesbitt on 2/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezAnimation.h"


@implementation NezAnimation

-(id)initWithFromData:(float*)fromDataPtr ToData:(float*)toDataPtr DataLength:(int)length Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	if ((self = [super init])) {
		dataLength = length/sizeof(float);
		data = malloc(length*3);
		
		fromData = &data[0];
		memcpy(fromData, fromDataPtr, length);
		toData = &data[dataLength];
		memcpy(toData, toDataPtr, length);
/*		for (int i=0; i<dataLength; i++) {
			toData[i] = toDataPtr[i]-fromDataPtr[i];
		}
*/		newData = &data[dataLength*2];

		easingFunction = func;
		
		duration = d;
		repeatCount = 0;
		delay = 0;
		
		cancelled = NO;
		removedWhenFinished = YES;
		
		loop = NO_LOOP;
		
		chainLink = nil;
		
		callbackObject = object;
		updateFrameSelector = updateSel;
		didStopSelector = didStopSel;
		
		updateObject = nil;
	}
	return self;
}

-(id)initColor4fWithFromData:(color4f)from ToData:(color4f)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	return [self initWithFromData:&from.r ToData:&to.r DataLength:sizeof(color4f) Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel];
}

-(id)initFloatWithFromData:(float)from ToData:(float)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	return [self initWithFromData:&from ToData:&to DataLength:sizeof(vec2) Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel];
}

-(id)initVec2WithFromData:(vec2)from ToData:(vec2)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	return [self initWithFromData:&from.x ToData:&to.x DataLength:sizeof(vec2) Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel];
}

-(id)initVec3WithFromData:(vec3)from ToData:(vec3)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	return [self initWithFromData:&from.x ToData:&to.x DataLength:sizeof(vec3) Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel];
}

-(id)initVec4WithFromData:(vec4)from ToData:(vec4)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	return [self initWithFromData:&from.x ToData:&to.x DataLength:sizeof(vec4) Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel];
}

-(id)initMat4WithFromData:(mat4)from ToData:(mat4)to Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	return [self initWithFromData:&from.x.x ToData:&to.x.x DataLength:sizeof(mat4) Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel];
}

-(void)dealloc {
	free(data);
	[super dealloc];
}

@end
