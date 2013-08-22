//
//  NezBaseSceneView.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"
#import "AletterationAppDelegate.h"
#import "matrix.h"

@implementation NezBaseSceneView

@synthesize needsLayoutReset;

-(NSInteger)getAnimationFrameInterval {
	return 1;
}

-(EAGLView*)getGLView {
	AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	return delegate.glView;
}

-(vec3)getInitialEye {
	static vec3 v = {0,0,0};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0,0,0};
	return v;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		framesPerSecond = NEZ_FRAMES_PER_SECOND;
		
		time = 0;
		firstLayout = YES;
    	touchesDown = 0;
		
		needsLayoutReset = YES;
	}
    return self;
}

-(void)draw {}

-(void)layoutSubviews {
	if (firstLayout) {
		AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate viewDidLayout];
		firstLayout = NO;
	}
	[super layoutSubviews];
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {}
-(void)setContext:(EAGLContext*)context WithArguments:(id)arguments {}
-(void)loadSceneWithContext:(EAGLContext*)context andArguments:(id)arguments {}
-(void)resetViewElements {}

- (void)dealloc {
    [super dealloc];
}


@end
