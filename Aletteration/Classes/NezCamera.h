//
//  NezCamera.h
//  NezModels3D
//
//  Created by David Nesbitt on 3/7/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "Math.h"
#import "Structures.h"

@interface NezCamera : NSObject {
	
@public
	mat4 matrix;
	mat4 inverseMatrix;
	
	vec3 eye;
	vec3 target;
	vec3 up;
	
	float minEyeTargetDistance;
}

-(id)initWithEye:(vec3)eyePos Target:(vec3)lookAtTarget UpVector:(vec3)upVector;

-(void)setMinEyeTargetDistance:(float)d;
-(float)getEyeTargetDistance;

-(void)setEye:(vec3)e;
-(void)setTarget:(vec3)t;
-(void)setEye:(vec3)e andTarget:(vec3)t;
-(void)setEye:(vec3)e andTarget:(vec3)t andUpVector:(vec3)u;
-(void)setUpVector:(vec3)u;

-(vec3)getEye;
-(vec3)getTarget;
-(vec3)getUpVector;

-(void)getOrientation:(vec4*)q;

-(void)movePartialWithTarget:(vec3*)targetPos Increment:(float)ratio;
-(float)movePartialWithEyePos:(vec3*)eyePos EyeRatio:(float)eyeRatio Target:(vec3*)targetPos TargetRatio:(float)targetRatio;

-(mat4*)matrix;
-(mat4*)inverseMatrix;

-(void)zoom:(float)scale;
-(void)rotateCameraAroundLookAt:(vec4*)quaternion;

-(void)roll:(float)angle;
-(void)spin:(float)dx :(float)dy Radians:(float)angle;

-(void)setupMatrix;

@end
