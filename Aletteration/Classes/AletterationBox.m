//
//  AletterationBox.m
//  Aletteration
//
//  Created by David Nesbitt on 2/8/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationBox.h"
#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "LetterBlock.h"
#import "Math.h"
#import "matrix.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezCubicBezierAnimation.h"
#import "NezCubicBezier.h"
#import "NezOpenAL.h"
#import "SimpleObjLoader.h"
#import "LetterStack.h"

@interface AletterationBoxGeometry : NezGeometry {
	NezVertexArray *vertexArray;
}
@end

@implementation AletterationBoxGeometry

-(id)initWithVertexArray:(NezVertexArray*)array centerPoint:(vec3)pos color:(color4uc)c Box:(SimpleObjLoader*)box Group:(NSString*)group {
	vertexArray = [box makeVertexArrayForGroup:group];
	if (vertexArray->vertexCount > 0) {
		mat4 mat;
		mat = IDENTITY_MATRIX;

		min = vertexArray->vertexList[0].pos;
		max = vertexArray->vertexList[0].pos;
		for (int i=1; i<vertexArray->vertexCount; i++) {
			Vertex *v = &vertexArray->vertexList[i];
			if (min.x > v->pos.x) { min.x = v->pos.x; }
			if (min.y > v->pos.y) { min.y = v->pos.y; }
			if (min.z > v->pos.z) { min.z = v->pos.z; }
			if (max.x < v->pos.x) { max.x = v->pos.x; }
			if (max.y < v->pos.y) { max.y = v->pos.y; }
			if (max.z < v->pos.z) { max.z = v->pos.z; }
		}
		dimensions.w = max.x-min.x;
		dimensions.h = max.y-min.y;
		dimensions.d = max.z-min.z;
		
		float dx = (max.x+min.x)/2.0;
		float dy = (max.y+min.y)/2.0;
		float dz = (max.z+min.z)/2.0;
		
		for (int i=0; i<vertexArray->vertexCount; i++) {
			Vertex *v = &vertexArray->vertexList[i];
			v->pos.x -= dx;
			v->pos.y -= dy;
			v->pos.z -= dz;
		}
		mat.w.x = pos.x;
		mat.w.y = pos.y;
		mat.w.z = pos.z+dimensions.d/2.0;
		mat.w.w = 1.0f;
		
		if ((self=[super initWithVertexArray:array modelMatrix:mat color:c])) {
			
		}
		return self;
	} else {
		return nil;
	}
}

-(int)getModelVertexCount {
	return vertexArray->vertexCount;
}

-(Vertex*)getModelVertexList {
	return vertexArray->vertexList;
}

-(unsigned short)getModelIndexCount {
	return vertexArray->indexCount;
}

-(unsigned short*)getModelIndexList {
	return vertexArray->indexList;
}

-(void)dealloc {
	[vertexArray release];
	[super dealloc];
}

@end

@implementation AletterationBox

@synthesize letterBlockSize;

