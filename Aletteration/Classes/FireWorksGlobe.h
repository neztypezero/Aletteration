//
//  FireWorksGlobe.h
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"
#import "NezGeometry.h"
#import "NezVertexArray.h"

@interface FireWorksGlobe : NezGeometry {
	Vertex *vertexList;
	unsigned short *indexList;
	CFTimeInterval startTime;
}

-(id)initWithVertexArray:(NezVertexArray*)vertexArray;

-(void)startFireWorks:(CFTimeInterval)now;

-(void)setUV:(vec2)uv;

@end
