//
//  AletterationTutorialMakerController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationTutorialMakerController.h"
#import "AletterationTutorialMakerView.h"
#import "AletterationGameState.h"
#import "DisplayLine.h"
#import "LetterBlock.h"
#import "TutorialTextBox.h"
#import "OpenGLES2Graphics.h"
#import "LetterStack.h"

//#define MAKE_FIRST_TIME 1

@implementation AletterationTutorialMakerController

@synthesize infoIndex;
@synthesize actionList;
@synthesize tutorialList;
@synthesize counterButtonList;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		infoIndex = -1;
        self.tutorialList = [NSMutableArray arrayWithCapacity:16];
		editMode = NO;
		moveLetterMode = NO;
		
		self.actionList = [NSArray arrayWithObjects:
						   kTutorialActionNone, kTutorialActionSlideDefault, kTutorialActionSlideWordList, kTutorialActionSlideJunk,
						   kTutorialActionPause, kTutorialActionResume, kTutorialActionScoring,
						   
						   kTutorialActionLine1Sub1,kTutorialActionLine1Sub2,kTutorialActionLine1Sub3,kTutorialActionLine1Sub4,kTutorialActionLine1Sub5,
						   kTutorialActionLine1Sub6,kTutorialActionLine1Sub7,kTutorialActionLine1Sub8,kTutorialActionLine1Sub9,
						   
						   kTutorialActionLine2Sub1,kTutorialActionLine2Sub2,kTutorialActionLine2Sub3,kTutorialActionLine2Sub4,kTutorialActionLine2Sub5,
						   kTutorialActionLine2Sub6,kTutorialActionLine2Sub7,kTutorialActionLine2Sub8,kTutorialActionLine2Sub9,
						   
						   kTutorialActionLine3Sub1,kTutorialActionLine3Sub2,kTutorialActionLine3Sub3,kTutorialActionLine3Sub4,kTutorialActionLine3Sub5,
						   kTutorialActionLine3Sub6,kTutorialActionLine3Sub7,kTutorialActionLine3Sub8,kTutorialActionLine3Sub9,

						   kTutorialActionLine4Sub1,kTutorialActionLine4Sub2,kTutorialActionLine4Sub3,kTutorialActionLine4Sub4,kTutorialActionLine4Sub5,
						   kTutorialActionLine4Sub6,kTutorialActionLine4Sub7,kTutorialActionLine4Sub8,kTutorialActionLine4Sub9,
						   
						   kTutorialActionLine5Sub1,kTutorialActionLine5Sub2,kTutorialActionLine5Sub3,kTutorialActionLine5Sub4,kTutorialActionLine5Sub5,
						   kTutorialActionLine5Sub6,kTutorialActionLine5Sub7,kTutorialActionLine5Sub8,kTutorialActionLine5Sub9,
						   
						   kTutorialActionLine6Sub1,kTutorialActionLine6Sub2,kTutorialActionLine6Sub3,kTutorialActionLine6Sub4,kTutorialActionLine6Sub5,
						   kTutorialActionLine6Sub6,kTutorialActionLine6Sub7,kTutorialActionLine6Sub8,kTutorialActionLine6Sub9,
						   
						   nil];
	}
	return self;
}

-(void)setLabel:(NSString*)label forButton:(UIButton*)b {
	[b setTitle:label forState:UIControlStateNormal];
	[b setTitle:label forState:UIControlStateDisabled];
	[b setTitle:label forState:UIControlStateHighlighted];
	[b setTitle:label forState:UIControlStateSelected];
}

-(void)setViewOffScreen:(UIView*)v {
	CGRect f = v.frame;
	v.frame = CGRectMake(self.view.frame.size.width, f.origin.y, f.size.width, f.size.height);
}

-(void)viewDidLoad {
	[super viewDidLoad];
	UIView *v = self.tutorialMakerView.letterCounterView;
	NSArray *buttonList = v.subviews;
	self.counterButtonList = [buttonList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		UIView *v1 = (UIView*)obj1;
		UIView *v2 = (UIView*)obj2;
		if (v1.tag > v2.tag) {
			return NSOrderedDescending;
		}
		if (v1.tag < v2.tag) {
			return NSOrderedAscending;
		}
		return NSOrderedSame;
	}];
	for (UIButton *b in self.counterButtonList) {
		[self setLabel:[NSString stringWithFormat:@"%d", [gameState getCountForLetterIndex:b.tag]] forButton:b];
		[b.titleLabel setTextAlignment:UITextAlignmentCenter];
	}
	[self setViewOffScreen:self.tutorialMakerView.autoLettersTableView];
	[self setViewOffScreen:self.tutorialMakerView.actionPicker];
	
