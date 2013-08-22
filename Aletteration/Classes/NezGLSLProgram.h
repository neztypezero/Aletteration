//
//  NezGLSLProgram.h
//  Aletteration
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_NAME_LENGTH 128

@interface NezGLSLProgram : NSObject {
@public
	GLuint program;
	GLint a_indexArray;
	GLint a_position;
	GLint a_uv;
	GLint a_normal;
	GLint u_ambientMaterial;
	GLint u_lightPosition;
	GLint u_modelViewProjectionMatrix;
	GLint u_shininess;
	GLint u_matrixPalette;
	GLint u_colorPalette;
	GLint u_specularMaterial;
	GLint u_alphaPalette;
	GLint u_time;
	GLint u_texUnit;
}

- (id)initWithProgramName:(NSString*)programName;

@end

