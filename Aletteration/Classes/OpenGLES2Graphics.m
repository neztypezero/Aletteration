//
//  OpenGLES2Graphics.m
//  Aletteration
//
//  Created by David Nesbitt on 2/9/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "OpenGLES2Graphics.h"
#import "GLSLProgramManager.h"
#import "TextureManager.h"
#import "AnimatedCamera.h"
#import "NezCubicBezier.h"
#import "AletterationAppDelegate.h"
#import "matrix.h"
#import "NezVertexArray.h"
#import "GLSLProgram.h"

static OpenGLES2Graphics *g_GameGraphics = nil;

@interface OpenGLES2Graphics(private)

-(void)setMatrixAndRGBPaletteArray:(NezVertexArray*)vertexArray;

@end

@implementation OpenGLES2Graphics

@synthesize camera;
@synthesize light;

@synthesize screenScale;
@synthesize screenWidth;
@synthesize screenHeight;

static inline void setMatrixPaletteEntry(VertexAttributePaletteItem *paletteItem, mat43rm *mat43)
{
	mat43->xx = paletteItem->matrix.x.x;
	mat43->yx = paletteItem->matrix.y.x;
	mat43->zx = paletteItem->matrix.z.x;
	mat43->wx = paletteItem->matrix.w.x;
	
	mat43->xy = paletteItem->matrix.x.y;
	mat43->yy = paletteItem->matrix.y.y;
	mat43->zy = paletteItem->matrix.z.y;
	mat43->wy = paletteItem->matrix.w.y;
	
	mat43->xz = paletteItem->matrix.x.z;
	mat43->yz = paletteItem->matrix.y.z;
	mat43->zz = paletteItem->matrix.z.z;
	mat43->wz = paletteItem->matrix.w.z;
}

+(OpenGLES2Graphics*)instance {
	return(g_GameGraphics);
}

+(void)initializeWithContext:(EAGLContext*)context CamPos:(vec3)camPos CamTarget:(vec3)camTarget UpVector:(vec3)camUp LightPos:(vec3)lightPos LightTarget:(vec3)lightTarget {
	g_GameGraphics = [[OpenGLES2Graphics alloc] initWithContext:context CamPos:camPos CamTarget:camTarget UpVector:camUp LightPos:lightPos LightTarget:lightTarget];
}

-(id)initWithContext:(EAGLContext*)context CamPos:(vec3)camPos CamTarget:(vec3)camTarget UpVector:(vec3)camUp LightPos:(vec3)lightPos LightTarget:(vec3)lightTarget {
	if ((self = [super init])) {
		Vertex a;
		vertexOffset.pos        = ADDR_OFFSET(&a, &a.pos);
		vertexOffset.uv         = ADDR_OFFSET(&a, &a.uv);
		vertexOffset.normal     = ADDR_OFFSET(&a, &a.normal);
		vertexOffset.indexArray = ADDR_OFFSET(&a, &a.indexArray);

		AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		UIScreen *mainScreen = [UIScreen mainScreen];
		screenScale = mainScreen.scale;
		screenWidth = delegate.window.frame.size.height*screenScale;
		screenHeight = delegate.window.frame.size.width*screenScale;
		
		rect4f viewPort = {0, 0, screenHeight, screenWidth};
		[self setViewPort:viewPort];
		
		mat4 mat, rot;
		mat4f_LoadPerspective(RADIANS_60_DEGREES, screenWidth/screenHeight, 1.0f, 1200.0f, &mat.x.x);
		mat4f_LoadZRotation(-Nez_PI/2.0f, &rot.x.x);
		MatrixMultiply(&rot, &mat, &projectionMatrix);
		
		camera = [[AnimatedCamera alloc] initWithEye:camPos Target:camTarget UpVector:camUp];
		light = [[AnimatedCamera alloc] initWithEye:lightPos Target:lightTarget UpVector:camUp];
		
		[self setupMatrices];
		
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		glEnable(GL_CULL_FACE);
		glCullFace(GL_BACK);
		
		color4f clearColor = {1.0,1.0,1.0,1.0};
		[self setClearColor:clearColor];
	}
	return self;
}

