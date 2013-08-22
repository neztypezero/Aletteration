//
//  AletterationSinglePlayerGameView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameView.h"

@implementation AletterationSinglePlayerGameView

@synthesize nextTurnButton;
@synthesize pauseMenuButton;

-(void)dealloc {
	self.nextTurnButton = nil;
	self.pauseMenuButton = nil;
	[super dealloc];
}

@end
