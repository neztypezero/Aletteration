//
//  NezGeometry.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"
#import "OpenGLES2Graphics.h"
#import "Math.h"
#import "NezAnimation.h" 
#import "NezAnimator.h"


@interface NezGeometry(private)

-(void)setDimensions;

@end

@implementation NezGeometry

@synthesize size;

-(int)getModelVertexCount {
	return 0;
}

-(Vertex*)getModelVertexList {
	return 0;
}

-(unsigned short)getModelIndexCount {
	return 0;
}

-(unsigned short*)getModelIndexList {
	return 0;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray {
	color4uc c = {0,0,0,0};
	return [self initWithVertexArray:vertexArray modelMatrix:IDENTITY_MATRIX color:c];
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(mat4)mat color:(color4uc)c {
	if ((self=[super init])) {
		int iCount = [self getModelIndexCount];
		int vCount = [self getModelVertexCount];

		[vertexArray reserveVertices:vCount Indices:iCount];
		attributes = &vertexArray->paletteArray[vertexArray->paletteArrayCount];
		attributes->matrix = mat;
		
		int vertexCount = vertexArray->vertexCount;
		unsigned short *indexList = &vertexArray->indexList[vertexArray->indexCount];
		
		unsigned short *modelIndexList = [self getModelIndexList];
		for (int i=0; i<iCount; i++) {
			indexList[i] = vertexCount+modelIndexList[i];
		}
		bufferOffset = vertexCount;
		bufferedVertexArray = vertexArray;
		
		Vertex *vertexList = &vertexArray->vertexList[vertexCount];
		Vertex *modelVertexList = [self getModelVertexList];
		memcpy(vertexList, modelVertexList, sizeof(Vertex)*vCount);
		for (int i=0; i<vCount; i++) {
			vertexList[i].indexArray[0] = vertexArray->paletteArrayCount;
		}
		[self setColor:c];
		[self setDimensions];
		
		vertexArray->indexCount += iCount;
		vertexArray->vertexCount += vCount;
		vertexArray->paletteArrayCount++;
	}
	return self;
}

-(void)setColor:(color4uc)c {
	attributes->color1 = c;
	attributes->color2 = c;
	attributes->mix = 1.0;
}

-(void)setColor:(color4uc)c andMix:(float)mix {
	attributes->color1 = attributes->color2;
	attributes->color2 = c;
	attributes->mix = mix;
}

-(color4uc)getColor {
	return attributes->color2;
}

-(void)setMix:(float)mix {
	attributes->mix = mix;
}

-(float)getMix {
	return attributes->mix;
}

-(mat4*)getModelMaxtrix {
	return &attributes->matrix;
}

-(void)setModelMaxtrix:(mat4*)mat {
	attributes->matrix = *mat;
}

-(void)setScale:(float)scale {
	attributes->matrix.x.x = scale;
	attributes->matrix.y.y = scale;
	attributes->matrix.z.z = scale;
	[self setBoundingPoints];
}

-(void)setXScale:(float)xScale YScale:(float)yScale ZScale:(float)zScale {
	attributes->matrix.x.x = xScale;
	attributes->matrix.y.y = yScale;
	attributes->matrix.z.z = zScale;
	[self setBoundingPoints];
}

-(void)offsetWithDX:(float)dx DY:(float)dy DZ:(float)dz {
	min.x += dx;
	min.y += dy;
	min.z += dz;

	max.x += dx;
	max.y += dy;
	max.z += dz;
	
	attributes->matrix.w.x += dx;
	attributes->matrix.w.y += dy;
	attributes->matrix.w.z += dz;
}

-(void)translateToGeometry:(NezGeometry*)geometry {
	
}

-(float)getMinX {
	return min.x;
}

-(float)getMaxX {
	return max.x;
}

-(float)getMinY {
	return min.y;
}

-(float)getMaxY {
	return max.y;
}

-(float)getMinZ {
	return min.z;
}

-(float)getMaxZ {
	return max.z;
}

-(vec3)getMidPoint {
	vec3 p = {
		(max.x+min.x)/2.0f,
		(max.y+min.y)/2.0f, 
		(max.z+min.z)/2.0f
	};
	return p;
}

-(vec2)getMidScreenPoint {
	vec3 p = [self getMidPoint];
	return [[OpenGLES2Graphics instance] getScreenPointWithX:p.x Y:p.y Z:p.z];
}

-(size3)getOriginalSize {
	return originalDimensions;
}

-(size3)getSize {
	return dimensions;
}

-(void)setBoundingPoints {
	dimensions.w = originalDimensions.w*attributes->matrix.x.x;
	dimensions.h = originalDimensions.h*attributes->matrix.y.y;
	dimensions.d = originalDimensions.d*attributes->matrix.z.z;
	
	float halfW = originalDimensions.w/2.0f;
	float halfH = originalDimensions.h/2.0f;
	float halfD = originalDimensions.d/2.0f;
	
	vec4 modelMin = {
		-halfW,
		-halfH,
		-halfD,
		1.0f
	};
	vec4 modelMax = {
		halfW,
		halfH,
		halfD,
		1.0f
	};
	MatrixMultVec3(&attributes->matrix, &modelMin, &min);
	MatrixMultVec3(&attributes->matrix, &modelMax, &max);
}

-(void)setDimensions {
	Vertex *vertexList = [self getModelVertexList];
	int vertexCount = [self getModelVertexCount];
	if (vertexCount > 0) {
		min.x = vertexList[0].pos.x;
		min.y = vertexList[0].pos.y;
		min.y = vertexList[0].pos.y;
		max = min;
		
		for (int i=0; i<vertexCount; i++) {
			if (min.x > vertexList[i].pos.x) { min.x = vertexList[i].pos.x; }
			if (min.y > vertexList[i].pos.y) { min.y = vertexList[i].pos.y; }
			if (min.z > vertexList[i].pos.z) { min.z = vertexList[i].pos.z; }
			if (max.x < vertexList[i].pos.x) { max.x = vertexList[i].pos.x; }
			if (max.y < vertexList[i].pos.y) { max.y = vertexList[i].pos.y; }
			if (max.z < vertexList[i].pos.z) { max.z = vertexList[i].pos.z; }
		}
	} else {
		min = ZERO3;
		max = ZERO3;
	}
	originalScale.x = attributes->matrix.x.x;
	originalScale.y = attributes->matrix.y.y;
	originalScale.z = attributes->matrix.z.z;
	originalDimensions.w = (max.x-min.x);
	originalDimensions.h = (max.y-min.y);
	originalDimensions.d = (max.z-min.z);
	[self setBoundingPoints];
}

-(void)setBoxWithMidPoint:(vec3*)pos {
	attributes->matrix.w.x = pos->x;
	attributes->matrix.w.y = pos->y;
	attributes->matrix.w.z = pos->z;
	
	[self setBoundingPoints];
}

-(BOOL)containsPoint:(vec4)point {
	if (point.x < min.x || point.x > max.x) return NO;
	if (point.y < min.y || point.y > max.y) return NO;
	if (point.z < min.z || point.z > max.z) return NO;
	return YES;
}

-(BOOL)containsPoint:(vec4)point withExtraSize:(size3)extra {
	extra.w *= dimensions.w;
	extra.h *= dimensions.h;
	extra.d *= dimensions.d;
	if (point.x < min.x-extra.w || point.x > max.x+extra.w) return NO;
	if (point.y < min.y-extra.h || point.y > max.y+extra.h) return NO;
	if (point.z < min.z-extra.d || point.z > max.z+extra.d) return NO;
	return YES;
}

-(BOOL)containsPoint:(vec4)point withExtraLeft:(float)left Top:(float)top Right:(float)right Bottom:(float)bottom Down:(float)down Up:(float)up {
	left *= dimensions.w;
	top *= dimensions.h;
	right *= dimensions.w;
	bottom *= dimensions.h;
	if (point.x < min.x-left || point.x > max.x+right) return NO;
	if (point.y < min.y-bottom || point.y > max.y+top) return NO;
	if (point.z < min.z-down || point.z > max.z+up) return NO;
	return YES;
}

-(void)startFadeInAnimationWithDelay:(float)delay {
	color4uc c = attributes->color1;
	c.a = 1.0;
	[self setColor:c andMix:0.0];
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:delay EasingFunction:easeInCubic CallbackObject:self UpdateSelector:@selector(animateFadeIn:) DidStopSelector:@selector(animateFadeInDidStop:)];
	[[NezAnimator instance] addAnimation:ani];	
}

-(void)animateFadeIn:(NezAnimation*)ani {
	[self setMix:ani->newData[0]];
}

-(void)animateFadeInDidStop:(NezAnimation*)ani {
	[ani release];
}

@end