#ifdef MAKE_FIRST_TIME
	[self addTutorialTextBox];
#else
	[self loadTutorial];
#endif
	[self.tutorialMakerView.autoLettersTableView reloadData];
}

-(void)toggleViewPlace:(UIView*)v {
	CGRect f = v.frame;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 if (v.frame.origin.x == self.view.frame.size.width) {
							 v.frame = CGRectMake(self.view.frame.size.width-f.size.width, f.origin.y, f.size.width, f.size.height);
						 } else {
							 v.frame = CGRectMake(self.view.frame.size.width, f.origin.y, f.size.width, f.size.height);
						 }
					 }
					 completion:^(BOOL completed){
					 }
	 ];
}

-(void)setupAllLines {
	[gameState setupAllLines];
	[gameState setColorsForAllLines];
	for (int i=0; i<LINE_COUNT; i++) {
		DisplayLine *line = gameState.displayLines[i];
		if (line.isWord) {
			[self highlightLine:line];
		}
	}
}

-(IBAction)toggleTableViewMode:(id)sender {
	[self toggleViewPlace:self.tutorialMakerView.autoLettersTableView];
}

-(IBAction)toggleActionPickerViewMode:(id)sender {
	[self toggleViewPlace:self.tutorialMakerView.actionPicker];
}

-(IBAction)toggleTableEditMode:(UIBarButtonItem*)sender {
	editMode = !editMode;
	[super setEditing:editMode animated:YES];
	[self.tutorialMakerView.autoLettersTableView setEditing:editMode animated:YES];
	if (editMode) {
		[sender setTitle:@"Done"];
	} else {
		[sender setTitle:@"Edit"];
	}
}

-(IBAction)startLetterMovement:(UIBarButtonItem*)sender {
	moveLetterMode = YES;
	if ([self.currentTutorialTextBox.autoLetterList count] > 0) {
		moveLetterIndex = 0;
		for (TutorialAutoLetter *tal in self.currentTutorialTextBox.autoLetterList) {
			if (tal.autoDblTapLineIndex == -1) {
				[self setSelectedLetter:tal];
			} else {
				
				[self startRemoveWordAnimation:gameState.displayLines[tal.autoDblTapLineIndex]];
			}
			return;
		}
	}
	moveLetterIndex = 0;
	moveLetterMode = NO;
}

-(IBAction)resetPositions:(id)sender {
	for (TutorialAutoLetter *tal in self.currentTutorialTextBox.autoLetterList) {
		tal.lineIndex = -1;
		tal.autoDblTapLineIndex = -1;
	}
}

-(IBAction)nextAction:(id)sender {
	[self tapButton:self.tutorialMakerView.nextTurnButton];
}

-(IBAction)toggleTextAreaHidden:(id)sender {
	self.tutorialMakerView.instructionBackground.hidden = !self.tutorialMakerView.instructionBackground.hidden;
	self.tutorialMakerView.instructionTextArea.hidden = !self.tutorialMakerView.instructionTextArea.hidden;
	self.tutorialMakerView.dragLeft.hidden = !self.tutorialMakerView.dragLeft.hidden;
	self.tutorialMakerView.dragRight.hidden = !self.tutorialMakerView.dragRight.hidden;
	self.tutorialMakerView.dragUp.hidden = !self.tutorialMakerView.dragUp.hidden;
	self.tutorialMakerView.dragDown.hidden = !self.tutorialMakerView.dragDown.hidden;
	self.tutorialMakerView.nextButton.hidden = !self.tutorialMakerView.nextButton.hidden;
}

-(TutorialTextBox*)getCurrentTutorialTextBox {
	if (self.infoIndex < 0 || self.infoIndex > [self.tutorialList count]-1) {
		return nil;
	}
	return [self.tutorialList objectAtIndex:self.infoIndex];

}

