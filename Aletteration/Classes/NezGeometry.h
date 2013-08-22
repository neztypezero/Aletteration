//
//  NezGeometry.h
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"
#import "NezVertexArray.h"


@interface NezGeometry : NSObject {
	vec3 min, max;
	size3 dimensions;
	size3 originalDimensions;
	vec3 originalScale;
	
	VertexAttributePaletteItem *attributes;
	
	NezVertexArray *bufferedVertexArray;
	unsigned int bufferOffset;
}
-(id)initWithVertexArray:(NezVertexArray*)vertexArray;
-(id)initWithVertexArray:(NezVertexArray*)vertexArray modelMatrix:(mat4)mat color:(color4uc)c;

-(int)getModelVertexCount;
-(Vertex*)getModelVertexList;
-(unsigned short*)getModelIndexList;
-(unsigned short)getModelIndexCount;

-(void)setScale:(float)scale;
-(void)setXScale:(float)xScale YScale:(float)yScale ZScale:(float)zScale;

-(void)offsetWithDX:(float)dx DY:(float)dy DZ:(float)dz;
-(void)setBoundingPoints;
-(void)setBoxWithMidPoint:(vec3*)pos;
-(void)setModelMaxtrix:(mat4*)mat;

-(void)setColor:(color4uc)c;
-(void)setColor:(color4uc)c andMix:(float)mix;
-(void)setMix:(float)mix;
-(float)getMix;

-(vec3)getMidPoint;
-(vec2)getMidScreenPoint;
-(size3)getSize;

-(BOOL)containsPoint:(vec4)point;
-(BOOL)containsPoint:(vec4)point withExtraSize:(size3)extra;
-(BOOL)containsPoint:(vec4)point withExtraLeft:(float)left Top:(float)top Right:(float)right Bottom:(float)bottom Down:(float)down Up:(float)up;
-(void)startFadeInAnimationWithDelay:(float)delay;

-(void)translateToGeometry:(NezGeometry*)geometry;

-(color4uc)getColor;

@property (nonatomic, readonly, getter = getColor) color4uc color;

@property (nonatomic, readonly, getter=getMinX) float minX;
@property (nonatomic, readonly, getter=getMaxX) float maxX;
@property (nonatomic, readonly, getter=getMinY) float minY;
@property (nonatomic, readonly, getter=getMaxY) float maxY;
@property (nonatomic, readonly, getter=getMinZ) float minZ;
@property (nonatomic, readonly, getter=getMaxZ) float maxZ;

@property (nonatomic, readonly, getter=getOriginalSize) size3 originalSize;
@property (nonatomic, readonly, getter=getSize) size3 size;
@property (nonatomic, readonly, getter=getMix) float mix;

@property (nonatomic, assign, getter=getModelMaxtrix, setter=setModelMaxtrix:) mat4 *modelMatrix;

@end
