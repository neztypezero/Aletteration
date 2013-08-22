//
//  NezCubicBezierAnimation.m
//  Aletteration
//
//  Created by David Nesbitt on 2/26/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezCubicBezierAnimation.h"
#import "NezCubicBezier.h"


@implementation NezCubicBezierAnimation

-(id)initWithControlPointsP0:(vec3)p0 P1:(vec3)p1 P2:(vec3)p2 P3:(vec3)p3 Duration:(CFTimeInterval)d EasingFunction:(EasingFunctionPtr)func CallbackObject:(id)object UpdateSelector:(SEL)updateSel DidStopSelector:(SEL)didStopSel {
	bezier = nil;
	if ((self=[super initFloatWithFromData:0.0 ToData:1.0 Duration:d EasingFunction:func CallbackObject:object UpdateSelector:updateSel DidStopSelector:didStopSel])) {
		bezier = [[NezCubicBezier alloc] initWithControlPointsP0:p0 P1:p1 P2:p2 P3:p3];
	}
	return self;
}

-(void)dealloc {
	if (bezier) {
		[bezier release];
	}
	[super dealloc];
}

@end