-(void)textViewDidChange:(UITextView *)textView {
	if (self.currentTutorialTextBox != nil) {
		self.currentTutorialTextBox.text = textView.text;
	}
}

-(void)setPickerIndex {
	[self.tutorialMakerView.actionPicker reloadAllComponents];
	if (self.currentTutorialTextBox.actionString == nil) {
		[self.tutorialMakerView.actionPicker selectRow:0 inComponent:0 animated:NO];
	} else {
		int i = 0;
		for (NSString *actionText in self.actionList) {
			if ([self.currentTutorialTextBox.actionString compare:actionText] == NSOrderedSame) {
				[self.tutorialMakerView.actionPicker selectRow:i inComponent:0 animated:NO];
				break;
			}
			i++;
		}
	}
}

-(void)doTutorialAction:(TutorialTextBox*)ttb {
	if (ttb.actionString != nil) {
		if ([ttb.actionString compare:kTutorialActionSlideWordList] == NSOrderedSame) {
			[self slideCameraWordList];
		} else if ([ttb.actionString compare:kTutorialActionSlideDefault] == NSOrderedSame) {
			[self slideCameraDefault];
		} else if ([ttb.actionString compare:kTutorialActionSlideJunk] == NSOrderedSame) {
			[self slideCameraJunk];
		} else if ([ttb.actionString compare:kTutorialActionPause] == NSOrderedSame) {
			[self showPauseMenu:nil];
		} else if ([ttb.actionString compare:kTutorialActionScoring] == NSOrderedSame) {
			[self showScoringDialog:nil];
		} else if ([ttb.actionString compare:kTutorialActionResume] == NSOrderedSame) {
			[self resumeUpInsideAction:nil];
		} else if ([ttb.actionString hasPrefix:kTutorialActionLineX]) {
			unichar lineChar = [ttb.actionString characterAtIndex:7];
			unichar subChar = [ttb.actionString characterAtIndex:12];
			int lineIndex = lineChar-'1';
			int subIndex = subChar-'1';

			DisplayLine *line = gameState.displayLines[lineIndex];
			LetterBlock *lb = [line.letterList objectAtIndex:subIndex];

			[self positionWordOutlineForLine:line TapPoint:CGPointMake(0.0, 0.0) TappedBlock:lb];
		}
	}
}

-(void)addTutorialTextBox {
	[self doTutorialAction:self.currentTutorialTextBox];
	moveLetterMode = NO;
	moveLetterIndex = 0;
	infoIndex++;
	if (infoIndex < [self.tutorialList count]) {
		TutorialTextBox *ttb = self.currentTutorialTextBox;
		for (TutorialAutoLetter *tal in ttb.autoLetterList) {
			UIButton *b = [self.counterButtonList objectAtIndex:tal.letter-'a'];
			int count = [b.titleLabel.text intValue];
			if (count > 0) {
				count--;
				[self setLabel:[NSString stringWithFormat:@"%d", count] forButton:b];
			}
		}
	} else {
		[self.tutorialList addObject:[TutorialTextBox textBoxWithText:@"new text box" AutoLetterList:nil andFrame:CGRectMake(50, 50, 200, 100)]];
	}
	[self setPickerIndex];
}


-(void)insertTutorialTextBox {
	CGRect f = self.currentTutorialTextBox.frame;
	[self doTutorialAction:self.currentTutorialTextBox];
	moveLetterMode = NO;
	moveLetterIndex = 0;
	infoIndex++;
	[self.tutorialList insertObject:[TutorialTextBox textBoxWithText:@"new text box" AutoLetterList:nil andFrame:f] atIndex:infoIndex];
	[self setPickerIndex];
}

-(void)fireButtonEvent:(UIButton*)button {
	[button sendActionsForControlEvents:UIControlEventTouchUpInside];
	button.highlighted = NO;
}

-(void)tapButton:(UIButton*)button {
	button.highlighted = YES;
	[self performSelector:@selector(fireButtonEvent:) withObject:button afterDelay:0.25];
}

-(IBAction)addTutorialTextBox:(id)sender {
	if (sender != nil) {
		if (self.tutorialMakerView.nextTurnButton.hidden == NO && [self.currentTutorialTextBox.autoLetterList count] == 0) {
			[self tapButton:self.tutorialMakerView.nextTurnButton];
		}
		[self addTutorialTextBox];
		[self setInfoLabel:self.currentTutorialTextBox];
		[self.tutorialMakerView.autoLettersTableView reloadData];
	}
}

