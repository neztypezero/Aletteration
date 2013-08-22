//
//  AletterationTutorialView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationTutorialView.h"

@implementation AletterationTutorialView

@synthesize instructionTextArea;
@synthesize instructionBackground;
@synthesize nextButton;

-(void)dealloc {
	self.instructionTextArea = nil;
	self.instructionBackground = nil;
	self.nextButton = nil;
	[super dealloc];
}

@end
