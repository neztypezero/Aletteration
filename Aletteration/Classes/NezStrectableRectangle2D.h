//
//  NezStrectableRectangle2D.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-21.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"


#define NSR_INDEXED_LINE_INDEX_COUNT 6*3
#define NSR_INDEXED_LINE_VERTEX_COUNT 4*3

@interface NezStrectableRectangle2D : NezGeometry {
	Vertex vertexPtr[NSR_INDEXED_LINE_INDEX_COUNT];
	
	float rectWidth;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray;

-(void)setUVwithU1:(float)u1 V1:(float)v1 U2:(float)u2 V2:(float)v2;
-(void)setUV:(vec4)uv;

-(void)setRectWidth:(float)newWidth andHeight:(float)newHeight;

@end
