//
//  NezVertexArray.m
//  Aletteration
//
//  Created by David Nesbitt on 3/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArray.h"
#import "OpenGLES2Graphics.h"


@interface NezVertexArray(private)

-(void)extendArray:(void**)array length:(int*)length count:(int)currentCount total:(int)total increment:(int)increment stride:(int)stride;

@end

@implementation NezVertexArray

-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc {
	return [self initWithVertexIncrement:vInc indexIncrement:iInc TextureUnit:-1];
}

-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc TextureUnit:(int)texUnit {
	if ((self = [super init])) {
		indexArrayIncrement = iInc;
		vertexArrayIncrement = vInc;
		paletteArrayIncrement = MATRIX_PALETTE_COUNT;
		
		indexArrayLength = 0;
		vertexArrayLength = 0;
		paletteArrayLength = 0;
		
		indexCount = 0;
		vertexCount = 0;
		paletteArrayCount = 0;
		
		bufferObjects = 0;
		
		textureUnit = texUnit;
		
		animating = NO;
		startTime = 0;
		now = 0;
		
		program = nil;

		[self extendArray:(void**)&paletteArray length:&paletteArrayLength count:0 total:paletteArrayIncrement increment:paletteArrayIncrement stride:sizeof(VertexAttributePaletteItem)];
		[self extendArray:(void**)&indexList length:&indexArrayLength count:0 total:indexArrayIncrement increment:indexArrayIncrement stride:sizeof(unsigned short)];
		[self extendArray:(void**)&vertexList length:&vertexArrayLength count:0 total:vertexArrayIncrement increment:vertexArrayIncrement stride:sizeof(Vertex)];
	}
	return self;
}

-(void)extendArray:(void**)array length:(int*)length count:(int)currentCount total:(int)total increment:(int)increment stride:(int)stride {
	int count = (*length)+increment;
	while (count < total) {
		count += increment;
	}
	void *list = malloc(stride*count);
	if (currentCount > 0) {
		memcpy(list, *array, stride*currentCount);
		free(*array);
	}
	*array = list;
	*length = count;
}

-(void)reserveVertices:(int)vCount Indices:(int)iCount {
	if (indexCount+iCount > indexArrayLength) {
		[self extendArray:(void**)&indexList length:&indexArrayLength count:indexCount total:indexCount+iCount increment:indexArrayIncrement stride:sizeof(unsigned short)];
	}
	if (vertexCount+vCount > vertexArrayLength) {
		[self extendArray:(void**)&vertexList length:&vertexArrayLength count:vertexCount total:vertexCount+vCount increment:vertexArrayIncrement stride:sizeof(Vertex)];
	}
}

-(BOOL)canHoldMorePaletteEntries:(int)paletteCount {
	return (paletteArrayCount+paletteCount <= paletteArrayLength);
}

-(void)attachVboWithDrawType:(unsigned int)type {
	[[OpenGLES2Graphics instance] attachVboToVertexArray:self DrawType:type];
	free(indexList);
	indexList = 0;
	free(vertexList);
	vertexList = 0;
}

-(void)dealloc {
	//NSLog(@"dealloc:NezVertexArray");
	if (indexList) {
		free(indexList);
	}
	if (vertexList) {
		free(vertexList);
	}
	if (paletteArray) {
		free(paletteArray);
	}
	[[OpenGLES2Graphics instance] deleteVboFromVertexArray:self];
	[super dealloc];
}

@end