-(void)setupMatrices {
	[self setupMatricesQuick];
	MatrixInverse(&modelViewProjectionMatrix, &inverseModelViewProjectionMatrix);
	
	mat4 m;
	MatrixMultiply(&modelViewProjectionMatrix, &inverseModelViewProjectionMatrix, &m);

	MatrixInverse(&modelViewMatrix, &inverseModelViewMatrix);
}

-(void)setupMatricesQuick {
	MatrixCopy([camera matrix], &modelViewMatrix);
	MatrixMultiply(&projectionMatrix, &modelViewMatrix, &modelViewProjectionMatrix);
}

-(void)setMatrixAndRGBPaletteArray:(NezVertexArray*)vertexArray {
	int paletteCount = vertexArray->paletteArrayCount;
	for (int i=0; i<paletteCount; i++) {
		VertexAttributePaletteItem *paletteItem = &vertexArray->paletteArray[i];

		setMatrixPaletteEntry(paletteItem, &matrixPalette[i]);
		
		colorPalette[i].r = ((paletteItem->color1.r*(1.0-paletteItem->mix))+(paletteItem->color2.r*(paletteItem->mix)))/255.0;
		colorPalette[i].g = ((paletteItem->color1.g*(1.0-paletteItem->mix))+(paletteItem->color2.g*(paletteItem->mix)))/255.0;
		colorPalette[i].b = ((paletteItem->color1.b*(1.0-paletteItem->mix))+(paletteItem->color2.b*(paletteItem->mix)))/255.0;
	}
}

-(void)setMatrixAndAlphaPaletteArray:(NezVertexArray*)vertexArray {
	int paletteCount = vertexArray->paletteArrayCount;
	for (int i=0; i<paletteCount; i++) {
		VertexAttributePaletteItem *paletteItem = &vertexArray->paletteArray[i];
		
		setMatrixPaletteEntry(paletteItem, &matrixPalette[i]);
		
		alphaPalette[i] = paletteItem->mix;
	}
}

-(void)setMatrixColorAndAlphaPaletteArray:(NezVertexArray*)vertexArray {
	int paletteCount = vertexArray->paletteArrayCount;
	for (int i=0; i<paletteCount; i++) {
		VertexAttributePaletteItem *paletteItem = &vertexArray->paletteArray[i];
		
		setMatrixPaletteEntry(paletteItem, &matrixPalette[i]);
		
		colorPalette[i].r = paletteItem->color2.r/255.0;
		colorPalette[i].g = paletteItem->color2.g/255.0;
		colorPalette[i].b = paletteItem->color2.b/255.0;
		
		alphaPalette[i] = (paletteItem->color2.a/255.0)*paletteItem->mix;
	}
}

-(vec4)getWorldPointWithPixelX:(float)x PixelY:(float)y WorldZ:(float)z {
	static mat4 inverseBias = {
		2.0, 0.0, 0.0, 0.0, 
		0.0, 2.0, 0.0, 0.0,
		0.0, 0.0, 2.0, 0.0,
		-1.0,-1.0,-1.0, 1.0
	};
	vec4 p = {y/screenHeight, x/screenWidth, 0, 1}, p1;
	MatrixMultVec4(&inverseBias, &p, &p1);
	
	vec4 p2 = {0, 0, z, 1}, p3;
	MatrixMultVec4(&modelViewProjectionMatrix, &p2, &p3);
	
	p1.x = -p1.x*p3.w;
	p1.y = -p1.y*p3.w;
	p1.z = p3.z;
	p1.w = 1;
	MatrixMultVec4(&inverseModelViewProjectionMatrix, &p1, &p);
	p.z = z;
	p.w = 1;

	return p;
}

-(vec4)getWorldPointWithScreenX:(float)x ScreenY:(float)y WorldZ:(float)z {
	return [self getWorldPointWithPixelX:x*screenScale PixelY:y*screenScale WorldZ:z];
}

