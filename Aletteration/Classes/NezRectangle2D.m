//
//  NezRectangle2D.m
//  Aletteration
//
//  Created by David Nesbitt on 3/18/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezRectangle2D.h"
#import "OpenGLES2Graphics.h"

static unsigned short LINE_INDEX_LIST[] = {
	0, 1, 2, 
	2, 1, 3, 
};

static Vertex LINE_VERTICES[] = {
	{  0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, //top
	{ -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, //top
	{  0.5,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, //top
	{ -0.5,-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 }, //top
};

@implementation NezRectangle2D

-(int)getModelVertexCount {
	return INDEXED_LINE_VERTEX_COUNT;
}

-(Vertex*)getModelVertexList {
	return LINE_VERTICES;
}

-(unsigned short)getModelIndexCount {
	return INDEXED_LINE_INDEX_COUNT;
}

-(unsigned short*)getModelIndexList {
	return LINE_INDEX_LIST;
}

-(void)setUVwithU1:(float)u1 V1:(float)v1 U2:(float)u2 V2:(float)v2 {
	vec4 uv = {u1, v1, u2, v2};
	[self setUV:uv];
}

-(void)setUV:(vec4)uv {
	if (bufferedVertexArray->bufferObjects) {
		vertexPtr[0].uv.x = uv.x;
		vertexPtr[0].uv.y = uv.y;
		
		vertexPtr[1].uv.x = uv.z;
		vertexPtr[1].uv.y = uv.y;
		
		vertexPtr[2].uv.x = uv.x;
		vertexPtr[2].uv.y = uv.w;
		
		vertexPtr[3].uv.x = uv.z;
		vertexPtr[3].uv.y = uv.w;
		[[OpenGLES2Graphics instance] setBufferSubData:bufferedVertexArray Data:vertexPtr Offset:bufferOffset*sizeof(Vertex) Size:INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex)];
	} else {
		Vertex *v = &bufferedVertexArray->vertexList[bufferOffset];
		v[0].uv.x = uv.x;
		v[0].uv.y = uv.y;
		
		v[1].uv.x = uv.z;
		v[1].uv.y = uv.y;
		
		v[2].uv.x = uv.x;
		v[2].uv.y = uv.w;
		
		v[3].uv.x = uv.z;
		v[3].uv.y = uv.w;
		memcpy(vertexPtr, v, INDEXED_LINE_VERTEX_COUNT*sizeof(Vertex));
	}
}

@end