-(IBAction)insertTutorialTextBox:(id)sender {
	if (sender != nil) {
		if (self.tutorialMakerView.nextTurnButton.hidden == NO && [self.currentTutorialTextBox.autoLetterList count] == 0) {
			[self tapButton:self.tutorialMakerView.nextTurnButton];
		}
		[self insertTutorialTextBox];
		[self setInfoLabel:self.currentTutorialTextBox];
		[self.tutorialMakerView.autoLettersTableView reloadData];
	}
}

-(void)saveTutorial {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString  *tutorialPath = nil;
	if ([paths count] > 0) {
		// Path to save array data
		NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
		tutorialPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj", language]];
		
		NSError *error;
		if (![[NSFileManager defaultManager] fileExistsAtPath:tutorialPath]) {
			if (![[NSFileManager defaultManager] createDirectoryAtPath:tutorialPath withIntermediateDirectories:NO attributes:nil error:&error]) {
				return;
			}
		}
		// Write dictionary
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:self.tutorialList forKey:kTutorialRootObject];
		[archiver finishEncoding];
		[archiver release];
		
		// Here, data holds the serialized version of your dictionary
		NSString *tutorialFile;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			tutorialFile = [tutorialPath stringByAppendingPathComponent:@"Tutorial~ipad.plist"];
		} else {
			tutorialFile = [tutorialPath stringByAppendingPathComponent:@"Tutorial.plist"];
		}
		
		[data writeToFile:tutorialFile atomically:YES];
		[data release];
	}
}

-(void)loadTutorial {
	NSString *textPath = [[NSBundle mainBundle] pathForResource:@"Tutorial" ofType:@"plist"];
	
	NSData *data = [[NSMutableData alloc] initWithContentsOfFile:textPath];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	self.tutorialList = [unarchiver decodeObjectForKey:kTutorialRootObject];
	[unarchiver finishDecoding];
	[unarchiver release];
	[data release];
	
	self.infoIndex = 0;
	
	if ([self.tutorialList count] > 0) {
		TutorialTextBox *ttb = [self.tutorialList objectAtIndex:0];
		for (TutorialAutoLetter *tal in ttb.autoLetterList) {
			UIButton *b = [self.counterButtonList objectAtIndex:tal.letter-'a'];
			int count = [b.titleLabel.text intValue];
			if (count > 0) {
				count--;
				[self setLabel:[NSString stringWithFormat:@"%d", count] forButton:b];
			}
		}
	}
}

-(void)layoutStacksAnimationDidStop {
	[super layoutStacksAnimationDidStop];
	inputMask = IM_DRAG_LETTER | IM_DROP_LINE_ALL | IM_DBLTAP_WORD_ALL;
	[self animateInfoLableWithDuration:0.25 andCompleteSelector:nil afterDelay:0.0];
}

-(void)setInfoLabel:(TutorialTextBox*)ttb {
	AletterationTutorialMakerView *view = (AletterationTutorialMakerView*)self.view;
	
	CGRect f = ttb.frame;
	view.instructionTextArea.frame = f;
	
	CGRect frame = {
		f.origin.x-5,
		f.origin.y,
		f.size.width+10,
		f.size.height,
	};
	view.instructionBackground.frame = frame;
	view.instructionTextArea.text = ttb.text;
	
	view.instructionTextArea.hidden = NO;
	view.instructionBackground.hidden = NO;

	view.dragLeft.hidden = NO;
	view.dragRight.hidden = NO;
	view.dragUp.hidden = NO;
	view.dragDown.hidden = NO;
	
	view.dragLeft.center = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height/2.0);
	view.dragRight.center = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height/2.0);
	view.dragUp.center = CGPointMake(frame.origin.x+frame.size.width/2.0, frame.origin.y);
	view.dragDown.center = CGPointMake(frame.origin.x+frame.size.width/2.0, frame.origin.y+frame.size.height);

	UIImage *nextIcon = view.nextButton.imageView.image;
	
	CGPoint nextCenter = {
		frame.origin.x+frame.size.width-nextIcon.size.width/2,
		frame.origin.y+frame.size.height-nextIcon.size.height/2,
	};
	
	view.nextButton.hidden = NO;
	view.nextButton.center = nextCenter;
}

