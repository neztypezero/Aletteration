//
//  MainSelectionView.m
//  Aletteration
//
//  Created by David Nesbitt on 1/20/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "MainSelectionView.h"
#import "GLSLProgramManager.h"
#import "TextureManager.h"
#import "AletterationGameState.h"

@implementation MainSelectionView

@synthesize titleImageView;
@synthesize playGameButton;
@synthesize playNetworkGameButton;
@synthesize setOptionsButton;
@synthesize tutorialButton;
@synthesize tutorialMakerButton;
@synthesize creditsButton;
@synthesize highScoresButton;
@synthesize editDictionaryButton;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        gameState = nil;
	}
    return self;
}

-(void)draw {
	[gameState draw];
}


-(void)setGameState {
	gameState = [AletterationGameState instance];
}

-(void)setAllButtonAlpha:(float)alpha {
    [playGameButton setAlpha:alpha];
	[playNetworkGameButton setAlpha:alpha];
	[setOptionsButton setAlpha:alpha];
	[tutorialButton setAlpha:alpha];
	[tutorialMakerButton setAlpha:alpha];
	[creditsButton setAlpha:alpha];
	[highScoresButton setAlpha:alpha];
	[editDictionaryButton setAlpha:alpha];
}

-(void)dealloc {
	//NSLog(@"dealloc:MainSelectionView");
	self.titleImageView = nil;
	self.playGameButton = nil;
	self.playNetworkGameButton = nil;
	self.setOptionsButton = nil;
	self.tutorialButton = nil;
	self.tutorialMakerButton = nil;
	self.creditsButton = nil;
	self.highScoresButton = nil;
	self.editDictionaryButton = nil;
	[super dealloc];
}


@end
