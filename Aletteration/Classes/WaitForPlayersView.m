//
//  WaitForPlayersView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WaitForPlayersView.h"

@implementation WaitForPlayersView

@synthesize waitingLabel;
@synthesize waitingView;
@synthesize playerView;
@synthesize playerTableView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
	}
    return self;
}

-(void)loadRoundCornersAndBorders {
	NSArray *roundedCornerViewArray = [NSArray arrayWithObjects:self.waitingView, self.playerView, nil];
	
	for (UIView *rView in roundedCornerViewArray) {
		rView.layer.borderColor = [UIColor blackColor].CGColor;
		rView.layer.borderWidth = 2.0;
		rView.layer.cornerRadius = 9;
	}
	self.playerView.clipsToBounds = YES;
	self.playerTableView.clipsToBounds = YES;
}

-(void)dealloc {
	self.waitingLabel = nil;
	self.waitingView = nil;
	self.playerView = nil;
	self.playerTableView = nil;
	[super dealloc];
}

@end
