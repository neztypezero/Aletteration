//
//  AletterationTutorialMakerController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameController.h"

@class TutorialTextBox;
@class AletterationTutorialMakerView;
@class LetterStack;

@interface AletterationTutorialMakerController : AletterationSinglePlayerGameController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
	UIView *resizeDragView;
	CGPoint dragOffset;
	BOOL editMode;
	BOOL moveLetterMode;
	int moveLetterIndex;
}

@property (nonatomic, retain) NSArray *actionList;
@property (nonatomic, retain) NSArray *counterButtonList;
@property (nonatomic, retain) NSMutableArray *tutorialList;
@property (nonatomic, assign) int infoIndex;
@property (nonatomic, readonly, getter = getTMView) AletterationTutorialMakerView *tutorialMakerView;
@property (nonatomic, readonly, getter = getCurrentTutorialTextBox) TutorialTextBox *currentTutorialTextBox;

-(void)setInfoLabel:(TutorialTextBox*)ttb;

-(IBAction)toggleTableViewMode:(id)sender;
-(IBAction)toggleActionPickerViewMode:(id)sender;
-(IBAction)toggleTableEditMode:(id)sender;

-(IBAction)startLetterMovement:(UIBarButtonItem*)sender;

-(IBAction)getLetter:(UIView*)sender;

-(IBAction)addTutorialTextBox:(id)sender;
-(IBAction)insertTutorialTextBox:(id)sender;

-(IBAction)saveTutorial;
-(void)loadTutorial;

-(IBAction)resetPositions:(id)sender;
-(IBAction)nextAction:(id)sender;

@end
