//
//  UIPlayerInfoButton.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-24.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIPlayerInfoButton.h"
#import "AletterationPlayerInfo.h"

@implementation UIPlayerInfoButton

@synthesize playerInfo;

+(id)buttonWithPlayerInfo:(AletterationPlayerInfo*)playerInfo andFrame:(CGRect)frame {
	UIPlayerInfoButton *playerInfoButton = [[UIPlayerInfoButton alloc] initWithFrame:frame];
	
	playerInfoButton.layer.borderColor = [UIColor blackColor].CGColor;
	playerInfoButton.layer.borderWidth = 1.0;
	playerInfoButton.layer.cornerRadius = 6;
	playerInfoButton.clipsToBounds = YES;
	
	[playerInfoButton setBackgroundImage:playerInfo.portrait forState:UIControlStateNormal];

	playerInfoButton.playerInfo = playerInfo;

	return [playerInfoButton autorelease];
}

-(void)dealloc {
	self.playerInfo = nil;
	[super dealloc];
}

@end
