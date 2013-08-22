//
//  NezModelLoader.h
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"
#import "NezVertexArray.h"


@interface NezModelLoader : NSObject {
	NezVertexArray *vertexArray;
	size3 dimensions;
}

+(NSString*)getModelResourceWithFile:(NSString*)filename Type:(NSString*)fileType;
+(NSString*)getModelResourceWithFile:(NSString*)filename Type:(NSString*)fileType Dir:(NSString*)dir;

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir;
+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic;

-(id)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir;

@property(nonatomic, readonly, getter=getVertexCount) int vertexCount;
@property(nonatomic, readonly, getter=getVertexList) Vertex* vertexList;
@property(nonatomic, readonly, getter=getIndexCount) int indexCount;
@property(nonatomic, readonly, getter=getIndexList) unsigned short *indexList;
@property(nonatomic, readonly, getter=getDimensions) size3 size;

@end
