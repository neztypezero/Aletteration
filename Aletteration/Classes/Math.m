//
//  Math.m
//  NezModels3D
//
//  Created by David Nesbitt on 3/6/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "Math.h"

float pointLineDistance(vec3 lineStart, vec3 lineEnd, vec3 point) {
	vec3 a = {
		lineStart.x-lineEnd.x,
		lineStart.y-lineEnd.y,
		lineStart.z-lineEnd.z,
	};
	vec3 b = {
		lineStart.x-point.x,
		lineStart.y-point.y,
		lineStart.z-point.z,
	};
	vec3 cross;
	VectorCrossProduct(&a, &b, &cross);
	return Vector3Length(&cross)/Vector3Length(&a);
}

void QuaternionNormalize(vec4 *q) {
	/* compute magnitude of the quaternion */
	float mag = sqrt ((q->x * q->x) + (q->y * q->y)
					  + (q->z * q->z) + (q->w * q->w));
	
	/* check for bogus length, to protect against divide by zero */
	if (mag > EPSILON) {
		/* normalize it */
		float oneOverMag = 1.0f / mag;
		
		q->x *= oneOverMag;
		q->y *= oneOverMag;
		q->z *= oneOverMag;
		q->w *= oneOverMag;
    }
}

void Quat_multQuat(vec4 *qa, vec4 *qb, vec4 *qout) {
	qout->x = (qa->x * qb->w) + (qa->w * qb->x) + (qa->y * qb->z) - (qa->z * qb->y);
	qout->y = (qa->y * qb->w) + (qa->w * qb->y) + (qa->z * qb->x) - (qa->x * qb->z);
	qout->z = (qa->z * qb->w) + (qa->w * qb->z) + (qa->x * qb->y) - (qa->y * qb->x);
	qout->w = (qa->w * qb->w) - (qa->x * qb->x) - (qa->y * qb->y) - (qa->z * qb->z);
}

void Quat_multVec(vec4 *q, vec3 *v, vec4 *qout) {
	qout->x =   (q->w * v->x) + (q->y * v->z) - (q->z * v->y);
	qout->y =   (q->w * v->y) + (q->z * v->x) - (q->x * v->z);
	qout->z =   (q->w * v->z) + (q->x * v->y) - (q->y * v->x);
	qout->w = - (q->x * v->x) - (q->y * v->y) - (q->z * v->z);
}

void Quat_rotatePoint(vec4 *q, vec3 *vin, vec3 *vout) {
	vec4 tmp, inv, final;
	
	inv.x = -q->x;
	inv.y = -q->y;
	inv.z = -q->z;
	inv.w =  q->w;
	
	QuaternionNormalize(&inv);
	
	Quat_multVec(q, vin, &tmp);
	Quat_multQuat(&tmp, &inv, &final);
	
	vout->x = final.x;
	vout->y = final.y;
	vout->z = final.z;
}

void QuaternionGetInverse(vec4 *q, vec4 *inv) {
	inv->x = -q->x; 
	inv->y = -q->y;
	inv->z = -q->z; 
	inv->w =  q->w;
	QuaternionNormalize(inv);
}

void QuaternionFromEulerAngles(float xAng, float yAng, float zAng, vec4 *quaternion) {
	vec3 vec;
	vec4 quat1, quat2, xQuat, yQuat, zQuat;
	
	vec.x = 1; vec.y = 0; vec.z = 0;
	QuaternionRotationAxis(&vec, -xAng, &xQuat);
	vec.x = 0; vec.y = 1; vec.z = 0;
	QuaternionRotationAxis(&vec, -yAng, &yQuat);
	vec.x = 0; vec.y = 0; vec.z = 1;
	QuaternionRotationAxis(&vec, -zAng, &zQuat);
	
	QuaternionGetIdentity(&quat1);
	QuaternionMultiply(&quat1, &xQuat, &quat2);
	QuaternionMultiply(&quat2, &yQuat, &quat1);
	QuaternionMultiply(&quat1, &zQuat, quaternion);
}

