//
//  ES2Renderer.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GLSLProgram.h"

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;
	
    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
	
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
	GLuint depthBuffer;
}

-(void)render:(NezBaseSceneView*)scene;
-(BOOL)resizeFromLayer:(CAEAGLLayer*)layer;

@end

