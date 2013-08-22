//
//  GameKitBagmanNamingView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "GameKitBagmanNamingView.h"
#import "AletterationGameState.h"

@implementation GameKitBagmanNamingView

@synthesize areaView;
@synthesize playersTableView;
@synthesize playerNameField;
@synthesize startGameButton;
@synthesize portraitImageView;
@synthesize gameInfoView;
@synthesize gameInfoLabel;

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
	self.startGameButton.enabled = NO;
}

-(void)dealloc {
	//NSLog(@"dealloc:GameKitBagmanNamingView");
	self.areaView = nil;
	self.playersTableView = nil;
	self.playerNameField = nil;
	self.startGameButton = nil;
	self.portraitImageView = nil;
	self.gameInfoView = nil;
	self.gameInfoLabel = nil;
	[super dealloc];
}

@end