-(id)initWithVertexArray:(NezVertexArray*)vertexArray LetterList:(NSArray*)allLettersList midPoint:(vec3)pos boxColor:(color4uc)c {
	if ((self=[super init])) {
		AletterationGameState *gameState = [AletterationGameState instance];
		
		SimpleObjLoader *boxObj = [[SimpleObjLoader alloc] initWithFile:@"box" Type:@"obj" Dir:@"Models"];
		SimpleObjLoader *lidObj = [[SimpleObjLoader alloc] initWithFile:@"lid" Type:@"obj" Dir:@"Models"];
		
		dimensions = boxObj.size;

		color4uc blockColor = gameState.letterColor;
		
		box = [[AletterationBoxGeometry alloc] initWithVertexArray:vertexArray centerPoint:pos color:blockColor Box:boxObj Group:@"Box"];
		pos.z += dimensions.d-lidObj.size.d*0.85;
		lid = [[AletterationBoxGeometry alloc] initWithVertexArray:vertexArray centerPoint:pos color:blockColor Box:lidObj Group:@"Lid"];
		
		[boxObj release];
		[lidObj release];
		
		mat4 identityMatrix;
		identityMatrix = IDENTITY_MATRIX;

		lettersList = [[NSMutableArray arrayWithCapacity:LETTER_COUNT] retain];
		
		for (char i='a'; i<='z'; i++) {
			int letterCount = [gameState getCountForLetter:i];
			NSMutableArray *letterBlockList = [NSMutableArray arrayWithCapacity:letterCount];
			[lettersList addObject:letterBlockList];
		}
		for (LetterBlock *lb in allLettersList) {
			NSMutableArray *letterBlockList = [lettersList objectAtIndex:lb.letter-'a'];
			[letterBlockList addObject:lb];
		}

		LetterBlock *flb = [[lettersList objectAtIndex:0] objectAtIndex:0];
		letterBlockSize = flb.size;
		
		float letterBoxStartY = ((TOTAL_LETTER_COUNT/4.0)*letterBlockSize.d-letterBlockSize.d/2.0);
		float wSpace = letterBlockSize.w/8.0f;
		float maxJitter = letterBlockSize.w/16.0f;
		float halfMaxJitter = maxJitter/2.0f;
		vec4 letterBoxTranslation = {
			-letterBlockSize.w/2.0f-wSpace/2.0f,
			letterBoxStartY,
			0.0f,
			1.0
		};
		mat4 z90Rot;
		mat4f_LoadZRotation(RADIANS_90_DEGREES, &z90Rot.x.x);
		
		mat4 boxM = *box.modelMatrix;
		mat4 lidM = *lid.modelMatrix;
		
		MatrixMultiply(&boxM, &z90Rot, box.modelMatrix);
		MatrixMultiply(&lidM, &z90Rot, lid.modelMatrix);
		
		originalBoxMatrix = *box.modelMatrix;
		originalLidMatrix = *lid.modelMatrix;
		
		mat4 *boxMatrix = box.modelMatrix;
		mat4 mat, mat2;
		
		mat4f_LoadXRotation(-RADIANS_90_DEGREES, &mat.x.x);
		
		int count = 0;
		for (char i='a'; i<='z'; i++) {
			int letterCount = [gameState getCountForLetter:i];
			NSMutableArray *letterBlockList = [lettersList objectAtIndex:i-'a'];
			
			for (int j=0; j<letterCount; j++) {
				vec3 jitter = {
					maxJitter*randomNumber()-halfMaxJitter,
					0,
					maxJitter*randomNumber()-halfMaxJitter
				};
				mat.w = letterBoxTranslation;
				mat.w.x += jitter.x;
				//mat.w.y += jitter.y;
				mat.w.z += jitter.z;
				
				letterModelMatrix[count] = mat;
				
				MatrixMultiply(boxMatrix, &mat, &mat2);
				
				LetterBlock *lb = [letterBlockList objectAtIndex:j];
				lb.modelMatrix = &mat2;
				letterBoxTranslation.y -= lb.size.d;
				count++;
				if (count==TOTAL_LETTER_COUNT/2) {
					letterBoxTranslation.x += letterBlockSize.w+wSpace;
					letterBoxTranslation.y = letterBoxStartY;
				}
			}
		}
	}
	return self;
}

-(mat4)getResetStage1BoxMatrix {
	mat4 *rot;
	CATransform3D rot3D = CATransform3DMakeRotation(Nez_PI*0.2, 1.0, -1.0, -1.0);
	rot = ((mat4*)(&rot3D));
	rot->w.x = 0;
	rot->w.y = dimensions.h/2.0f;
	rot->w.z = dimensions.d*3.0f;
	return *rot;
}

-(void)resetAnimation:(id)finishedDelegate finishedSelector:(SEL)finishedSelector {
	blocksFinishedDelegate = finishedDelegate;
	blocksFinishedSelector = finishedSelector;
	
	mat4 *boxMatrix = box.modelMatrix;
	mat4 rot = [self getResetStage1BoxMatrix];
	
	float duration = 1.6;
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&boxMatrix->x.x ToData:&rot.x.x DataLength:sizeof(mat4) Duration:duration EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateJustBox:) DidStopSelector:@selector(animationDidStop:)];

	[[NezAnimator instance] addAnimation:ani];
}

-(void)layoutStacks {
	for (NSMutableArray *letterBlockList in lettersList) {
		for (LetterBlock *lb in letterBlockList) {
			vec3 endPos = [[AletterationGameState instance] getPositionForLetter:lb.letter];
			mat4f_LoadTranslation(&endPos.x, &lb.modelMatrix->x.x);
			[[AletterationGameState instance] pushLetterBlock:lb forLetter:lb.letter];
			[lb release];
			[lb setBoundingPoints];
		}
	}
	[lettersList removeAllObjects];

	mat4 lidMatrix;
	mat4 matRotZ, matRotX;
	mat4f_LoadXRotation(-Nez_PI, &matRotX.x.x);
	mat4f_LoadZRotation(1.1, &matRotZ.x.x);
	MatrixMultiply(&matRotX, &matRotZ, &lidMatrix);

	vec3 endPos = {-dimensions.d,letterBlockSize.h*8.0,LINE_Z};
	lidMatrix.w.x = endPos.x;
	lidMatrix.w.y = endPos.y;
	lidMatrix.w.z = endPos.z;
	lid.modelMatrix = &lidMatrix;

	[lid setBoundingPoints];
	
	mat4 to;
	mat4f_LoadZRotation(-1.1, &to.x.x);
	to.w.x = (lid.maxX+lid.minX)/2.0;
	to.w.y = (lid.maxY+lid.minY)/2.0;
	to.w.z = (box.size.d)/4.0;
	box.modelMatrix = &to;
	[box setBoundingPoints];
}

