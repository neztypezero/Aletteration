//
//  AletterationGameView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-31.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameView.h"
#import "AletterationGameState.h"

@implementation AletterationGameView

-(NSInteger)getAnimationFrameInterval {
	return 2;
}

-(vec3)getInitialEye {
	static vec3 v = {0.0f, 0.0f, 2.0f};
	return v;
}

-(vec3)getInitialTarget {
	static vec3 v = {0.0f, 0.0f, 0.0f};
	return v;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		gameState = [AletterationGameState instance];
	}
    return self;
}

-(void)draw {
	[gameState draw];
}

-(void)hideControls {}

-(void)showControls {}

-(void)dealloc {
	gameState = nil;
    [super dealloc];
}

@end
