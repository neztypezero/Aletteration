//
//  LetterBlock.m
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "FireWorksGlobe.h"
#import "AletterationBox.h"
#import "Math.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezCubicBezierAnimation.h"
#import "SimpleObjLoader.h"
#import "matrix.h"
#import "NezOpenAL.h"
#import "NezCubicBezier.h"


#define NUM_FIREWORKS_PARTICLES 400
#define VELOCITY 6.0

@implementation FireWorksGlobe

-(int)getModelVertexCount {
	return NUM_FIREWORKS_PARTICLES;
}

-(Vertex*)getModelVertexList {
	return vertexList;
}

-(unsigned short)getModelIndexCount {
	return NUM_FIREWORKS_PARTICLES;
}

-(unsigned short*)getModelIndexList {
	return indexList;
}

-(vec3)getVelocity {
	vec3 v = {
		((randomNumber()*2.0)-1.0),
		((randomNumber()*2.0)-1.0),
		((randomNumber()*2.0)-1.0)
	};
	
	return v;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray {
	mat4 mat = IDENTITY_MATRIX;
	
	color4uc c = {0,0,0,0};

	vertexList = malloc(sizeof(Vertex)*NUM_FIREWORKS_PARTICLES);
	indexList = malloc(sizeof(unsigned short)*NUM_FIREWORKS_PARTICLES);
	

	double dlong = Nez_PI*(3-sqrt(5));  // ~2.39996323
	double dz    = 2.0/NUM_FIREWORKS_PARTICLES;
	double theta = 0;
	double z     = (1 - dz/2);
	for (int k=0;k<NUM_FIREWORKS_PARTICLES;k++) {
		double r = sqrt(1-z*z);
		vertexList[k].pos.x = (cos(theta)*r)*VELOCITY;
		vertexList[k].pos.y = (sin(theta)*r)*VELOCITY;
		vertexList[k].pos.z = (z)*VELOCITY;
		z -= dz;
		theta += dlong;

		indexList[k] = k;
	}
	
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
	}
	return self;
}

-(void)setUV:(vec2)uv {
	Vertex *v;
	if (bufferedVertexArray->bufferObjects) {
		v = vertexList;
	} else {
		v = &bufferedVertexArray->vertexList[bufferOffset];
	}
	for (int i=0; i<NUM_FIREWORKS_PARTICLES; i++) {
		v[i].uv = uv;
		v[i].uv = uv;
	}

	if (bufferedVertexArray->bufferObjects) {
		[[OpenGLES2Graphics instance] setBufferSubData:bufferedVertexArray Data:v Offset:bufferOffset*sizeof(Vertex) Size:NUM_FIREWORKS_PARTICLES*sizeof(Vertex)];
	} else {
		memcpy(vertexList, v, NUM_FIREWORKS_PARTICLES*sizeof(Vertex));
	}
}

-(void)dealloc {
	//NSLog(@"dealloc:LetterBlock");
	[super dealloc];
}

-(void)startFireWorks:(CFTimeInterval)now {
}

@end
