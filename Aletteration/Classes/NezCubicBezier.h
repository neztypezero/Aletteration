//
//  NezCubicBezier.h
//  Aletteration
//
//  Created by David Nesbitt on 2/25/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"


@interface NezCubicBezier : NSObject {
	vec3 P[4]; //control points
}

-(id)initWithControlPointsP0:(vec3)p0 P1:(vec3)p1 P2:(vec3)p2 P3:(vec3)p3;
-(BOOL)isFlat:(float)epsilon;
-(vec3)positionAt:(float)t;

@property(nonatomic, readonly, getter=getP0) vec3 p0;
@property(nonatomic, readonly, getter=getP1) vec3 p1;
@property(nonatomic, readonly, getter=getP2) vec3 p2;
@property(nonatomic, readonly, getter=getP3) vec3 p3;
	
@end