-(vec2)getScreenPointWithX:(float)x Y:(float)y Z:(float)z {
	static mat4 bias = {	
		0.5, 0.0, 0.0, 0.0, 
		0.0, 0.5, 0.0, 0.0,
		0.0, 0.0, 0.5, 0.0,
		0.5, 0.5, 0.5, 1.0
	};
	
	vec4 p = {x, y, z, 1}, p1;
	MatrixMultVec4(&modelViewProjectionMatrix, &p, &p1);
	
	p1.x = -p1.x/p1.w;
	p1.y = -p1.y/p1.w;
	p1.z /= p1.w;
	p1.w = 1.0;
	
	MatrixMultVec4(&bias, &p1, &p);
	
	vec2 screenPoint = {p.y*(screenWidth), p.x*(screenHeight)};
	return screenPoint;
}

-(TextureInfo)loadTexture:(NSString*)texture {
	NSString *dir = [NSString stringWithFormat:@"Textures/%@", texture];
//	if ([TextureManager isPvrSupported]) {
//		return [[TextureManager instance] loadTextureWithPathForResource:texture ofType:@"pvr" inDirectory:dir withPixelFormat:kTexture2DPixelFormat_RGB_PVRTC4];
//	} else {
		return [[TextureManager instance] loadTextureOfType:@"png" inDirectory:dir withPixelFormat:kTexture2DPixelFormat_Automatic];
//	}
}

-(void)setTexture:(unsigned int)name Unit:(unsigned int)unit {
	//NSLog(@"setTexture name:%d unit:%d", name, unit);
	glActiveTexture(GL_TEXTURE0+unit);
	glBindTexture(GL_TEXTURE_2D, name);
}

-(void)attachVboToVertexArray:(NezVertexArray*)vertexArray DrawType:(unsigned int)type {
	vertexArray->bufferObjects = (unsigned int*)malloc(sizeof(unsigned int)*3);
	glGenVertexArraysOES(1, &vertexArray->bufferObjects[0]);
	glBindVertexArrayOES(vertexArray->bufferObjects[0]);
	
	glGenBuffers(2, &vertexArray->bufferObjects[1]);
	glBindBuffer(GL_ARRAY_BUFFER, vertexArray->bufferObjects[1]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex)*vertexArray->vertexCount, vertexArray->vertexList, GL_STATIC_DRAW);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexArray->bufferObjects[2]);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned short)*vertexArray->indexCount, vertexArray->indexList, GL_STATIC_DRAW);

	GLSLProgram *program = nil;
	switch(type) {
		case LIT_TRIANGLES:
			program = [[GLSLProgram alloc] initWithProgramName:@"VertexLightingVBO"];

			float ambiMaterialColor[] = {0.15f, 0.15f, 0.15f};
			float specMaterialColor[] = {0.7f, 0.7f, 0.7f};
			vec3 lightPos = [light getEye];
			float specularPower = 128.0f;

			glUseProgram(program->program);
			glUniform1i(program->u_texUnit, vertexArray->textureUnit);
			glUniform3fv(program->u_lightPosition, 1, &lightPos.x);
			glUniform3fv(program->u_ambientMaterial, 1, ambiMaterialColor);
			glUniform3fv(program->u_specularMaterial, 1, specMaterialColor);
			glUniform1fv(program->u_shininess, 1, &specularPower);
			
			break;
		case UNLIT_TEXTURED_TRIANGLES:
			program = [[GLSLProgram alloc] initWithProgramName:@"UnlitTextureVBO"];
			glUseProgram(program->program);
			glUniform1i(program->u_texUnit, vertexArray->textureUnit);
			break;
			
		case UNLIT_BLENDED_TEXTURED_TRIANGLES:
			program = [[GLSLProgram alloc] initWithProgramName:@"UnlitBlendedTextureVBO"];
			glUseProgram(program->program);
			glUniform1i(program->u_texUnit, vertexArray->textureUnit);
			break;
			
		case UNLIT_BLENDED_COLORED_TRIANGLES:
			program = [[GLSLProgramManager instance] loadProgram:@"UnlitBlendedColorVBO"];
			glUseProgram(program->program);
			break;
			
		case UNLIT_BLENDED_COLOR_BURNED_TRIANGLES:
			program = [[GLSLProgramManager instance] loadProgram:@"ColorBurn"];
			glUseProgram(program->program);
			glUniform1i(program->u_texUnit, vertexArray->textureUnit);
			break;
			
		case FIREWORKS_POINT_SPRITES:
			program = [[GLSLProgramManager instance] loadProgram:@"FireWorksPointSprites"];
			glUseProgram(program->program);
			glUniform1i(program->u_texUnit, vertexArray->textureUnit);
			glUniform1f(program->u_time, 0.0);
			break;
	}
		
	int stride = sizeof(Vertex);

	glEnableVertexAttribArray(program->a_position);
	glVertexAttribPointer(program->a_position, 3, GL_FLOAT, GL_FALSE, stride, vertexOffset.pos);

	glEnableVertexAttribArray(program->a_normal);
	glVertexAttribPointer(program->a_normal, 3, GL_FLOAT, GL_FALSE, stride, vertexOffset.normal);

	glEnableVertexAttribArray(program->a_uv);
	glVertexAttribPointer(program->a_uv, 2, GL_FLOAT, GL_FALSE, stride, vertexOffset.uv);

	glEnableVertexAttribArray(program->a_indexArray);
	glVertexAttribPointer(program->a_indexArray, 1, GL_UNSIGNED_BYTE, GL_FALSE, stride, vertexOffset.indexArray);

	glBindVertexArrayOES(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glUseProgram(0);
	
	vertexArray->program = program;
}

