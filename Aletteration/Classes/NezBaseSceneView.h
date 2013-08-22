//
//  NezBaseSceneView.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <UIKit/UIKit.h>
#import "NezCamera.h"
#import "Structures.h"

@class EAGLView;

#define NEZ_FRAMES_PER_SECOND 30

@interface NezBaseSceneView : UIView {
	double time;
	
	BOOL firstLayout;

	int touchesDown;
	
	BOOL needsLayoutReset;
@public
	double framesPerSecond;
}
@property (nonatomic, readonly, getter=getAnimationFrameInterval) NSInteger animationFrameInterval;
@property (nonatomic, readonly, getter=getGLView) EAGLView *glView;

@property (nonatomic, assign) BOOL needsLayoutReset;

-(vec3)getInitialEye;
-(vec3)getInitialTarget;

-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments;
-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments;
-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed;
-(void)draw;

-(void)resetViewElements;

@end
