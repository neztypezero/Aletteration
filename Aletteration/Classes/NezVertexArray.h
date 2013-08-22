//
//  NezVertexArray.h
//  Aletteration
//
//  Created by David Nesbitt on 3/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"

@class GLSLProgram;

typedef struct VertexAttributePaletteItem {
	mat4 matrix;
	color4uc color1;
	color4uc color2;
	float mix;
} VertexAttributePaletteItem;

@interface NezVertexArray : NSObject {
	int indexArrayLength;
	int indexArrayIncrement;

	int vertexArrayLength;
	int vertexArrayIncrement;

	int paletteArrayLength;
	int paletteArrayIncrement;
@public
	int indexCount;
	unsigned short *indexList;
	int vertexCount;
	Vertex *vertexList;
	
	unsigned int *bufferObjects;
	
	VertexAttributePaletteItem *paletteArray;
	int paletteArrayCount;
	
	unsigned int textureUnit;
	
	BOOL animating;
	NSTimeInterval startTime, now;
	
	GLSLProgram *program;
}

-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc;
-(id)initWithVertexIncrement:(int)vInc indexIncrement:(int)iInc TextureUnit:(int)texUnit;

-(void)reserveVertices:(int)vertexCount Indices:(int)indexCount;
-(BOOL)canHoldMorePaletteEntries:(int)paletteCount;

-(void)attachVboWithDrawType:(unsigned int)type;

@end
