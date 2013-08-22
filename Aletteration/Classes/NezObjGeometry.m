//
//  NezObjGeometry.m
//  Aletteration
//
//  Created by David Nesbitt on 3/15/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezObjGeometry.h"
#import "SimpleObjLoader.h"


@implementation NezObjGeometry

-(int)getModelVertexCount {
	return objVertexArray->vertexCount;
}

-(Vertex*)getModelVertexList {
	return objVertexArray->vertexList;
}

-(unsigned short)getModelIndexCount {
	return objVertexArray->indexCount;
}

-(unsigned short*)getModelIndexList {
	return objVertexArray->indexList;
}

-(id)initWithObjFile:(NSString*)name VertexArray:(NezVertexArray*)vertexArray modelMatrix:(mat4)mat color:(color4uc)c {
	objVertexArray = [SimpleObjLoader loadVertexArrayWithFile:name Type:@"obj" Dir:@"Models"];
	if (objVertexArray) {
		if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:c])) {
			
		}
		return self;
	}
	return nil;
}

@end
