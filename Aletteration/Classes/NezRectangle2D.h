//
//  NezRectangle2D.h
//  Aletteration
//
//  Created by David Nesbitt on 3/18/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"


#define INDEXED_LINE_INDEX_COUNT 6
#define INDEXED_LINE_VERTEX_COUNT 4

@interface NezRectangle2D : NezGeometry {
	Vertex vertexPtr[INDEXED_LINE_VERTEX_COUNT];
}

-(void)setUVwithU1:(float)u1 V1:(float)v1 U2:(float)u2 V2:(float)v2;
-(void)setUV:(vec4)uv;

@end
