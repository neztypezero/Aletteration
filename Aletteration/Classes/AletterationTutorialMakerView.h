//
//  AletterationTutorialMakerView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameView.h"
#import "NezUIRoundRectView.h"

@interface AletterationTutorialMakerView : AletterationSinglePlayerGameView {
	
}

@property (nonatomic, retain) IBOutlet UITextView *instructionTextArea;
@property (nonatomic, retain) IBOutlet UIView *instructionBackground;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UITextField *textbox;
@property (nonatomic, retain) IBOutlet UITableView *autoLettersTableView;

@property (nonatomic, retain) IBOutlet UIView *letterCounterView;

@property (nonatomic, retain) IBOutlet NezUIRoundRectView *dragLeft;
@property (nonatomic, retain) IBOutlet NezUIRoundRectView *dragRight;
@property (nonatomic, retain) IBOutlet NezUIRoundRectView *dragUp;
@property (nonatomic, retain) IBOutlet NezUIRoundRectView *dragDown;

@property (nonatomic, retain) IBOutlet UIPickerView *actionPicker;

@end