void Mat4ToMat3(mat4 *mIn, mat3 *mOut) {
	mOut->x.x = mIn->x.x;
	mOut->x.y = mIn->x.y;
	mOut->x.z = mIn->x.z;

	mOut->y.x = mIn->y.x;
	mOut->y.y = mIn->y.y;
	mOut->y.z = mIn->y.z;

	mOut->z.x = mIn->z.x;
	mOut->z.y = mIn->z.y;
	mOut->z.z = mIn->z.z;
}

void QuaternionToMatrix(vec4 *quat, mat4 *mOut) {
    /* Fill matrix members */
	float qXsqrd = quat->x*quat->x;
	float qYsqrd = quat->y*quat->y;
	float qZsqrd = quat->z*quat->z;
	
	mOut->x.x = 1.0f - 2.0f*qYsqrd - 2.0f*qZsqrd;
	mOut->x.y = 2.0f*quat->x*quat->y - 2.0f*quat->z*quat->w;
	mOut->x.z = 2.0f*quat->x*quat->z + 2.0f*quat->y*quat->w;
	mOut->x.w = 0.0f;
	
	mOut->y.x = 2.0f*quat->x*quat->y + 2.0f*quat->z*quat->w;
	mOut->y.y = 1.0f - 2.0f*qXsqrd - 2.0f*qZsqrd;
	mOut->y.z = 2.0f*quat->y*quat->z - 2.0f*quat->x*quat->w;
	mOut->y.w = 0.0f;
	
	mOut->z.x = 2.0f*quat->x*quat->z - 2*quat->y*quat->w;
	mOut->z.y = 2.0f*quat->y*quat->z + 2.0f*quat->x*quat->w;
	mOut->z.z = 1.0f - 2.0f*qXsqrd - 2*qYsqrd;
	mOut->z.w = 0.0f;
	
	mOut->w.x = 0.0f;
	mOut->w.y = 0.0f;
	mOut->w.z = 0.0f;
	mOut->w.w = 1.0f;
}

void MatrixToOrientationQuaternion(mat4 *m, vec4 *q) {
	float trace = m->x.x + m->y.y + m->z.z + 1.0f;
	
	if(trace > EPSILON) {
		float s = 0.5f / sqrtf(trace);
		q->x = (m->y.z - m->z.y) * s;
		q->y = (m->z.x - m->x.z) * s;
		q->z = (m->x.y - m->y.x) * s;
		q->w = 0.25f / s;
	} else {
		if(m->x.x > m->y.y && m->x.x > m->z.z) {
			float s = 2.0f * sqrtf(1.0f + m->x.x - m->y.y - m->z.z);
			q->x = (m->y.x+ m->x.x)/s;
			q->y = (m->z.x+ m->x.z)/s;
			q->z = (m->z.y- m->y.z)/s;
			q->w = 0.25f * s;
		} else if (m->y.y > m->z.z) {
			float s = 2.0f * sqrtf(1.0f + m->y.y - m->x.x - m->z.z);
			q->x = 0.25f * s;
			q->y = (m->z.y + m->y.z) / s;
			q->z = (m->z.x - m->x.z) / s;
			q->w = (m->y.x + m->x.y) / s;
		} else {
			float s = 2.0f * sqrtf(1.0f + m->z.z - m->x.x - m->y.y);
			q->x = (m->z.y + m->y.z) / s;
			q->y = 0.25f * s;
			q->z = (m->x.y - m->x.y) / s;
			q->w = (m->z.x + m->x.z) / s;
		}
	}
	QuaternionNormalize(q);
}

void QuaternionFromVectors(const vec3 *v0, const vec3 *v1, vec4 *qOut) {
	if (v0->x == -v1->x && v0->y == -v1->y && v0->z == -v1->z) {
		vec3 v = {1,0,0};
		QuaternionRotationAxis(&v, Nez_PI, qOut);
		return;
	}
	vec3 c;
	VectorCrossProduct(v0, v1, &c);
	float d = VectorDotProduct(v0, v1);
	float s = sqrt((1+d)*2);
	
	qOut->x = c.x/s;
	qOut->y = c.y/s;
	qOut->z = c.z/s;
	qOut->w = s / 2.0f;
}

void QuaternionRotationAxis(const vec3 *vAxis, const float fAngle, vec4 *qOut) {
	float fSin = (float)sin(fAngle * 0.5f);
	float fCos = (float)cos(fAngle * 0.5f);
	
	/* Create quaternion */
	qOut->x = vAxis->x * fSin;
	qOut->y = vAxis->y * fSin;
	qOut->z = vAxis->z * fSin;
	qOut->w = fCos;
	
	/* Normalise it */
	QuaternionNormalize(qOut);
}

