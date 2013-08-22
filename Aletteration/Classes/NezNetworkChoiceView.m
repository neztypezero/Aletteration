//
//  NezNetworkChoiceView.m
//  Aletteration
//
//  Created by David Nesbitt on 5/11/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezNetworkChoiceView.h"
#import "AletterationGameState.h"

@implementation NezNetworkChoiceView

@synthesize titleImageView;
@synthesize bagmanButton;
@synthesize joinGameButton;
@synthesize mainMenuButton;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		gameState = [AletterationGameState instance];
	}
    return self;
}

-(void)draw {
	[gameState draw];
}

-(void)resetViewElements {
	if (needsLayoutReset) {
		[titleImageView setAlpha:1.0];
		[bagmanButton setAlpha:0.0];
		[joinGameButton setAlpha:0.0];
		[mainMenuButton setAlpha:0.0];
	}
}

-(void)dealloc {
	//NSLog(@"dealloc:NezNetworkChoiceView");
	self.titleImageView = nil;
	self.bagmanButton = nil;
	self.joinGameButton = nil;
	self.mainMenuButton = nil;
	[super dealloc];
}

@end
