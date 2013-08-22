//
//  AletterationResultsView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-09-16.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationResultsView.h"
#import "AletterationGameState.h"
#import "UICALayerLabel.h"

@implementation AletterationResultsView

-(NSInteger)getAnimationFrameInterval {
	return 2;
}

-(id)init {
    self = [super init];
    if (self) {
		gameState = [AletterationGameState instance];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		gameState = [AletterationGameState instance];
	}

	return self;
}

-(void)draw {
	[gameState draw];
}

-(void)dealloc {
	self.backgroundArea = nil;
	self.portraitArea = nil;
	self.portraitImageView = nil;
	self.playerNameLabel = nil;
	self.wordListArea = nil;
	self.wordListTableView = nil;
	self.jArea = nil;
	self.jUsed = nil;
	self.qArea = nil;
	self.qUsed = nil;
	self.xArea = nil;
	self.xUsed = nil;
	self.zArea = nil;
	self.zUsed = nil;
	self.aletterationDescLabel = nil;
	self.aletterationLinkLabel = nil;
	self.aletterationLinkBackground = nil;

	[super dealloc];
}

@end
