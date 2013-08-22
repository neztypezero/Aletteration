//
//  GameKitPlayerView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameKitPlayerView.h"
#import "WaitForPlayersView.h"

@implementation AletterationGameKitPlayerView

@synthesize waitingForPlayersView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WaitForPlayersView" owner:self options:nil];
		self.waitingForPlayersView = (WaitForPlayersView*)[nib objectAtIndex:0];
		self.waitingForPlayersView.hidden = YES;
		[self addSubview:self.waitingForPlayersView];
	}
    return self;
}

-(void)dealloc {
	self.waitingForPlayersView = nil;
	[super dealloc];
}

@end
