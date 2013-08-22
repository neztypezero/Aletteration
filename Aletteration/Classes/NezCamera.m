//
//  NezCamera.m
//  NezModels3D
//
//  Created by David Nesbitt on 3/7/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "NezCamera.h"

#define SIGN(x) (x>=0?'+':'-') 

void LookAt(vec3 *eye, vec3 *target, vec3 *up, mat4 *mOut) {
	float m[16];
	vec3 *x = (vec3*)&m[0];
	vec3 *y = (vec3*)&m[4];
	vec3 *z = (vec3*)&m[8];
	
	VectorSubtractAndNormalize(eye, target, z);
	VectorCrossProductAndNormalize(up, z, x);
	VectorCrossProductAndNormalize(z, x, y);
	
	mOut->x.x = x->x; mOut->y.x = x->y; mOut->z.x = x->z; 
	mOut->x.y = y->x; mOut->y.y = y->y; mOut->z.y = y->z; 
	mOut->x.z = z->x; mOut->y.z = z->y; mOut->z.z = z->z; 
	mOut->x.w = 0;    mOut->y.w = 0;    mOut->z.w = 0; 
	
	vec3 negEye = {-eye->x, -eye->y, -eye->z};
	mOut->w.x = x->x * negEye.x + x->y * negEye.y + x->z * negEye.z;
	mOut->w.y = y->x * negEye.x + y->y * negEye.y + y->z * negEye.z;
	mOut->w.z = z->x * negEye.x + z->y * negEye.y + z->z * negEye.z;
	mOut->w.w = 1;
}

@implementation NezCamera

-(id)initWithEye:(vec3)eyePos Target:(vec3)lookAtTarget UpVector:(vec3)upVector {
	if ((self = [super init])) {
		eye = eyePos;
		target = lookAtTarget;
		up = upVector;

		[self setMinEyeTargetDistance:VectorDistanceBetween(&eye, &target)];
		[self setupMatrix];
	}
	return self;
}

-(void)setMinEyeTargetDistance:(float)d {
	minEyeTargetDistance = fabs(d);
}

-(void)getOrientation:(vec4*)q {
	MatrixToOrientationQuaternion(&matrix, q);
}

-(float)getEyeTargetDistance {
	vec3 v = {eye.x-target.x, eye.y-target.y, eye.z-target.z};
	return Vector3Length(&v);
}

-(vec3)getEye {
	return eye;
}

-(vec3)getTarget {
	return target;
}

-(vec3)getUpVector {
	return up;
}

-(mat4*)matrix {
	return &matrix;
}

-(mat4*)inverseMatrix {
	return &inverseMatrix;
}

-(void)movePartialWithTarget:(vec3*)targetPos Increment:(float)ratio {
	target.x += (targetPos->x-target.x)*ratio;
	target.y += (targetPos->y-target.y)*ratio;
	target.z += (targetPos->z-target.z)*ratio;
	[self setupMatrix];
}

-(float)movePartialWithEyePos:(vec3*)eyePos EyeRatio:(float)eyeRatio Target:(vec3*)targetPos TargetRatio:(float)targetRatio {
	target.x += (targetPos->x-target.x)*targetRatio;
	target.y += (targetPos->y-target.y)*targetRatio;
	target.z += (targetPos->z-target.z)*targetRatio;
	eye.x += (eyePos->x-eye.x)*eyeRatio;
	eye.y += (eyePos->y-eye.y)*eyeRatio;
	eye.z += (eyePos->z-eye.z)*eyeRatio;
	[self setupMatrix];
	float totalDifference = fabs(targetPos->x-target.x)+fabs(targetPos->y-target.y)+fabs(targetPos->z-target.z);
	totalDifference += fabs(eyePos->x-eye.x)+fabs(eyePos->y-eye.y)+fabs(eyePos->z-eye.z);
	return(totalDifference);
}

-(void)setEye:(vec3)e {
	eye = e;
	[self setupMatrix];
}

-(void)setTarget:(vec3)t {
	target = t;
	[self setupMatrix];
}

-(void)setEye:(vec3)e andTarget:(vec3)t {
	eye = e;
	target = t;
	[self setupMatrix];
}

-(void)setEye:(vec3)e andTarget:(vec3)t andUpVector:(vec3)u {
	eye = e;
	target = t;
	up = u;
	[self setupMatrix];
}

-(void)setUpVector:(vec3)u {
	up = u;
	[self setupMatrix];
}

-(void)setupMatrix {
	LookAt(&eye, &target, &up, &matrix);
}

-(void)zoom:(float)scale {
	vec3 directionVector;
	VectorSubtractAndNormalize(&eye, &target, &directionVector);
	
	scale = -scale/100;
	
	vec3 newEyePos = {
		eye.x+directionVector.x*scale,
		eye.y+directionVector.y*scale,
		eye.z+directionVector.z*scale,
	};
	vec3 newDV = {
		newEyePos.x-target.x,
		newEyePos.y-target.y,
		newEyePos.z-target.z,
	};
	if (
		(newDV.x > 0 && directionVector.x < 0) || 
		(newDV.x < 0 && directionVector.x > 0) || 
		(newDV.y > 0 && directionVector.y < 0) || 
		(newDV.y < 0 && directionVector.y > 0) || 
		(newDV.z > 0 && directionVector.z < 0) || 
		(newDV.z < 0 && directionVector.z > 0) || 
		(Vector3Length(&newDV) < minEyeTargetDistance)
	) {
		newEyePos.x = target.x+(directionVector.x*minEyeTargetDistance);
		newEyePos.y = target.y+(directionVector.y*minEyeTargetDistance);
		newEyePos.z = target.z+(directionVector.z*minEyeTargetDistance);
	}
	eye = newEyePos;
	[self setupMatrix];
}

-(void)roll:(float)angle {
//	float qA[4];
//	float qB[4];
//	float zAxis[] = {0,0,1};
	
//	QuaternionCopy(quaternion, qA);
//	QuaternionRotationAxis(zAxis, angle, qB);
//	QuaternionMultiply(qA, qB, quaternion);
	[self setupMatrix];
}

-(void)rotateCameraAroundLookAt:(vec4*)q {
	vec4 v = {0,0,1,1};
	vec4 v2;
	mat4 m;
	QuaternionToMatrix(q, &m);
	MatrixMultVec4(&m, &v, &v2);

	float distance = [self getEyeTargetDistance];
	eye.x = target.x+(v2.x*distance);
	eye.y = target.y+(v2.y*distance);
	eye.z = target.z+(v2.z*distance);

	[self setupMatrix];
}

-(void)spin:(float)dx :(float)dy Radians:(float)angle {
//	float qA[4];
//	float qB[4];
//	float axis[] = {dx,dy,0};
	
//	QuaternionCopy(quaternion, qA);
//	QuaternionRotationAxis(axis, 0.05, qB);
//	QuaternionMultiply(qA, qB, quaternion);
	[self setupMatrix];
}


@end