-(void)layoutStacksAnimation:(id)finishedDelegate finishedSelector:(SEL)finishedSelector {
	blocksFinishedDelegate = finishedDelegate;
	blocksFinishedSelector = finishedSelector;
	
	mat4 *boxMatrix = box.modelMatrix;
	mat4 rot;
	CATransform3D rot3D = CATransform3DMakeRotation(Nez_PI*0.2, 1.0, -1.0, -1.0);
	rot = *((mat4*)(&rot3D));
	rot.w.x = boxMatrix->w.x + dimensions.d;
	rot.w.y = boxMatrix->w.y + dimensions.h*0.5;
	rot.w.z = boxMatrix->w.z + dimensions.d*2.0f;
	
	float duration = 1.6;
	NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&boxMatrix->x.x ToData:&rot.x.x DataLength:sizeof(mat4) Duration:duration*0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBox:) DidStopSelector:@selector(animateBoxDidStop:)];
	[[NezAnimator instance] addAnimation:ani];

	mat4 *lidMatrix = lid.modelMatrix;
	vec3 midPoint = [lid getMidPoint];
	vec3 endPos = {-dimensions.d,letterBlockSize.h*8.0,LINE_Z};

	NezCubicBezierAnimation *cbani = [[NezCubicBezierAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:duration EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateLid:) DidStopSelector:@selector(animationDidStop:)];
	vec3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(-5.0)};
	vec3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, midPoint.z+(endPos.z-midPoint.z)*(-5.0)};
	cbani->bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
	[[NezAnimator instance] addAnimation:cbani];

	mat4 matRotZ, matRotX, lidMidMatrix;
	mat4f_LoadXRotation(-Nez_PI/2.0, &matRotX.x.x);
	mat4f_LoadZRotation(1.1/3.0, &matRotZ.x.x);
	matRotZ = IDENTITY_MATRIX;
	MatrixMultiply(&matRotX, &matRotZ, &lidMidMatrix);
	
	mat4 lidRestMatrix;
	mat4f_LoadXRotation(-Nez_PI, &matRotX.x.x);
	mat4f_LoadZRotation(1.1, &matRotZ.x.x);
	MatrixMultiply(&matRotX, &matRotZ, &lidRestMatrix);

	NezAnimation *lidRotAni = [[NezAnimation alloc] initWithFromData:&lidMatrix->x.x ToData:&lidMidMatrix.x.x DataLength:sizeof(mat4) Duration:duration*0.25 EasingFunction:&easeInCubic CallbackObject:self UpdateSelector:@selector(animateLidRotation:) DidStopSelector:@selector(animationDidStop:)];
	lidRotAni->delay = duration*0.15;
	lidRotAni->chainLink = [[NezAnimation alloc] initWithFromData:&lidMidMatrix.x.x ToData:&lidRestMatrix.x.x DataLength:sizeof(mat4) Duration:duration*0.6 EasingFunction:&easeOutCubic CallbackObject:self UpdateSelector:@selector(animateLidRotation:) DidStopSelector:@selector(animationDidStop:)];
	[[NezAnimator instance] addAnimation:lidRotAni];
}

-(void)animateBox:(NezAnimation*)ani {
	mat4 *mat = (mat4*)ani->newData;
	mat4 mat2;
	
	box.modelMatrix = mat;
	int count=0;
	for (NSMutableArray *letterBlockList in lettersList) {
		for (LetterBlock *lb in letterBlockList) {
			MatrixMultiply(mat, &letterModelMatrix[count++], &mat2);
			lb.modelMatrix = &mat2;
		}
	}
}

-(void)animateJustBox:(NezAnimation*)ani {
	mat4 *mat = (mat4*)ani->newData;
	box.modelMatrix = mat;
}

-(void)animateLid:(NezCubicBezierAnimation*)ani {
	mat4 *mat = lid.modelMatrix;
	vec3 p = [ani->bezier positionAt:ani->elapsedTime/ani->duration];
	mat->w.x = p.x;
	mat->w.y = p.y;
	mat->w.z = p.z;
}

