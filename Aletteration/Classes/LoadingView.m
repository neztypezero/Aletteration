//
//  RootView.m
//  Aletteration
//
//  Created by David Nesbitt on 1/19/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "LoadingView.h"
#import "GLSLProgramManager.h"
#import "OpenGLES2Graphics.h"
#import "AletterationGameState.h"
#import "TextureManager.h"
#import "AnimatedCamera.h"

@implementation LoadingView

@synthesize isSceneLoaded;
@synthesize progressView;
@synthesize titleImageView;
@synthesize logoImageView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		isSceneLoaded = NO;
		isSceneLoading = NO;
		gameState = nil;
	}
    return self;
}

-(vec3)getInitialEye {
	return [AletterationGameState getDefaultEye];
}

-(vec3)getInitialTarget {
	return [AletterationGameState getDefaultTarget];
}

-(vec3)getInitialUpVector {
	return [AletterationGameState getDefaultUpVector];
}

-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments {
	if (isSceneLoading == NO) {
		isSceneLoading = YES;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			[EAGLContext setCurrentContext:context];
			
			gameState = [AletterationGameState instance];
			
			vec3 eye = [self getInitialEye];
			vec3 target = [self getInitialTarget];
			vec3 up = [self getInitialUpVector];
			vec3 leye = {1.4f, -0.8f, 3.0f};
			vec3 ltarget = {0.0f, 0.0f, 0.0f};
			[OpenGLES2Graphics initializeWithContext:context CamPos:eye CamTarget:target UpVector:up LightPos:leye LightTarget:ltarget];
			[gameState loadData];
			
			color4f bgColor = {0.94f, 0.36f, 0.32f, 1.0f};
			[[OpenGLES2Graphics instance] setClearColor:bgColor];

			eye = [AletterationGameState getInitialEye];
			target = [AletterationGameState getInitialTarget];
			up = [AletterationGameState getInitialUpVector];
			
			OpenGLES2Graphics *gameGraphics = [OpenGLES2Graphics instance];
			[gameGraphics.camera setEye:eye andTarget:target andUpVector:up];
			[gameGraphics setupMatrices];
			
			[pool release];
			
			isSceneLoaded = YES;
		});
	}
}

-(void)draw {
	if (isSceneLoaded) {
		[gameState draw];
	}
}


- (void)dealloc {
	self.titleImageView = nil;
	self.progressView = nil;
	self.logoImageView = nil;
    [super dealloc];
}

@end
