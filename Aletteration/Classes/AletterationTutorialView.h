//
//  AletterationTutorialView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameView.h"

@interface AletterationTutorialView : AletterationSinglePlayerGameView {
	
}

@property (nonatomic, retain) IBOutlet UITextView *instructionTextArea;
@property (nonatomic, retain) IBOutlet UIView *instructionBackground;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

@end