void QuaternionMultiply(const vec4 *qA, const vec4 *qB, vec4 *qOut) 
{
	vec3 crossProduct;
	
	/* Compute scalar component */
	qOut->w = (qA->w*qB->w) - (qA->x*qB->x + qA->y*qB->y + qA->z*qB->z);
	
	/* Compute cross product */
	crossProduct.x = qA->y*qB->z - qA->z*qB->y;
	crossProduct.y = qA->z*qB->x - qA->x*qB->z;
	crossProduct.z = qA->x*qB->y - qA->y*qB->x;
	
	/* Compute result vector */
	qOut->x = (qA->w * qB->x) + (qB->w * qA->x) + crossProduct.x;
	qOut->y = (qA->w * qB->y) + (qB->w * qA->y) + crossProduct.y;
	qOut->z = (qA->w * qB->z) + (qB->w * qA->z) + crossProduct.z;
	
	/* Normalize resulting quaternion */
	QuaternionNormalize(qOut);
}

void QuaternionSlerp(const vec4 *qA, const vec4 *qB, const float t, vec4 *qOut) {
	float fCosine, fAngle, A, B;
	
	/* Find sine of Angle between Quaternion A and B (dot product between quaternion A and B) */
	fCosine = qA->w*qB->w + qA->x*qB->x + qA->y*qB->y + qA->z*qB->z;
	
	if (fCosine < 0) {
		/*
		 <http://www.magic-software.com/Documentation/Quaternions.pdf>
		 
		 "It is important to note that the quaternions q and -q represent
		 the same rotation... while either quaternion will do, the
		 interpolation methods require choosing one over the other.
		 
		 "Although q1 and -q1 represent the same rotation, the values of
		 Slerp(t; q0, q1) and Slerp(t; q0,-q1) are not the same. It is
		 customary to choose the sign... on q1 so that... the angle
		 between q0 and q1 is acute. This choice avoids extra
		 spinning caused by the interpolated rotations."
		 */
		vec4 qi;
		qi.x = -qB->x;
		qi.y = -qB->y;
		qi.z = -qB->z;
		qi.w = -qB->w;
		
		QuaternionSlerp(qA, &qi, t, qOut);
		return;
	}
	
	fCosine = MIN(fCosine, 1.0f);
	fAngle = (float)cos(fCosine);
	
	/* Avoid a division by zero */
	if (fAngle<=EPSILON) {
		QuaternionCopy(qA, qOut);
		return;
	}
	
	/* Precompute some values */
	A = (float)(sin((1.0f-t)*fAngle) / sin(fAngle));
	B = (float)(sin(t*fAngle) / sin(fAngle));
	
	/* Compute resulting quaternion */
	qOut->x = A * qA->x + B * qB->x;
	qOut->y = A * qA->y + B * qB->y;
	qOut->z = A * qA->z + B * qB->z;
	qOut->w = A * qA->w + B * qB->w;
	
	/* Normalise result */
	QuaternionNormalize(qOut);
}

void MatrixGetTranslation(vec3 *translation, mat4 *mOut) {
	MatrixCopy(&IDENTITY_MATRIX, mOut);
	mOut->w.x = translation->x;
	mOut->w.y = translation->y;
	mOut->w.z = translation->z;
}

void MatrixGetScale(vec3 *scale, mat4 *mOut) {
	MatrixCopy(&IDENTITY_MATRIX, mOut);
	mOut->x.x = scale->x;
	mOut->y.y = scale->y;
	mOut->z.z = scale->z;
}

void MatrixMultiplyScaleS(mat4 *mIn, float scale, mat4 *mOut) {
	mOut->x.x = mIn->x.x * scale;
	mOut->x.y = mIn->x.y * scale;
	mOut->x.z = mIn->x.z * scale;
	mOut->y.x = mIn->y.x * scale;
	mOut->y.y = mIn->y.y * scale;
	mOut->y.z = mIn->y.z * scale;
	mOut->z.x = mIn->z.x * scale;
	mOut->z.y = mIn->z.y * scale;
	mOut->z.z = mIn->z.z* scale;
	if (mIn != mOut) {
		mOut->x.w = mIn->x.w;
		mOut->y.w = mIn->y.w;
		mOut->z.w = mIn->z.w;
		mOut->w.x = mIn->w.x;
		mOut->w.y = mIn->w.y;
		mOut->w.z = mIn->w.z;
		mOut->w.w = mIn->w.w;
	}
}

