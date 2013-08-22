//
//  Math.h
//  NezModels3D
//
//  Created by David Nesbitt on 3/6/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#include "Structures.h"

#define SIZE_OF_VEC4F (sizeof(vec4))
#define SIZE_OF_SEGMENT (sizeof(float)*6)
#define SIZE_OF_MATRIX4F (sizeof(mat4))

#define EPSILON 1.0e-5
#define Nez_ABS(a) ((a)<=0?-(a):(a))

#define Nez_PI 3.141592653589793

static vec4 IDENTITY_QUATERNION = {
	0, 0, 0, 1
};

static mat4 IDENTITY_MATRIX = {
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0,
	0, 0, 0, 1
};

static inline void QuaternionCopy(const vec4 *qIn, vec4 *qOut) {
	memcpy(qOut, qIn, SIZE_OF_VEC4F);
}

static inline void QuaternionGetIdentity(vec4 *qOut) {
	QuaternionCopy(&IDENTITY_QUATERNION, qOut);
}

static inline double randomNumber() {
	return arc4random()/4294967295.0f;
}

float pointLineDistance(vec3 lineStart, vec3 lineEnd, vec3 point);

void QuaternionNormalize(vec4 *q);
void Quat_multQuat (vec4 *qa, vec4 *qb, vec4 *qout);
void Quat_multVec(vec4 *q, vec3 *v, vec4 *qout);
void Quat_rotatePoint(vec4 *q, vec3 *vin, vec3 *vout);

void QuaternionGetInverse(vec4 *q, vec4 *inv);

void QuaternionFromEulerAngles(float zAng, float yAng, float xAng, vec4 *quaternion);
void QuaternionToMatrix(vec4 *quat, mat4 *mOut);
void QuaternionFromVectors(const vec3 *v0, const vec3 *v1, vec4 *qOut);
void QuaternionRotationAxis(const vec3 *vAxis, const float fAngle, vec4 *qOut);
void QuaternionMultiply(const vec4 *qA, const vec4 *qB, vec4 *qOut);
void QuaternionSlerp(const vec4 *qA, const vec4 *qB, const float t, vec4 *qOut);

void MatrixToOrientationQuaternion(mat4 *m, vec4 *q);

static inline void MatrixCopy(const mat4 *mIn, mat4 *mOut) {
	memcpy(mOut, mIn, sizeof(mat4));
}

static inline void MatrixGetIdentity(mat4 *mOut) {
	MatrixCopy(&IDENTITY_MATRIX, mOut);
}

void Mat4ToMat3(mat4 *mIn, mat3 *mOut);

void MatrixSet(mat4 *dst, float tx, float ty, float tz, float sx, float sy, float sz );

void MatrixGetTranslation(vec3 *translation, mat4 *mOut);

void MatrixGetScale(vec3 *scale, mat4 *mOut);
void MatrixMultiplyScale(mat4 *mIn, vec3 *scale, mat4 *mOut);
void MatrixMultiplyScaleS(mat4 *mIn, float scale, mat4 *mOut);

void MatrixGetRotation(vec3 *rotation, mat4 *mOut);

void MatrixMultiply(const mat4 *mB, const mat4 *mA, mat4 *mOut);
void MatrixInverse(mat4 *f, mat4 *mOut);

void MatrixMultVec4(mat4 *mIn, vec4 *vIn, vec4 *vOut);
void MatrixMultVec3(mat4 *mIn, vec4 *vIn, vec3 *vOut);
void Mat4ToMat3MultVec3(mat4 *mIn, vec3 *vIn, vec3 *vOut);

static inline void Vec3Copy(const vec3 *vIn, vec3 *vOut) {
	memcpy(vOut, vIn, sizeof(vec3));
}

void Vector3Mix(vec3 *a, vec3 *b, float t, vec3 *c);
float Vector3LengthSquared(vec3 *vec);
float Vector3Length(vec3 *vec);
float VectorDotProduct(const vec3 *vec1, const vec3 *vec2);
void VectorCrossProduct(const vec3 *v1, const vec3 *v2, vec3 *vOut);
void VectorNormalize(vec3 *v);
float VectorDistanceBetween(vec3 *v1, vec3 *v2);
void VectorSubtractAndNormalize(vec3 *v1, vec3 *v2, vec3 *vOut);
void VectorCrossProductAndNormalize(vec3 *v1, vec3 *v2, vec3 *vOut);	
void GetNormal(vec3 *vertex1, vec3 *vertex2, vec3 *vertex3, vec3 *normal);

