//
//  AletterationTutorialController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameController.h"

@class TutorialTextBox;
@class TutorialAutoLetter;
@class AletterationTutorialView;

@interface AletterationTutorialController : AletterationSinglePlayerGameController {
	int lettersInFlightCount;
	TutorialAutoLetter *autoDbleTapTal;
}

@property (nonatomic, readonly, getter = getTutorialView) AletterationTutorialView *tutorialView;
@property (nonatomic, readonly, getter = getCurrentTutorialTextBox) TutorialTextBox *currentTutorialTextBox;

@property (nonatomic, retain) NSMutableArray *tutorialList;
@property (nonatomic, assign) int infoIndex;
@property (nonatomic, assign) int letterIndex;

-(IBAction)nextAction:(id)sender;

@end