void MatrixMultiplyScale(mat4 *mIn, vec3 *scale, mat4 *mOut) {
	float x = scale->x;
	float y = scale->y;
	float z = scale->z;
	mOut->x.x = mIn->x.x * x;
	mOut->x.y = mIn->x.y * x;
	mOut->x.z = mIn->x.z * x;
	mOut->y.x = mIn->y.x * y;
	mOut->y.y = mIn->y.y * y;
	mOut->y.z = mIn->y.z * y;
	mOut->z.x = mIn->z.x * z;
	mOut->z.y = mIn->z.y * z;
	mOut->z.z = mIn->z.z* z;
	if (mIn != mOut) {
		mOut->x.w = mIn->x.w;
		mOut->y.w = mIn->y.w;
		mOut->z.w = mIn->z.w;
		mOut->w.x = mIn->w.x;
		mOut->w.y = mIn->w.y;
		mOut->w.z = mIn->w.z;
		mOut->w.w = mIn->w.w;
	}
}

void MatrixGetRotation(vec3 *rotation, mat4 *mOut) {
	MatrixCopy(&IDENTITY_MATRIX, mOut);
	mOut->x.x = rotation->x;
	mOut->y.y = rotation->y;
	mOut->z.z = rotation->z;
}

void MatrixMultiply(const mat4 *mB, const mat4 *mA, mat4 *mOut) {
	mOut->x.x = mA->x.x*mB->x.x + mA->x.y*mB->y.x + mA->x.z*mB->z.x + mA->x.w*mB->w.x;
	mOut->x.y = mA->x.x*mB->x.y + mA->x.y*mB->y.y + mA->x.z*mB->z.y + mA->x.w*mB->w.y;
	mOut->x.z = mA->x.x*mB->x.z + mA->x.y*mB->y.z + mA->x.z*mB->z.z + mA->x.w*mB->w.z;
	mOut->x.w = mA->x.x*mB->x.w + mA->x.y*mB->y.w + mA->x.z*mB->z.w + mA->x.w*mB->w.w;
	mOut->y.x = mA->y.x*mB->x.x + mA->y.y*mB->y.x + mA->y.z*mB->z.x + mA->y.w*mB->w.x;
	mOut->y.y = mA->y.x*mB->x.y + mA->y.y*mB->y.y + mA->y.z*mB->z.y + mA->y.w*mB->w.y;
	mOut->y.z = mA->y.x*mB->x.z + mA->y.y*mB->y.z + mA->y.z*mB->z.z + mA->y.w*mB->w.z;
	mOut->y.w = mA->y.x*mB->x.w + mA->y.y*mB->y.w + mA->y.z*mB->z.w + mA->y.w*mB->w.w;
	mOut->z.x = mA->z.x*mB->x.x + mA->z.y*mB->y.x + mA->z.z*mB->z.x + mA->z.w*mB->w.x;
	mOut->z.y = mA->z.x*mB->x.y + mA->z.y*mB->y.y + mA->z.z*mB->z.y + mA->z.w*mB->w.y;
	mOut->z.z = mA->z.x*mB->x.z + mA->z.y*mB->y.z + mA->z.z*mB->z.z + mA->z.w*mB->w.z;
	mOut->z.w = mA->z.x*mB->x.w + mA->z.y*mB->y.w + mA->z.z*mB->z.w + mA->z.w*mB->w.w;
	mOut->w.x = mA->w.x*mB->x.x + mA->w.y*mB->y.x + mA->w.z*mB->z.x + mA->w.w*mB->w.x;
	mOut->w.y = mA->w.x*mB->x.y + mA->w.y*mB->y.y + mA->w.z*mB->z.y + mA->w.w*mB->w.y;
	mOut->w.z = mA->w.x*mB->x.z + mA->w.y*mB->y.z + mA->w.z*mB->z.z + mA->w.w*mB->w.z;
	mOut->w.w = mA->w.x*mB->x.w + mA->w.y*mB->y.w + mA->w.z*mB->z.w + mA->w.w*mB->w.w;
}

