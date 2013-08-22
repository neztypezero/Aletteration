//
//  ES2Renderer.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//

#import "ES2Renderer.h"
#import "GLSLProgramManager.h"
#import "NezBaseSceneView.h"

@interface ES2Renderer (private)

-(void)createOffscreenFrameBuffer;

@end

@implementation ES2Renderer

// Create an OpenGL ES 2.0 context
- (id)init {
    if ((self = [super init])) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffers(1, &defaultFramebuffer);
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		depthBuffer = 0;
	}
	
    return self;
}

-(EAGLContext*)getContext {
	return context;
}

-(void)render:(NezBaseSceneView*)scene {
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
	[scene draw];
	
	GLenum attachments[] = {GL_DEPTH_ATTACHMENT};
	glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, attachments);
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
	glGenRenderbuffers(1, &depthBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, backingWidth, backingHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);

	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        //NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		switch (glCheckFramebufferStatus(GL_FRAMEBUFFER)) {
			case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				//NSLog(@"Not all framebuffer attachment points are framebuffer attachment complete. This means that at least one attachment point with a renderbuffer or texture attached has its attached object no longer in existence or has an attached image with a width or height of zero, or the color attachment point has a non-color-renderable image attached, or the depth attachment point has a non-depth-renderable image attached, or the stencil attachment point has a non-stencil-renderable image attached.");
				//NSLog(@"Color-renderable formats include GL_RGBA4, GL_RGB5_A1, and GL_RGB565. GL_DEPTH_COMPONENT16 is the only depth-renderable format. GL_STENCIL_INDEX8 is the only stencil-renderable format.");
				break;
			case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
				//NSLog(@"Not all attached images have the same width and height.");
				break;
			case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
				//NSLog(@"No images are attached to the framebuffer.");
				break;
			case GL_FRAMEBUFFER_UNSUPPORTED:
				//NSLog(@"GL_FRAMEBUFFER_UNSUPPORTED.");
				break;
			default:
				break;
		}
		return NO;
    }
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    return YES;
}

- (void)dealloc {
    // Tear down GL
    if (defaultFramebuffer) {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    if (colorRenderbuffer) {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
	if (depthBuffer) {
        glDeleteRenderbuffers(1, &depthBuffer);
        depthBuffer = 0;
	}
	
    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
    [context release];
    context = nil;
	
	[super dealloc];
}

@end