-(void)setBufferSubData:(NezVertexArray*)vertexArray Data:(void*)data Offset:(unsigned int)offset Size:(unsigned int)size {
	glBindBuffer(GL_ARRAY_BUFFER, vertexArray->bufferObjects[1]);
	glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)deleteVboFromVertexArray:(NezVertexArray*)vertexArray {
	if (vertexArray->bufferObjects) {
		glDeleteVertexArraysOES(1, &vertexArray->bufferObjects[0]);
		glDeleteBuffers(2, &vertexArray->bufferObjects[1]);
	}
	if (vertexArray->program != nil) {
		[vertexArray->program release];
	}
}

-(void)drawBackgroundTriangles:(unsigned int)textureUnit {
/*    float vertexList[] = {
        -1, 1,
        -1,-1,
        1, 1,
        1,-1,
    };
    float uvList[] = {
        1,0,
        0,0,
        1,1,
        0,1,
    };
		
    glUseProgram(backgroundProgram->program);

	glEnableVertexAttribArray(backgroundProgram->a_position);
	glEnableVertexAttribArray(backgroundProgram->a_uv);

    glVertexAttribPointer(backgroundProgram->a_position, 2, GL_FLOAT, GL_FALSE, 0, vertexList);
    glVertexAttribPointer(backgroundProgram->a_uv, 2, GL_FLOAT, GL_FALSE, 0, uvList);
    glUniform1i(backgroundProgram->u_texUnit, textureUnit);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);*/
}

-(void)drawUnlitBlendedTexturedTrianglesVBO:(NezVertexArray*)vertexArray {
	int indexCount = vertexArray->indexCount;
	if(indexCount > 0) {
		glEnable(GL_BLEND);

		GLSLProgram *programVBO = vertexArray->program;
		
		int paletteCount = vertexArray->paletteArrayCount;
		[self setMatrixAndAlphaPaletteArray:vertexArray];
		glUseProgram(programVBO->program);
		glUniformMatrix4fv(programVBO->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
		glUniform4fv(programVBO->u_matrixPalette, paletteCount*3, &matrixPalette[0].xx);
		glUniform1fv(programVBO->u_alphaPalette, paletteCount, alphaPalette);
		glUniform1i(programVBO->u_texUnit, vertexArray->textureUnit);
		
		glBindVertexArrayOES(vertexArray->bufferObjects[0]);
		glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, 0);
		glBindVertexArrayOES(0);
		
		glDisable(GL_BLEND);
	}
}