void MatrixSet(mat4 *dst, float tx, float ty, float tz, float sx, float sy, float sz ) {
	dst->x.x = sx; dst->y.x = 0;  dst->z.x = 0;  dst->w.x = tx;
	dst->x.y = 0;  dst->y.y = sy; dst->z.y = 0;  dst->w.y = ty;
	dst->x.z = 0;  dst->y.z = 0;  dst->z.z = sz; dst->w.z = tz;
	dst->x.w = 0;  dst->y.w = 0;  dst->z.w = 0;  dst->w.w = 1;
}

void MatrixInverse(mat4 *mIn, mat4 *mOut) {
	double		det_1;
	double		pos, neg, temp;
	float *f = &mIn->x.x;
	
    /* Calculate the determinant of submatrix A and determine if the
	 the matrix is singular as limited by the double precision
	 floating-point data representation. */
    pos = neg = 0.0;
    temp =  f[ 0] * f[ 5] * f[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp =  f[ 4] * f[ 9] * f[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp =  f[ 8] * f[ 1] * f[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -f[ 8] * f[ 5] * f[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -f[ 4] * f[ 1] * f[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
    temp = -f[ 0] * f[ 9] * f[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
    det_1 = pos + neg;
	
    /* Is the submatrix A singular? */
    if ((det_1 == 0.0) || (Nez_ABS(det_1 / (pos - neg)) < EPSILON))	{
        /* Matrix M has no inverse */
        return;
    } else {
		float *fOut = &mOut->x.x;
        /* Calculate inverse(A) = adj(A) / det(A) */
        det_1 = 1.0 / det_1;
        fOut[ 0] =   ( f[ 5] * f[10] - f[ 9] * f[ 6] ) * (float)det_1;
        fOut[ 1] = - ( f[ 1] * f[10] - f[ 9] * f[ 2] ) * (float)det_1;
        fOut[ 2] =   ( f[ 1] * f[ 6] - f[ 5] * f[ 2] ) * (float)det_1;
        fOut[ 4] = - ( f[ 4] * f[10] - f[ 8] * f[ 6] ) * (float)det_1;
        fOut[ 5] =   ( f[ 0] * f[10] - f[ 8] * f[ 2] ) * (float)det_1;
        fOut[ 6] = - ( f[ 0] * f[ 6] - f[ 4] * f[ 2] ) * (float)det_1;
        fOut[ 8] =   ( f[ 4] * f[ 9] - f[ 8] * f[ 5] ) * (float)det_1;
        fOut[ 9] = - ( f[ 0] * f[ 9] - f[ 8] * f[ 1] ) * (float)det_1;
        fOut[10] =   ( f[ 0] * f[ 5] - f[ 4] * f[ 1] ) * (float)det_1;
		
        /* Calculate -C * inverse(A) */
        fOut[12] = - ( f[12] * fOut[ 0] + f[13] * fOut[ 4] + f[14] * fOut[ 8] );
        fOut[13] = - ( f[12] * fOut[ 1] + f[13] * fOut[ 5] + f[14] * fOut[ 9] );
        fOut[14] = - ( f[12] * fOut[ 2] + f[13] * fOut[ 6] + f[14] * fOut[10] );
		
        /* Fill in last row */
        fOut[ 3] = 0.0f;
		fOut[ 7] = 0.0f;
		fOut[11] = 0.0f;
        fOut[15] = 1.0f;
	}
}

void MatrixMultVec4(mat4 *mIn, vec4 *vIn, vec4 *vOut) {
	vOut->x = vIn->x*mIn->x.x+vIn->y*mIn->y.x+vIn->z*mIn->z.x+vIn->w*mIn->w.x;
	vOut->y = vIn->x*mIn->x.y+vIn->y*mIn->y.y+vIn->z*mIn->z.y+vIn->w*mIn->w.y;
	vOut->z = vIn->x*mIn->x.z+vIn->y*mIn->y.z+vIn->z*mIn->z.z+vIn->w*mIn->w.z;
	vOut->w = vIn->x*mIn->x.w+vIn->y*mIn->y.w+vIn->z*mIn->z.w+vIn->w*mIn->w.w;
}

void MatrixMultVec3(mat4 *mIn, vec4 *vIn, vec3 *vOut) {
	vOut->x = vIn->x*mIn->x.x+vIn->y*mIn->y.x+vIn->z*mIn->z.x+vIn->w*mIn->w.x;
	vOut->y = vIn->x*mIn->x.y+vIn->y*mIn->y.y+vIn->z*mIn->z.y+vIn->w*mIn->w.y;
	vOut->z = vIn->x*mIn->x.z+vIn->y*mIn->y.z+vIn->z*mIn->z.z+vIn->w*mIn->w.z;
}

void Mat4ToMat3MultVec3(mat4 *mIn, vec3 *vIn, vec3 *vOut) {
	vOut->x = vIn->x*mIn->x.x+vIn->y*mIn->y.x+vIn->z*mIn->z.x;
	vOut->y = vIn->x*mIn->x.y+vIn->y*mIn->y.y+vIn->z*mIn->z.y;
	vOut->z = vIn->x*mIn->x.z+vIn->y*mIn->y.z+vIn->z*mIn->z.z;
}

void Vector3Mix(vec3 *a, vec3 *b, float t, vec3 *c) {
	c->x = a->x+((b->x-a->x)*t);
	c->y = a->y+((b->y-a->y)*t);
	c->z = a->z+((b->z-a->z)*t);
}

float Vector3LengthSquared(vec3 *vec) {
	return  (vec->x *vec->x)+(vec->y*vec->y)+(vec->z*vec->z);
}

/**
 * Returns the length of this vector.
 * @return the length of this vector
 */
float Vector3Length(vec3 *vec) {
	return sqrt(Vector3LengthSquared(vec));
}

float VectorDotProduct(const vec3 *vec1, const vec3 *vec2) {
	return  (vec1->x*vec2->x)+(vec1->y*vec2->y)+(vec1->z*vec2->z);
}

void VectorCrossProduct(const vec3 *v1, const vec3 *v2, vec3 *vOut) {
	vOut->x = (v1->y * v2->z) - (v1->z * v2->y);
	vOut->y = (v1->z * v2->x) - (v1->x * v2->z);
	vOut->z = (v1->x * v2->y) - (v1->y * v2->x);
}

void VectorNormalize(vec3 *v) {
	float len = Vector3Length(v);
	v->x /= len;
	v->y /= len;
	v->z /= len;
}

float VectorDistanceBetween(vec3 *v1, vec3 *v2) {
	float dx = v1->x-v2->x;
	float dy = v1->y-v2->y;
	float dz = v1->z-v2->z;
	
	return sqrt(dx*dx+dy*dy+dz*dz);
}

void VectorSubtractAndNormalize(vec3 *v1, vec3 *v2, vec3 *vOut) {
	vOut->x = v1->x-v2->x;
	vOut->y = v1->y-v2->y;
	vOut->z = v1->z-v2->z;
	
	float length = sqrt(vOut->x*vOut->x+vOut->y*vOut->y+vOut->z*vOut->z);
	vOut->x /= length;
	vOut->y /= length;
	vOut->z /= length;
}

void VectorCrossProductAndNormalize(vec3 *v1, vec3 *v2, vec3 *vOut) {
	vOut->x = v1->y*v2->z - v1->z*v2->y;
	vOut->y = v1->z*v2->x - v1->x*v2->z;
	vOut->z = v1->x*v2->y - v1->y*v2->x;
	
	float length = sqrt(vOut->x*vOut->x+vOut->y*vOut->y+vOut->z*vOut->z);
	vOut->x /= length;
	vOut->y /= length;
	vOut->z /= length;
}

//Takes in triangle, outputs normal
void GetNormal(vec3 *vertex1, vec3 *vertex2, vec3 *vertex3, vec3 *normal) {
	vec3 v1 = {
		vertex2->x - vertex1->x,
		vertex2->y - vertex1->y,
		vertex2->z - vertex1->z,
	};
	vec3 v2 = {
		vertex3->x - vertex1->x,
		vertex3->y - vertex1->y,
		vertex3->z - vertex1->z,
	};
	VectorCrossProduct(&v1, &v2, normal);
	VectorNormalize(normal);
}