-(void)animateInfoLableWithDuration:(float)duration andCompleteSelector:(SEL)selector afterDelay:(float)delay {
	if (self.currentTutorialTextBox == nil) {
		return;
	}
	[self setInfoLabel:self.currentTutorialTextBox];

	AletterationTutorialMakerView *view = (AletterationTutorialMakerView*)self.view;
	
	view.instructionTextArea.alpha = 0.0;
	view.instructionBackground.alpha = 0.0;
	view.nextButton.alpha = 0.0;
	view.nextButton.alpha = 0.0;

	view.dragLeft.alpha = 0.0;
	view.dragRight.alpha = 0.0;
	view.dragUp.alpha = 0.0;
	view.dragDown.alpha = 0.0;

	[UIView animateWithDuration:duration
		animations:^ {
			view.instructionTextArea.alpha = 1.0;
			view.instructionBackground.alpha = 1.0;
			view.nextButton.alpha = 1.0;

			view.dragLeft.alpha = 1.0;
			view.dragRight.alpha = 1.0;
			view.dragUp.alpha = 1.0;
			view.dragDown.alpha = 1.0;
		}
		completion:^(BOOL completed) {
			if (selector != nil) {
				[self performSelector:selector withObject:nil afterDelay:delay];
			}
		}
	];
}

-(void)receivedNextBlock {
	[super receivedNextBlock];
}

-(void)animateSelectedBlockToDefaultPositionWithSoundEffect:(NSUInteger)sound andDuration:(float)duration{
	blockAddedTemporarily = NO;
	[super animateSelectedBlockToDefaultPositionWithSoundEffect:sound andDuration:duration];
}

-(void)positionWordOutlineForLine:(DisplayLine*)line TapPoint:(CGPoint)point TappedBlock:(LetterBlock*)tappedBlock {
	[super positionWordOutlineForLine:line TapPoint:point TappedBlock:tappedBlock];
}

-(void)endTurn:(int)lineIndex {
	if (moveLetterMode) {
		TutorialAutoLetter *tal = [self.currentTutorialTextBox.autoLetterList objectAtIndex:moveLetterIndex];
		tal.lineIndex = lineIndex;
		[self.tutorialMakerView.autoLettersTableView reloadData];
	}
	[super endTurn:lineIndex];
}

-(void)doNextTurn {
	if (moveLetterMode) {
		moveLetterIndex++;
		if (moveLetterIndex == [self.currentTutorialTextBox.autoLetterList count]) {
			moveLetterMode = NO;
			self.currentTutorialTextBox.autoNextLastLetter = YES;
		}
	}
	[super doNextTurn];
}

-(void)waitForNextTurn {
	//	[super waitForNextTurn];
	if (moveLetterMode && moveLetterIndex < [self.currentTutorialTextBox.autoLetterList count]) {
		TutorialAutoLetter *tal = [self.currentTutorialTextBox.autoLetterList objectAtIndex:moveLetterIndex];
		if (tal.autoDblTapLineIndex == -1) {
			[self setSelectedLetter:tal];
		} else {
			[self startRemoveWordAnimation:gameState.displayLines[tal.autoDblTapLineIndex]];
		}
	}
	[self enableUserInteraction];
}

-(void)animateRemoveWordDidStopSetup {
	[super animateRemoveWordDidStopSetup];
	TutorialAutoLetter *tal = [self.currentTutorialTextBox.autoLetterList objectAtIndex:moveLetterIndex];
	[self setSelectedLetter:tal];
}