-(void)animateLidRotation:(NezAnimation*)ani {
	mat4 *mat = (mat4*)ani->newData;
	mat4 *modelMatrix = lid.modelMatrix;
	modelMatrix->x = mat->x;
	modelMatrix->y = mat->y;
	modelMatrix->z = mat->z;
}

-(void)animationDidStop:(NezAnimation*)ani {
	[ani release];
	[lid setBoundingPoints];
	[box setBoundingPoints];
}

-(void)animateBoxDidStop:(NezAnimation*)ani {
	currentAnimatingCount = 0;
	for (NSMutableArray *letterBlockList in lettersList) {
		LetterBlock *lb = [letterBlockList objectAtIndex:0];
		float z = lb.modelMatrix->w.z;
		NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:z ToData:z+lb.size.h*(0.5+randomNumber()*1.0) Duration:0.15 EasingFunction:&easeLinear CallbackObject:self UpdateSelector:@selector(animateStackUpFromBox:) DidStopSelector:@selector(animateStackUpFromBoxDidStop:)];
		ani->updateObject = [letterBlockList retain];
		ani->delay = randomNumber()*1.0;
		[[NezAnimator instance] addAnimation:ani];
	}
	[lettersList removeAllObjects];
	[ani release];
}

-(void)animateStackUpFromBox:(NezAnimation*)ani {
	NSMutableArray *letterBlockList = ani->updateObject;
	for (LetterBlock *lb in letterBlockList) {
		lb.modelMatrix->w.z = ani->newData[0];
	}
}

-(void)animateStackUpFromBoxDidStop:(NezAnimation*)ani {
	NSMutableArray *letterBlockList = ani->updateObject;
	[ani release];
	
	float delay = 0.0;
	float delayIncrement = 0.10;
	for (LetterBlock *lb in letterBlockList) {
		[lb setBoundingPoints];
		lb.animationStopDelegate = self;
		lb.animationStopSelector = @selector(animateLetterBlockDidStop:);
		[lb retain];
		[lb startFromBoxAnimation:delay];
		currentAnimatingCount++;
		delay += delayIncrement;
	}
	[letterBlockList removeAllObjects];
	[letterBlockList release];
}

-(void)animateLetterBlockDidStop:(LetterBlock*)lb {
	lb.animationStopDelegate = nil;
	lb.animationStopSelector = nil;
	[[AletterationGameState instance] pushLetterBlock:lb forLetter:lb.letter];
	[lb release];
	currentAnimatingCount--;
	if (currentAnimatingCount == 0) {
		[blocksFinishedDelegate performSelector:blocksFinishedSelector withObject:nil afterDelay:1.0];
		blocksFinishedDelegate = nil;
		blocksFinishedSelector = nil;

		mat4 *from = box.modelMatrix;
		mat4 to;
		mat4f_LoadZRotation(-1.1, &to.x.x);
		to.w.x = (lid.maxX+lid.minX)/2.0;
		to.w.y = (lid.maxY+lid.minY)/2.0;
		to.w.z = (box.size.d)/4.0;
		
		NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&from->x.x ToData:&to.x.x DataLength:sizeof(mat4) Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateJustBox:) DidStopSelector:@selector(animationDidStop:)];
		[[NezAnimator instance] addAnimation:ani];
	}
}

