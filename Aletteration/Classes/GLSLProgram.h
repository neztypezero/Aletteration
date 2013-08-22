//
//  GLSLProgram.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_NAME_LENGTH 128

@interface GLSLProgram : NSObject {
@public
	GLuint program;
	GLint a_normal;
	GLint a_indexArray;
	GLint a_uv;
	GLint a_position;
	GLint u_lightPosition;
	GLint u_alphaPalette;
	GLint u_specularMaterial;
	GLint u_modelViewProjectionMatrix;
	GLint u_ambientMaterial;
	GLint u_matrixPalette;
	GLint u_time;
	GLint u_colorPalette;
	GLint u_shininess;
	GLint u_texUnit;
}

- (id)initWithProgramName:(NSString*)programName;

@end