-(BOOL)touch:(UITouch*)touch InView:(UIView*)v {
	CGPoint nextTouch = [touch locationInView:v];
	if (nextTouch.x < 0 || nextTouch.y < 0) {
		return NO;
	}
	if (nextTouch.x > v.frame.size.width || nextTouch.y > v.frame.size.height) {
		return NO;
	}
	return YES;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	AletterationTutorialMakerView *view = (AletterationTutorialMakerView*)self.view;

	UITouch *touch = [touches anyObject];
	
	if ([self touch:touch InView:view.dragLeft]) {
		resizeDragView = view.dragLeft;
	} else if ([self touch:touch InView:view.dragRight]) {
		resizeDragView = view.dragRight;
	} else if ([self touch:touch InView:view.dragUp]) {
		resizeDragView = view.dragUp;
	} else if ([self touch:touch InView:view.dragDown]) {
		resizeDragView = view.dragDown;
	} else if ([self touch:touch InView:view.instructionBackground]) {
		resizeDragView = view.instructionBackground;
		CGPoint nextTouch = [touch locationInView:view];
		dragOffset.x = nextTouch.x-resizeDragView.center.x;
		dragOffset.y = nextTouch.y-resizeDragView.center.y;
	} else {
		[super touchesBegan:touches withEvent:event];
	}
	[self.tutorialMakerView.instructionTextArea resignFirstResponder];
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	AletterationTutorialMakerView *view = (AletterationTutorialMakerView*)self.view;
	UITouch *touch = [touches anyObject];
	CGPoint nextTouch = [touch locationInView:view];
	if (resizeDragView == view.dragLeft || resizeDragView == view.dragRight || resizeDragView == view.dragUp || resizeDragView == view.dragDown) {

		if (resizeDragView == view.dragLeft || resizeDragView == view.dragRight) {
			resizeDragView.center = CGPointMake(nextTouch.x, resizeDragView.center.y);
		} else if (resizeDragView == view.dragUp || resizeDragView == view.dragDown) {
			resizeDragView.center = CGPointMake(resizeDragView.center.x, nextTouch.y);
		}
		if (self.currentTutorialTextBox != nil) {
			self.currentTutorialTextBox.frame = CGRectMake(view.dragLeft.center.x+5, view.dragUp.center.y, view.dragRight.center.x-view.dragLeft.center.x-10, view.dragDown.center.y-view.dragUp.center.y);
			[self setInfoLabel:self.currentTutorialTextBox];
		}
	} else if (resizeDragView == view.instructionBackground) {
		if (self.currentTutorialTextBox != nil) {
			float w = self.currentTutorialTextBox.frame.size.width;
			float h = self.currentTutorialTextBox.frame.size.height;
			self.currentTutorialTextBox.frame = CGRectMake(nextTouch.x-w/2.0-dragOffset.x, nextTouch.y-h/2.0-dragOffset.y, w, h);
			[self setInfoLabel:self.currentTutorialTextBox];
		}
	} else {
		[super touchesMoved:touches withEvent:event];
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	AletterationTutorialMakerView *view = (AletterationTutorialMakerView*)self.view;
	UITouch *touch = [touches anyObject];
	if (resizeDragView == view.instructionBackground) {
		if ([touch tapCount] == 2) {
			if (self.currentTutorialTextBox != nil) {
				CGRect f = self.currentTutorialTextBox.frame;
				float x = view.frame.size.width/2.0-f.size.width/2.0;
				float y = f.origin.y;
				float w = f.size.width;
				float h = f.size.height;
				self.currentTutorialTextBox.frame = CGRectMake(x, y, w, h);
				[self setInfoLabel:self.currentTutorialTextBox];
			}
		}
	} else {
		[super touchesEnded:touches withEvent:event];
	}
	resizeDragView = nil;
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	resizeDragView = nil;
	[super touchesCancelled:touches withEvent:event];
}

-(void)setSelectedLetter:(TutorialAutoLetter*)tal {
	int index = 0;
	for (NSNumber *letterValue in gameState.letterList) {
		char letter = [letterValue charValue];
		if (tal.letter == letter) {
			[gameState setSelectedBlockWithIndex:index];
			if (tal.lineIndex == -1) {
				[super waitForNextTurn];
			} else {
				LetterBlock *lb = gameState.selectedBlock;
				lb.lineIndex = tal.lineIndex;
				lb.animationStopDelegate = self;
				lb.lineIndex = tal.lineIndex;
				DisplayLine *line = gameState.displayLines[lb.lineIndex];
				vec3 pos = [line getNextLetterPos];

				lb.animationStopDelegate = nil;
				lb.animationStopSelector = nil;
				[gameState addCurrentLetterToLine:lb.lineIndex withNoCheck:NO];

				mat4 lineMat = {
					1,0,0,0,
					0,1,0,0,
					0,0,1,0,
					pos.x,pos.y,pos.z,1,
				};
				lb.lineMat = lineMat;
				
				[lb animateMatrix:&lineMat withDuration:0.25 afterDelay:0.0];
				[self endTurn:tal.lineIndex];
			}
			return;
		}
		index++;
	}
}

-(void)insertLetterAtBottom:(char)letter {
	if (self.currentTutorialTextBox != nil) {
		UIButton *b = [self.counterButtonList objectAtIndex:letter-'a'];
		int count = [b.titleLabel.text intValue];
		if (count > 0) {
			[self.currentTutorialTextBox.autoLetterList addObject:[TutorialAutoLetter autoLetter:letter LineIndex:-1 AutoDblTapLineIndex:-1]];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentTutorialTextBox.autoLetterList count]-1 inSection:0];
			UITableView *altv = self.tutorialMakerView.autoLettersTableView;
			[altv beginUpdates];
			[altv insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
			[altv endUpdates];
			[altv scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			
			count--;
			[self setLabel:[NSString stringWithFormat:@"%d", count] forButton:b];
			[altv reloadData];
		}
	}
}

-(IBAction)getLetter:(UIView*)sender {
	char letter = 'a'+sender.tag;
	[self insertLetterAtBottom:letter];
}

-(AletterationTutorialMakerView*)getTMView {
	return (AletterationTutorialMakerView*)self.view;
}

-(BOOL)removeWordFromLine:(int)lineIndex Count:(int)wordCount {
	BOOL ret = [super removeWordFromLine:lineIndex Count:wordCount];
	if (ret && moveLetterMode) {
		TutorialAutoLetter *autoLetter = [self.currentTutorialTextBox.autoLetterList objectAtIndex:moveLetterIndex];
		autoLetter.autoDblTapLineIndex = lineIndex;
		[self.tutorialMakerView.autoLettersTableView reloadData];
	}
	return ret;
}

#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tutorialMakerView.autoLettersTableView) {
		if (self.currentTutorialTextBox != nil) {
			return [self.currentTutorialTextBox.autoLetterList count];
		}
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *autoLetterCellIdentifier = @"UICellAutoLetter";
	
    NSString *cellIdentifier;
    if (tableView == self.tutorialMakerView.autoLettersTableView) {
        cellIdentifier = autoLetterCellIdentifier;
    }
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
    }
	
    if (tableView == self.tutorialMakerView.autoLettersTableView) {
		if (self.currentTutorialTextBox != nil) {
			TutorialAutoLetter *autoLetter = [self.currentTutorialTextBox.autoLetterList objectAtIndex:indexPath.row];
			cell.textLabel.text = [NSString stringWithFormat:@"%c, %d, %d", autoLetter.letter, autoLetter.lineIndex, autoLetter.autoDblTapLineIndex];
		}
    }
	
    return cell;
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	TutorialAutoLetter *tal = [[self.currentTutorialTextBox.autoLetterList objectAtIndex:indexPath.row] retain];
	[self.currentTutorialTextBox.autoLetterList removeObjectAtIndex:indexPath.row];
	
	[tableView beginUpdates];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];

	UIButton *b = [self.counterButtonList objectAtIndex:tal.letter-'a'];
	int count = [b.titleLabel.text intValue]+1;
	[self setLabel:[NSString stringWithFormat:@"%d", count] forButton:b];
	
	[tal release];
}

#pragma mark Row reordering
// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	TutorialAutoLetter *autoLetter = [[self.currentTutorialTextBox.autoLetterList objectAtIndex:fromIndexPath.row] retain];
	[self.currentTutorialTextBox.autoLetterList removeObject:autoLetter];
	[self.currentTutorialTextBox.autoLetterList insertObject:autoLetter atIndex:toIndexPath.row];
	[autoLetter release];
}

#pragma mark UIPickerView methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}

-(NSInteger)pickerView:(UIPickerView*)thePickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.actionList count];
}

-(NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.actionList objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.currentTutorialTextBox.actionString = [self.actionList objectAtIndex:row];
}

-(void)dealloc {
    self.actionList = nil;
    self.tutorialList = nil;
	self.counterButtonList = nil;
	[super dealloc];
}

@end