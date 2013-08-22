//
//  GameKitPlayerNamingView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "GameKitPlayerNamingView.h"
#import "AletterationGameState.h"

@implementation GameKitPlayerNamingView

@synthesize areaView;

@synthesize serverScrollView;
@synthesize serversTableView;
@synthesize serverPortraitImageView;
@synthesize serverDisconnectButton;
@synthesize playersScrollView;
@synthesize playerNameField;
@synthesize exitButton;
@synthesize portraitImageView;
@synthesize playersLabel;
@synthesize serversLabel;
@synthesize waitingLabel;
@synthesize waitingBall;
@synthesize connectingBall;
@synthesize playerPortraitsDic;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		gameState = [AletterationGameState instance];
		self.playerPortraitsDic = [NSMutableDictionary dictionaryWithCapacity:8];
	}
    return self;
}

-(void)draw {
	[gameState draw];
}

-(void)resetUIElements {
	self.waitingLabel.hidden = YES;
	self.waitingLabel.alpha = 0.0;
	self.waitingBall.hidden = YES;
	self.waitingBall.alpha = 0.0;
	[self.waitingBall stopAnimating];
	
	self.playersLabel.hidden = NO;
	self.playersLabel.alpha = 1.0;
	
	self.serversLabel.hidden = NO;
	self.serversLabel.alpha = 1.0;
	
	self.serversTableView.userInteractionEnabled = YES;
	
	[self removeAllPlayerPortraits];

	[self.serversTableView reloadData];
}

-(CGSize)getPortraitSize {
	float h = self.playersScrollView.frame.size.height-8.0;
	CGSize size = { h*1.5, h };
	return size;
}

-(CGRect)getPortraitFrameWithIndex:(int)index {
	CGSize portraitSize = [self getPortraitSize];
	CGRect frame = {
		4.0+(2.0+portraitSize.width)*index, 4.0, portraitSize.width, portraitSize.height
	};
	return frame;
}

-(void)updatePlayerPortrait:(AletterationPlayerInfo*)playerInfo {
	CGSize portraitSize = [self getPortraitSize];
	
	int count = [self.playerPortraitsDic count];
	UIImageView *portraitView = [self.playerPortraitsDic objectForKey:playerInfo.ip];
	if (portraitView == nil) {
		portraitView = [[UIImageView alloc] initWithFrame:[self getPortraitFrameWithIndex:count]];
		
		portraitView.layer.borderColor = [UIColor blackColor].CGColor;
		portraitView.layer.borderWidth = 2.0;
		portraitView.layer.cornerRadius = 8;
		portraitView.clipsToBounds = YES;
		portraitView.alpha = 0.0;
		portraitView.contentMode = UIViewContentModeScaleAspectFit;
		
		portraitView.image = playerInfo.portrait;
		[self.playersScrollView addSubview:portraitView];
		[self.playerPortraitsDic setObject:portraitView forKey:playerInfo.ip];
		
		[UIView animateWithDuration:0.5
			animations:^{
				portraitView.alpha = 1.0;
			}
			completion:^(BOOL completed) {
			}
		];
		
		[portraitView release];
		
		CGSize contentSize = {
			portraitView.frame.origin.x+(2.0+portraitSize.width),
			self.playersScrollView.frame.size.height
		};
		self.playersScrollView.contentSize = contentSize;
	} else {
		if (playerInfo.portrait != nil) portraitView.image = playerInfo.portrait;
	}
}

-(void)removePlayerPortrait:(NSString*)peerID {
	UIImageView *portraitView = [self.playerPortraitsDic objectForKey:peerID];
	if (portraitView != nil) {
		CGRect frame = portraitView.frame;
		[portraitView removeFromSuperview];
		[self.playerPortraitsDic removeObjectForKey:peerID];

		CGSize portraitSize = [self getPortraitSize];
		for (UIImageView *view in self.playerPortraitsDic.allValues) {
			//NSLog(@"%f, %f", view.frame.origin.x, frame.origin.x);
			if (view.frame.origin.x > frame.origin.x) {
				CGRect f = view.frame;
				f.origin.x -= (2.0+portraitSize.width);
				view.frame = f;
			}
		}
	}
}

-(void)removeAllPlayerPortraits {
	for (UIView *view in [playersScrollView subviews]) {
		[view removeFromSuperview];
	}
	self.playersScrollView.contentSize = CGSizeMake(0, 0);
	[self.playerPortraitsDic removeAllObjects];
}

-(void)dealloc {
	//NSLog(@"dealloc:GameKitPlayerNamingView");
	self.serverScrollView = nil;
	self.serversTableView = nil;
	self.serverPortraitImageView = nil;
	self.serverDisconnectButton = nil;
	self.playersScrollView = nil;
	self.playerNameField = nil;
	self.exitButton = nil;
	self.playersLabel = nil;
	self.serversLabel = nil;
	self.waitingLabel = nil;
	self.waitingBall = nil;
	self.playerPortraitsDic = nil;
	[super dealloc];
}

@end
