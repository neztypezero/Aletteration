//
//  NezModelLoader.m
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezModelLoader.h"

static NSString *DEFAULT_MODEL_DIR = @"Models";

@implementation NezModelLoader

+(NSString*)getModelResourceWithFile:(NSString*)filename Type:(NSString*)fileType {
	return [NezModelLoader getModelResourceWithFile:filename Type:fileType Dir:DEFAULT_MODEL_DIR];
	
}

+(NSString*)getModelResourceWithFile:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir {
	return [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	return nil;
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic {
	return nil;
}

-(id)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	if ((self=[super init])) {
		vertexArray = [NezModelLoader loadVertexArrayWithFile:file Type:ext Dir:dir];
		dimensions = SIZE3ZERO;
	}
	return self;
}

-(int)getVertexCount {
	return vertexArray->vertexCount;
}

-(Vertex*)getVertexList {
	return vertexArray->vertexList;
}

-(int)getIndexCount {
	return vertexArray->indexCount;
}

-(unsigned short*)getIndexList {
	return vertexArray->indexList;
}

-(size3)getDimensions {
	return dimensions;
}

@end