-(void)drawUnlitTexturedTrianglesVBO:(NezVertexArray*)vertexArray {
	int indexCount = vertexArray->indexCount;
	if(indexCount > 0) {
		GLSLProgram *programVBO = vertexArray->program;

		int paletteCount = vertexArray->paletteArrayCount;
		[self setMatrixAndAlphaPaletteArray:vertexArray];
		glUseProgram(programVBO->program);
		glUniformMatrix4fv(programVBO->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
		glUniform4fv(programVBO->u_matrixPalette, paletteCount*3, &matrixPalette[0].xx);
		glUniform1i(programVBO->u_texUnit, vertexArray->textureUnit);
		
		glBindVertexArrayOES(vertexArray->bufferObjects[0]);
		glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, 0);
		glBindVertexArrayOES(0);
	}
}

-(void)drawUnlitBlendedColoredTrianglesVBO:(NezVertexArray*)vertexArray {
	int indexCount = vertexArray->indexCount;
	if(indexCount > 0) {
		GLSLProgram *programVBO = vertexArray->program;

		glEnable(GL_BLEND);

		int paletteCount = vertexArray->paletteArrayCount;
		[self setMatrixColorAndAlphaPaletteArray:vertexArray];
		glUseProgram(programVBO->program);
		glUniformMatrix4fv(programVBO->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
		glUniform4fv(programVBO->u_matrixPalette, paletteCount*3, &matrixPalette[0].xx);
		glUniform3fv(programVBO->u_colorPalette, paletteCount, &colorPalette[0].r);
		glUniform1fv(programVBO->u_alphaPalette, paletteCount, alphaPalette);

		glBindVertexArrayOES(vertexArray->bufferObjects[0]);
		glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, 0);
		glBindVertexArrayOES(0);
		
		glDisable(GL_BLEND);
	}
}

-(void)drawUnlitBlendedColorBurnedTrianglesVBO:(NezVertexArray*)vertexArray {
	int indexCount = vertexArray->indexCount;
	if(indexCount > 0) {
		GLSLProgram *programVBO = vertexArray->program;
		
		glEnable(GL_BLEND);
		
		int paletteCount = vertexArray->paletteArrayCount;
		[self setMatrixColorAndAlphaPaletteArray:vertexArray];
		glUseProgram(programVBO->program);
		glUniformMatrix4fv(programVBO->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
		glUniform4fv(programVBO->u_matrixPalette, paletteCount*3, &matrixPalette[0].xx);
		glUniform3fv(programVBO->u_colorPalette, paletteCount, &colorPalette[0].r);
		glUniform1fv(programVBO->u_alphaPalette, paletteCount, alphaPalette);
		glUniform1i(programVBO->u_texUnit, vertexArray->textureUnit);
		
		glBindVertexArrayOES(vertexArray->bufferObjects[0]);
		glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, 0);
		glBindVertexArrayOES(0);
		
		glDisable(GL_BLEND);
	}
}

-(void)drawLitTrianglesVBO:(NezVertexArray*)vertexArray {
	int indexCount = vertexArray->indexCount;
	if(indexCount > 0) {
		GLSLProgram *programVBO = vertexArray->program;

		int paletteCount = vertexArray->paletteArrayCount;
		[self setMatrixAndRGBPaletteArray:vertexArray];
		glUseProgram(programVBO->program);
		glUniformMatrix4fv(programVBO->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
		glUniform4fv(programVBO->u_matrixPalette, paletteCount*3, &matrixPalette[0].xx);
		glUniform3fv(programVBO->u_colorPalette, paletteCount, &colorPalette[0].r);
		glUniform1i(programVBO->u_texUnit, vertexArray->textureUnit);
		
		glBindVertexArrayOES(vertexArray->bufferObjects[0]);
		glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_SHORT, 0);
		glBindVertexArrayOES(0);
	}
}

