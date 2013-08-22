//
//  OptionSceneView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-08-21.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "OptionsView.h"
#import "AletterationGameState.h"

@implementation OptionsView

@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;
@synthesize colorBox;
@synthesize soundArea;
@synthesize colorArea;
@synthesize playerArea;
@synthesize musicSlider;
@synthesize musicSwitch;
@synthesize musicVolumeImageView;
@synthesize soundSlider;
@synthesize soundSwitch;
@synthesize soundVolumeImageView;
@synthesize nameTextField;
@synthesize portraitImageView;
@synthesize scrollView;
@synthesize isDrawing;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		self.isDrawing = NO;
	}
    return self;
}

-(void)draw {
	if (self.isDrawing) {
		[[AletterationGameState instance] draw];
	}
}

@end
