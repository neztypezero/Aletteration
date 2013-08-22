//
//  AletterationPlayerInfoView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-07-08.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationPlayerInfoView.h"
#import "AletterationPlayerInfo.h"
#import "AletterationPlayerInfoTableViewDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation AletterationPlayerInfoView

@synthesize playerInfo;
@synthesize portraitImageView;
@synthesize nameLabel;
@synthesize wordsLabel;
@synthesize scoreLabel;
@synthesize wordsAreaView;
@synthesize wordsTableView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		wordsTableViewDelegate = nil;
    }
    return self;
}

-(void)setPlayerInfo:(AletterationPlayerInfo*)pInfo {
	if (playerInfo != nil) {
		[playerInfo release];
	}
	if (pInfo != nil) {
		playerInfo = [pInfo retain];

	    self.portraitImageView.image = playerInfo.portrait;
		self.nameLabel.text = playerInfo.name;
		self.scoreLabel.text = [NSString stringWithFormat:@"%d", playerInfo.score];
		self.wordsLabel.text = [NSString stringWithFormat:@"%d", playerInfo.completedWordCount];
	} else {
		playerInfo = nil;
	}
	if (wordsTableViewDelegate == nil && self.wordsTableView != nil) {
		wordsTableViewDelegate = [[AletterationPlayerInfoTableViewDelegate alloc] init];
		wordsTableViewDelegate.wordsTableView = wordsTableView;
		self.wordsTableView.delegate = wordsTableViewDelegate;
		self.wordsTableView.dataSource = wordsTableViewDelegate;
	}
	wordsTableViewDelegate.playerInfo = pInfo;
}

-(void)dealloc {
	self.portraitImageView = nil;
	self.nameLabel = nil;
	self.wordsLabel = nil;
	self.scoreLabel = nil;
	self.playerInfo = nil;
	self.wordsAreaView = nil;
	self.wordsTableView = nil;
	if (wordsTableViewDelegate != nil) {
		[wordsTableViewDelegate release];
	}
	[super dealloc];
}

@end