-(void)drawFireWorksPointSpritesVBO:(NezVertexArray*)vertexArray {
	int indexCount = vertexArray->indexCount;
	if(indexCount > 0) {
		GLSLProgram *programVBO = vertexArray->program;

		glEnable(GL_BLEND);

		int paletteCount = vertexArray->paletteArrayCount;
		[self setMatrixAndAlphaPaletteArray:vertexArray];
		glUseProgram(programVBO->program);
		glUniformMatrix4fv(programVBO->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
		glUniform4fv(programVBO->u_matrixPalette, paletteCount*3, &matrixPalette[0].xx);
		glUniform1i(programVBO->u_texUnit, vertexArray->textureUnit);
		glUniform1f(programVBO->u_time, vertexArray->now-vertexArray->startTime);
		
		glBindVertexArrayOES(vertexArray->bufferObjects[0]);
		glDrawElements(GL_POINTS, indexCount, GL_UNSIGNED_SHORT, 0);
		glBindVertexArrayOES(0);

		glDisable(GL_BLEND);
	}
}



-(void)drawBezierCurve:(NezCubicBezier*)bezier {
/*	color4uc color = {255,0,0,255};
	color4uc controlPointColor = {0,0,255,255};
	VertexPC p[4] = {
		{bezier.p0, controlPointColor},
		{bezier.p1, controlPointColor},
		{bezier.p2, controlPointColor},
		{bezier.p3, controlPointColor},
	};
	
	int steps = 25;
	
	VertexPC lineVertexList[steps];
	for (int i=0; i<steps; i++) {
		lineVertexList[i].pos = [bezier positionAt:((float)i/((float)steps-1))];
		lineVertexList[i].color = color;
	}
	GLSLProgram *flatShadedProgram = [[GLSLProgramManager instance] loadProgram:@"FlatShaded"];

	glUseProgram(flatShadedProgram->program);
	glUniformMatrix4fv(flatShadedProgram->u_modelViewProjectionMatrix, 1, GL_FALSE, &modelViewProjectionMatrix.x.x);
	glEnableVertexAttribArray(flatShadedProgram->a_position);
	glEnableVertexAttribArray(flatShadedProgram->a_color);

	int stride = sizeof(VertexPC);
	glVertexAttribPointer(flatShadedProgram->a_position, 3, GL_FLOAT, GL_FALSE, stride, &lineVertexList[0].pos);
	glVertexAttribPointer(flatShadedProgram->a_color, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, &lineVertexList[0].color);
	glDrawArrays(GL_LINE_STRIP, 0, steps);

	glVertexAttribPointer(flatShadedProgram->a_position, 3, GL_FLOAT, GL_FALSE, stride, &p[0].pos);
	glVertexAttribPointer(flatShadedProgram->a_color, 4, GL_UNSIGNED_BYTE, GL_TRUE, stride, &p[0].color);
	glDrawArrays(GL_POINTS, 0, 4);*/
}

-(void)glEnable:(SETTABLE_GL_STATES)state {
	glEnable(state);
}

-(void)glDisable:(SETTABLE_GL_STATES)state {
	glDisable(state);
}

-(void)setClearColor:(color4f)c {
    glClearColor(c.r, c.g, c.b, c.a);
}

-(void)setViewPort:(rect4f)r {
    glViewport(r.x, r.y, r.w, r.h);
}

-(void)setGLBlendSrc:(GL_BLEND_FUNCTIONS)src Dst:(GL_BLEND_FUNCTIONS)dst {
	glBlendFunc(src, dst);
}

-(void)clearBuffer {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

-(void)dealloc {
	//NSLog(@"dealloc:OpenGLES2Graphics");
	[camera release];
	[light release];
	[super dealloc];
}

@end
