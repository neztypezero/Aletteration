//
//  AletterationTutorialMakerView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationTutorialMakerView.h"

@implementation AletterationTutorialMakerView

@synthesize instructionTextArea;
@synthesize instructionBackground;
@synthesize nextButton;
@synthesize saveButton;
@synthesize infoLabel;
@synthesize textbox;
@synthesize autoLettersTableView;
@synthesize letterCounterView;
@synthesize actionPicker;

@synthesize dragLeft;
@synthesize dragRight;
@synthesize dragUp;
@synthesize dragDown;

-(void)dealloc {
	self.instructionTextArea = nil;
	self.instructionBackground = nil;
	self.nextButton = nil;
	self.saveButton = nil;
	self.infoLabel = nil;
	self.textbox = nil;
	self.autoLettersTableView = nil;

	self.letterCounterView = nil;
	self.actionPicker = nil;

	self.dragLeft = nil;
	self.dragRight = nil;
	self.dragUp = nil;
	self.dragDown = nil;

	[super dealloc];
}

@end
