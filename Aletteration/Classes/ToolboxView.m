//
//  ToolboxView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-09-27.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "ToolboxView.h"

@implementation ToolboxView

@synthesize exitButton;
@synthesize optionsButton;
@synthesize resumeButton;
@synthesize scoringButton;
@synthesize quickRulesButton;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

-(void)dealloc {
	self.exitButton = nil;
	self.optionsButton = nil;
	self.resumeButton = nil;
	self.scoringButton = nil;
	self.quickRulesButton = nil;
	[super dealloc];
}

@end
