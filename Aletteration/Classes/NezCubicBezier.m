//
//  NezCubicBezier.m
//  Aletteration
//
//  Created by David Nesbitt on 2/25/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezCubicBezier.h"
#import "Math.h"

@implementation NezCubicBezier

-(id)initWithControlPointsP0:(vec3)p0 P1:(vec3)p1 P2:(vec3)p2 P3:(vec3)p3 {
	if ((self = [super init])) {
		P[0] = p0;
		P[1] = p1;
		P[2] = p2;
		P[3] = p3;
	}
	return self;
}

-(vec3)getP0 {
	return P[0];
}

-(vec3)getP1 {
	return P[1];
}

-(vec3)getP2 {
	return P[2];
}

-(vec3)getP3 {
	return P[3];
}

-(BOOL)isFlat:(float)epsilon {
	float   d1 = pointLineDistance(P[1], P[0], P[3]);
	float   d2 = pointLineDistance(P[2], P[0], P[3]);
	return (d1 < epsilon) && (d2 < epsilon);
}

-(vec3)positionAt:(float)t {
	vec3 P01, P12, P23, P0112, P1223, outVec;
	Vector3Mix(&P[0], &P[1], t, &P01);
	Vector3Mix(&P[1], &P[2], t, &P12);
	Vector3Mix(&P[2], &P[3], t, &P23);
	Vector3Mix(&P01, &P12, t, &P0112);
	Vector3Mix(&P12, &P23, t, &P1223);
	
	Vector3Mix(&P0112, &P1223, t, &outVec);
	return outVec;
}

@end
