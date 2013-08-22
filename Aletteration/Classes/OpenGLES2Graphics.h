//
//  OpenGLES2Graphics.h
//  Aletteration
//
//  Created by David Nesbitt on 2/9/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "GLSLProgram.h"
#import "Structures.h"
#import <QuartzCore/QuartzCore.h>

typedef enum DRAW_TYPES {
	LIT_TRIANGLES,
	UNLIT_TEXTURED_TRIANGLES,
	UNLIT_BLENDED_TEXTURED_TRIANGLES,
	UNLIT_BLENDED_COLORED_TRIANGLES,
	UNLIT_BLENDED_COLOR_BURNED_TRIANGLES,
	FIREWORKS_POINT_SPRITES,
} DRAW_TYPES;

typedef enum SETTABLE_GL_STATES {
	GLES2_DEPTH_TEST = GL_DEPTH_TEST,
	GLES2_GL_BLEND = GL_BLEND,
} SETTABLE_GL_STATES;


typedef enum GL_BLEND_FUNCTIONS {
	GLES2_GL_SRC_ALPHA = GL_SRC_ALPHA, 
	GLES2_GL_ONE_MINUS_SRC_ALPHA = GL_ONE_MINUS_SRC_ALPHA,
	GLES2_GL_ONE = GL_ONE,
} GL_BLEND_FUNCTIONS;

@class NezCubicBezier, AnimatedCamera, NezVertexArray;

@interface OpenGLES2Graphics : NSObject {
	float screenScale;
	float screenWidth;
	float screenHeight;
	
	mat4 projectionMatrix;
	mat4 modelViewMatrix;
	mat4 modelViewProjectionMatrix;
	mat4 inverseModelViewProjectionMatrix;
	mat4 inverseModelViewMatrix;
	
	AnimatedCamera *camera;
	AnimatedCamera *light;
	
	VertexOffset vertexOffset;
	
	mat43rm matrixPalette[MATRIX_PALETTE_COUNT];
	color3f colorPalette[MATRIX_PALETTE_COUNT];
	float alphaPalette[MATRIX_PALETTE_COUNT];
}

+(OpenGLES2Graphics*)instance;
+(void)initializeWithContext:(EAGLContext*)context CamPos:(vec3)camPos CamTarget:(vec3)camTarget UpVector:(vec3)camUp LightPos:(vec3)lightPos LightTarget:(vec3)lightTarget;

-(id)initWithContext:(EAGLContext*)context CamPos:(vec3)camPos CamTarget:(vec3)camTarget UpVector:(vec3)camUp LightPos:(vec3)lightPos LightTarget:(vec3)lightTarget;

-(void)setupMatrices;
-(void)setupMatricesQuick;

-(void)glEnable:(SETTABLE_GL_STATES)state;
-(void)glDisable:(SETTABLE_GL_STATES)state;

-(void)setClearColor:(color4f)c;
-(void)setViewPort:(rect4f)r;

-(void)setGLBlendSrc:(GL_BLEND_FUNCTIONS)src Dst:(GL_BLEND_FUNCTIONS)dst;

-(vec4)getWorldPointWithPixelX:(float)x PixelY:(float)y WorldZ:(float)z;
-(vec4)getWorldPointWithScreenX:(float)x ScreenY:(float)y WorldZ:(float)z;
-(vec2)getScreenPointWithX:(float)x Y:(float)y Z:(float)z;

-(TextureInfo)loadTexture:(NSString*)texture;
-(void)setTexture:(unsigned int)name Unit:(unsigned int)unit;

-(void)attachVboToVertexArray:(NezVertexArray*)vertexArray DrawType:(unsigned int)type;
-(void)deleteVboFromVertexArray:(NezVertexArray*)vertexArray;
-(void)setBufferSubData:(NezVertexArray*)vertexArray Data:(void*)data Offset:(unsigned int)offset Size:(unsigned int)size;

-(void)drawUnlitTexturedTrianglesVBO:(NezVertexArray*)vertexArray;
-(void)drawUnlitBlendedTexturedTrianglesVBO:(NezVertexArray*)vertexArray;
-(void)drawUnlitBlendedColoredTrianglesVBO:(NezVertexArray*)vertexArray;
-(void)drawUnlitBlendedColorBurnedTrianglesVBO:(NezVertexArray*)vertexArray;
-(void)drawLitTrianglesVBO:(NezVertexArray*)vertexArray;
-(void)drawBezierCurve:(NezCubicBezier*)bezier;
-(void)drawBackgroundTriangles:(unsigned int)textureUnit;
-(void)drawFireWorksPointSpritesVBO:(NezVertexArray*)vertexArray;

-(void)clearBuffer;

@property(nonatomic, readonly) AnimatedCamera *camera;
@property(nonatomic, readonly) AnimatedCamera *light;

@property(nonatomic, readonly) float screenScale;
@property(nonatomic, readonly) float screenWidth;
@property(nonatomic, readonly) float screenHeight;

@end
