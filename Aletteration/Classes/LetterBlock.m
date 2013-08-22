//
//  LetterBlock.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "LetterBlock.h"
#import "AletterationBox.h"
#import "Math.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezCubicBezierAnimation.h"
#import "SimpleObjLoader.h"
#import "matrix.h"
#import "NezOpenAL.h"
#import "NezCubicBezier.h"


NezVertexArray* BLOCK_VERTEX_ARRAY = nil;

@implementation LetterBlock

@synthesize animationStopDelegate;
@synthesize animationStopSelector;
@synthesize lineIndex;
@synthesize lineMat;

@synthesize letter;

+(void)initialize {
	static BOOL initialized = NO;
	if(!initialized) {
		initialized = YES;
		BLOCK_VERTEX_ARRAY = [SimpleObjLoader loadVertexArrayWithFile:@"letter" Type:@"obj" Dir:@"Models"];
	}
}

-(int)getModelVertexCount {
	return BLOCK_VERTEX_ARRAY->vertexCount;
}

-(Vertex*)getModelVertexList {
	return BLOCK_VERTEX_ARRAY->vertexList;
}

-(unsigned short)getModelIndexCount {
	return BLOCK_VERTEX_ARRAY->indexCount;
}

-(unsigned short*)getModelIndexList {
	return BLOCK_VERTEX_ARRAY->indexList;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray letter:(char)blockLetter modelMatrix:(mat4)mat color:(color4uc)c uv:(vec4)uv {
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
		letter = blockLetter;

		int vertexCount = [self getModelVertexCount];
		Vertex *firstVertex = &vertexArray->vertexList[vertexArray->vertexCount-vertexCount];
		for (int i=0; i<vertexCount-4; i++) {
			firstVertex[i].uv.x = 0;
			firstVertex[i].uv.y = 0;
		}
		firstVertex[vertexCount-4].uv.x = uv.x;
		firstVertex[vertexCount-4].uv.y = uv.y;
		
		firstVertex[vertexCount-3].uv.x = uv.z;
		firstVertex[vertexCount-3].uv.y = uv.y;
		
		firstVertex[vertexCount-2].uv.x = uv.z;
		firstVertex[vertexCount-2].uv.y = uv.w;
		
		firstVertex[vertexCount-1].uv.x = uv.x;
		firstVertex[vertexCount-1].uv.y = uv.w;
		
		letterSquareVertexList[0] = firstVertex[vertexCount-4];
		letterSquareVertexList[1] = firstVertex[vertexCount-3];
		letterSquareVertexList[2] = firstVertex[vertexCount-2];
		letterSquareVertexList[3] = firstVertex[vertexCount-1];
		
		gameState = [AletterationGameState instance];
	}
	return self;
}

-(void)setUV:(vec4)uv {
	int vertexCount = [self getModelVertexCount];

	if (bufferedVertexArray->bufferObjects) {
		letterSquareVertexList[0].uv.x = uv.x;
		letterSquareVertexList[0].uv.y = uv.y;
		
		letterSquareVertexList[1].uv.x = uv.z;
		letterSquareVertexList[1].uv.y = uv.y;
		
		letterSquareVertexList[2].uv.x = uv.z;
		letterSquareVertexList[2].uv.y = uv.w;
		
		letterSquareVertexList[3].uv.x = uv.x;
		letterSquareVertexList[3].uv.y = uv.w;
		[[OpenGLES2Graphics instance] setBufferSubData:bufferedVertexArray Data:letterSquareVertexList Offset:(bufferOffset+vertexCount-4)*sizeof(Vertex) Size:LETTER_SQUARE_VERTEX_COUNT*sizeof(Vertex)];
	} else {
/*		Vertex *v = &bufferedVertexArray->vertexList[bufferOffset];
		v[0].uv.x = uv.x;
		v[0].uv.y = uv.y;
		
		v[1].uv.x = uv.z;
		v[1].uv.y = uv.y;
		
		v[2].uv.x = uv.x;
		v[2].uv.y = uv.w;
		
		v[3].uv.x = uv.z;
		v[3].uv.y = uv.w;
		memcpy(vertexPtr, v, INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex));
*/	

	}
}

