//
//  NezVertexArrayArray.m
//  Aletteration
//
//  Created by David Nesbitt on 3/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArrayArray.h"

#define VERTEX_ARRAY_INCREMENT 16

@interface NezVertexArrayArray(private)

-(void)extendArray;

@end

@implementation NezVertexArrayArray

-(id)init {
	if ((self = [super init])) {
		vertexArrayCount = 0;
		vertexArrayLength = 0;
		vertexArrayIncrement = VERTEX_ARRAY_INCREMENT;
		vertexArrayList = NULL;
		[self extendArray];
	}
	return self;
}

-(void)extendArray {
	int count = vertexArrayLength+vertexArrayIncrement;
	void *list = malloc(sizeof(NezVertexArray*)*(count));
	if (vertexArrayCount > 0) {
		memcpy(list, vertexArrayList, vertexArrayCount);
		free(vertexArrayList);
	}
	vertexArrayList = list;
	vertexArrayLength = count;
}

-(void)addVertexArray:(NezVertexArray*)vertexArray {
	if (vertexArrayCount >= vertexArrayLength) {
		[self extendArray];
	}
	vertexArrayList[vertexArrayCount++] = [vertexArray retain];
}

-(void)dealloc {
	//NSLog(@"dealloc:NezVertexArrayArray");
	for (int i=0; i<vertexArrayCount; i++) {
		[vertexArrayList[i] release];
	}
	free(vertexArrayList);
	[super dealloc];
}

@end