-(void)startMoveStacksToBoxAnimation:(float)duration {
	mat4 boxMatrix = [self getResetStage1BoxMatrix];
	mat4 mat, mat2, mat3;
	
	mat4f_LoadXRotation(-RADIANS_90_DEGREES, &mat.x.x);
	
	AletterationGameState *gameState = [AletterationGameState instance];
	
	float wSpace = letterBlockSize.w/8.0f;
	vec4 letterBoxTranslation = {
		-letterBlockSize.w/2.0f-wSpace/2.0f,
		23*letterBlockSize.d,
		letterBlockSize.h*2.5,
		1.0
	};
	vec4 blockTranslation = {
		letterBoxTranslation.x,
		letterBoxTranslation.y,
		0.0,
		1.0
	};
	
	stackToBoxCount = 0;
	
	int blockIndex = 0;
	for (char i='a'; i<='l'; i++) {
		LetterStack *stack = [gameState getStackForLetter:i];
		int letterCount = [stack.letterBlockList count];
		
		for (int j=0; j<letterCount; j++) {
			letterModelMatrix[blockIndex] = mat;
			letterModelMatrix[blockIndex].w = blockTranslation;
			blockIndex++;
			blockTranslation.y -= letterBlockSize.d;
		}
		[lettersList addObject:[NSMutableArray arrayWithArray:stack.letterBlockList]];
		
		letterBoxTranslation.y -= letterBlockSize.d*letterCount;
		mat.w = letterBoxTranslation;
		MatrixMultiply(&boxMatrix, &mat, &mat2);
		mat.w.z = 0;
		MatrixMultiply(&boxMatrix, &mat, &mat3);
		
		stackToBoxCount++;
		stack.animationStopDelegate = self;
		stack.animationStopSelector = @selector(stackMoveComplete:);
		
		[stack startMoveToBoxAnimation:1.0 Stage1Matrix:mat2 Stage2Matrix:mat3];
	}
	
	letterBoxTranslation.x = -letterBoxTranslation.x;
	letterBoxTranslation.y = 22*letterBlockSize.d;

	blockTranslation.x = letterBoxTranslation.x;
	blockTranslation.y = letterBoxTranslation.y;

	for (char i='m'; i<='z'; i++) {
		LetterStack *stack = [gameState getStackForLetter:i];
		int letterCount = [stack.letterBlockList count];
		
		for (int j=0; j<letterCount; j++) {
			letterModelMatrix[blockIndex] = mat;
			letterModelMatrix[blockIndex].w = blockTranslation;
			blockIndex++;
			blockTranslation.y -= letterBlockSize.d;
		}
		[lettersList addObject:[NSMutableArray arrayWithArray:stack.letterBlockList]];

		letterBoxTranslation.y -= letterBlockSize.d*letterCount;
		mat.w = letterBoxTranslation;
		MatrixMultiply(&boxMatrix, &mat, &mat2);
		mat.w.z = 0;
		MatrixMultiply(&boxMatrix, &mat, &mat3);

		stackToBoxCount++;
		stack.animationStopDelegate = self;
		stack.animationStopSelector = @selector(stackMoveComplete:);

		[stack startMoveToBoxAnimation:1.0 Stage1Matrix:mat2 Stage2Matrix:mat3];
	}
}

-(void)stackMoveComplete:(LetterStack*)stack {
	stack.animationStopDelegate = nil;
	stack.animationStopSelector = nil;
	stackToBoxCount--;
	if (stackToBoxCount == 0) {
		mat4 *boxMatrix = box.modelMatrix;
		NezAnimation *ani = [[NezAnimation alloc] initWithFromData:&boxMatrix->x.x ToData:&originalBoxMatrix.x.x DataLength:sizeof(mat4) Duration:1.6 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBox:) DidStopSelector:@selector(resetBoxDidStop:)];
		[[NezAnimator instance] addAnimation:ani];

		mat4 *lidMatrix = lid.modelMatrix;
		vec3 midPoint = [lid getMidPoint];
		vec3 endPos = {originalLidMatrix.w.x, originalLidMatrix.w.y, originalLidMatrix.w.z};
		
		NezCubicBezierAnimation *cbani = [[NezCubicBezierAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:2.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateLid:) DidStopSelector:@selector(animationDidStop:)];
		vec3 P1 = {midPoint.x+(endPos.x-midPoint.x)*0.25, midPoint.y+(endPos.y-midPoint.y)*0.25, midPoint.z+(endPos.z-midPoint.z)*(5.0)};
		vec3 P2 = {midPoint.x+(endPos.x-midPoint.x)*0.75, midPoint.y+(endPos.y-midPoint.y)*0.75, midPoint.z+(endPos.z-midPoint.z)*(5.0)};
		cbani->bezier = [[NezCubicBezier alloc] initWithControlPointsP0:midPoint P1:P1 P2:P2 P3:endPos];
		[[NezAnimator instance] addAnimation:cbani];

		NezAnimation *lidRotAni = [[NezAnimation alloc] initWithFromData:&lidMatrix->x.x ToData:&originalLidMatrix.x.x DataLength:sizeof(mat4) Duration:1.4 EasingFunction:&easeInCubic CallbackObject:self UpdateSelector:@selector(animateLidRotation:) DidStopSelector:@selector(animationDidStop:)];
		[[NezAnimator instance] addAnimation:lidRotAni];
		
	}
}

-(void)setColor:(color4uc)color {
	[box setColor:color];
	[lid setColor:color];
}

-(void)resetBoxDidStop:(NezAnimation*)ani {
	[ani release];
}

-(void)dealloc {
	[box release];
	[lid release];
	[lettersList release];
	[super dealloc];
}

@end