-(void)startFromBoxAnimation:(float)delay {
	vec3 midPoint = [self getMidPoint];
	vec3 endPos = [gameState getPositionForLetter:letter];
	
	mat4 mat = *self.modelMatrix;
	mat.w.z += dimensions.h*1.5;
	midPoint.z += dimensions.h*1.5;
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&attributes->matrix.x.x ToData:&mat.x.x DataLength:sizeof(mat4) Duration:0.2 EasingFunction:&easeInCubic CallbackObject:self UpdateSelector:@selector(animateModelMatrixFromBox:) DidStopSelector:@selector(animateDidStop:)];
	ani->delay = delay;

	mat4 curveMat = IDENTITY_MATRIX;
	curveMat.w.x = endPos.x;
	curveMat.w.y = endPos.y;
	curveMat.w.z = endPos.z;
	
	vec3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(-0.25)};
	vec3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, midPoint.z+(endPos.z-midPoint.z)*(0.75)};
	NezCubicBezier *bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
	NezCubicBezierAnimation *curveAni = [[NezCubicBezierAnimation alloc] initWithFromData:&mat.x.x ToData:&curveMat.x.x DataLength:sizeof(mat4) Duration:1.0 EasingFunction:&easeOutCubic CallbackObject:self UpdateSelector:@selector(animateModelMatrixCurveFromBox:) DidStopSelector:@selector(animateModelMatrixCurveFromBoxDidStop:)];
	curveAni->bezier = bezier;
	ani->chainLink = curveAni;
	
	[[NezAnimator instance] addAnimation:ani];
}

-(void)animateModelMatrixFromBox:(NezAnimation*)ani {
	mat4 *mat = (mat4*)ani->newData;
	attributes->matrix = *mat;
}

-(void)playRandomClick {
	float maxPitchOffset = 0.25;
	float pitchOffset = randomNumber()*(maxPitchOffset*2.0)-maxPitchOffset;
	[gameState.soundPlayer playSound:gameState.sounds->tileDrop gain:1.0 pitch:1.0+pitchOffset loops:NO];
}

-(void)animateModelMatrixCurveFromBoxDidStop:(NezCubicBezierAnimation*)ani {
	[self playRandomClick];
	[self animateModelMatrixDidStop:ani];
}

-(void)animateModelMatrixCurveFromBox:(NezCubicBezierAnimation*)ani {
	float t = (ani->elapsedTime/ani->duration);
	mat4 *mat = (mat4*)ani->newData;
	vec3 p = [ani->bezier positionAt:t];
	mat->w.x = p.x;
	mat->w.y = p.y;
	mat->w.z = p.z;
	attributes->matrix = *mat;
}

-(void)animateMatrix:(mat4*)mat withDuration:(float)duration {
    [self animateMatrix:mat withDuration:duration afterDelay:0.0];
}

-(void)animateMatrix:(mat4*)mat withDuration:(float)duration afterDelay:(float)delay {
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&attributes->matrix.x.x ToData:&mat->x.x DataLength:sizeof(mat4) Duration:duration EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateModelMatrix:) DidStopSelector:@selector(animateModelMatrixDidStop:)];
    ani->delay = delay;
	[[NezAnimator instance] addAnimation:ani];
}

-(void)animateModelMatrix:(NezAnimation*)ani {
	mat4 *mat = (mat4*)ani->newData;
	attributes->matrix = *mat;
}

-(void)animateModelMatrixDidStop:(NezAnimation*)ani {
	[self setBoundingPoints];

	if (animationStopDelegate && animationStopSelector) {
		[animationStopDelegate performSelector:animationStopSelector withObject:self];
	}
	[ani release];
}

-(void)animateColorMix:(float)mix withDuration:(float)duration {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:attributes->mix ToData:mix Duration:duration EasingFunction:easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateColorMix:) DidStopSelector:@selector(animateDidStop:)];
	[[NezAnimator instance] addAnimation:ani];
}

-(void)animateColorMix:(NezAnimation*)ani {
	[self setMix:ani->newData[0]];
}

-(void)animateDidStop:(NezAnimation*)ani {
	[ani release];
}

-(void)dealloc {
	//NSLog(@"dealloc:LetterBlock");
	[super dealloc];
}

@end
