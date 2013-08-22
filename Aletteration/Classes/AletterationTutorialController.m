//
//  AletterationTutorialController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationTutorialController.h"
#import "AletterationTutorialView.h"
#import "AletterationGameState.h"
#import "DisplayLine.h"
#import "LetterStack.h"
#import "LetterBlock.h"
#import "TutorialTextBox.h"
#import "OpenGLES2Graphics.h"

@implementation AletterationTutorialController

@synthesize tutorialList;
@synthesize infoIndex;
@synthesize letterIndex;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		autoDbleTapTal = nil;
		NSString *textPath = [[NSBundle mainBundle] pathForResource:@"Tutorial" ofType:@"plist"];
		[self loadTutorial:textPath];
	}
	return self;
}

-(AletterationTutorialView*)getTutorialView {
	return (AletterationTutorialView*)self.view;
}

-(TutorialTextBox*)getCurrentTutorialTextBox {
	if (self.infoIndex < 0 || self.infoIndex > [self.tutorialList count]-1) {
		return nil;
	}
	return [self.tutorialList objectAtIndex:self.infoIndex];
	
}

-(void)loadTutorial:(NSString*)textPath {
	NSData *data = [[NSMutableData alloc] initWithContentsOfFile:textPath];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	self.tutorialList = [unarchiver decodeObjectForKey:kTutorialRootObject];
	[unarchiver finishDecoding];
	[unarchiver release];
	[data release];
	
	self.infoIndex = 0;
	self.letterIndex = 0;
}

-(void)layoutStacksAnimationDidStop {
	[super layoutStacksAnimationDidStop];
	inputMask = IM_NO_INPUT;
}

-(void)setInfoLabel:(TutorialTextBox*)ttb {
	AletterationTutorialView *view = (AletterationTutorialView*)self.view;
	
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
	
	UIImage *nextIcon = view.nextButton.imageView.image;
	
	CGPoint nextCenter = {
		frame.origin.x+frame.size.width-nextIcon.size.width/2,
		frame.origin.y+frame.size.height-nextIcon.size.height/2,
	};
	
	view.nextButton.hidden = NO;
	view.nextButton.center = nextCenter;
}

-(void)animateInfoLableWithDuration:(float)duration Alpha:(float)alpha andCompleteSelector:(SEL)selector afterDelay:(float)delay {
	if (self.currentTutorialTextBox == nil) {
		return;
	}
	[self setInfoLabel:self.currentTutorialTextBox];
	
	AletterationTutorialView *view = (AletterationTutorialView*)self.view;
	
	view.instructionTextArea.alpha = alpha==0.0?1.0:0.0;
	view.instructionBackground.alpha = alpha==0.0?1.0:0.0;
	view.nextButton.alpha = alpha==0.0?1.0:0.0;
	
	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationCurveEaseInOut
		animations:^ {
			view.instructionTextArea.alpha = alpha;
			view.instructionBackground.alpha = alpha;
			view.nextButton.alpha = alpha;
		}
		completion:^(BOOL completed) {
			if (selector != nil) {
				[self performSelector:selector withObject:nil afterDelay:0.0];
			}
		}
	];
}

-(void)setSelectedLetter:(char)selectedLetter {
	int index = 0;
	for (NSNumber *letterValue in gameState.letterList) {
		char letter = [letterValue charValue];
		if (selectedLetter == letter) {
			[gameState setSelectedBlockWithIndex:index];
			break;
		}
		index++;
	}
}

-(void)waitForNextTurn {
	lettersInFlightCount = 0;
	if (self.currentTutorialTextBox != nil) {
		mat4 defaultPosMat = [AletterationGameController getDefaultSelectionMatrix];
		
		TutorialAutoLetter *lastTal = self.currentTutorialTextBox.autoLetterList.lastObject;
		float delay = 0.0;
		float delayIncrement = 0.15;

		for (TutorialAutoLetter *tal in self.currentTutorialTextBox.autoLetterList) {
			if (autoDbleTapTal != nil) {
				if (tal == autoDbleTapTal) {
					tal.autoDblTapLineIndex = -1;
					autoDbleTapTal = nil;
				} else {
					continue;
				}
			} else {
				[self setSelectedLetter:tal.letter];
			}
			LetterBlock *lb = gameState.selectedBlock;
			lb.lineIndex = tal.lineIndex;
			lb.animationStopDelegate = self;
			lb.lineIndex = tal.lineIndex;
			DisplayLine *line = gameState.displayLines[lb.lineIndex];
			
			vec3 pos = [line getNextLetterPos];
			mat4 mat;
			mat4 lineMat = {
				1,0,0,0,
				0,1,0,0,
				0,0,1,0,
				pos.x,pos.y,pos.z,1,
			};

			if (tal.autoDblTapLineIndex != -1) {
				autoDbleTapTal = tal;
				break;
			}
			
			if (tal == lastTal && self.currentTutorialTextBox.autoNextLastLetter == NO) {
				mat = defaultPosMat;
				lb.animationStopSelector = @selector(autoLetterDidStopUpOnlyFinal:);
			} else {
				mat = lineMat;
				if (tal == lastTal) {
					lb.animationStopSelector = @selector(autoLetterDidStopFinalLast:);
				} else {
					lb.animationStopSelector = @selector(autoLetterDidStopFinal:);
				}
				[gameState addCurrentLetterToLine:lb.lineIndex withNoCheck:YES];
				[gameState.localPlayerInfo addLetterToLine:lb.lineIndex forTurn:gameState.currentTurn];
				[gameState setNextTurn];
			}
			lb.lineMat = lineMat;
			lettersInFlightCount++;
			[lb animateMatrix:&mat withDuration:0.25 afterDelay:delay];
			
			delay += delayIncrement;
		}
	}
	[self doAutoDblTap];
//	[super waitForNextTurn];
}

-(void)quitGame {
	NSString *title = @"Quit Tutorial";
	NSString *message = @"Thank you for doing this tutorial. Have fun playing Aletteration!";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Quit", nil];
	[alert show];
	[alert release];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *text = [alertView buttonTitleAtIndex:buttonIndex];
	if ([text compare:@"Quit"] == NSOrderedSame) {
		[self animateInfoLableWithDuration:0.5 Alpha:0.0 andCompleteSelector:nil afterDelay:0.0];
		[super alertView:alertView clickedButtonAtIndex:buttonIndex];
	}
}

-(void)doTutorialAction {
	autoDbleTapTal = nil;
	BOOL needsNextTurn = YES;
	if ([self.currentTutorialTextBox.autoLetterList count] > 0 && self.currentTutorialTextBox.autoNextLastLetter == NO) {
		[self animateLastSelectedBlock];
	} else if (self.tutorialView.nextTurnButton.hidden == NO) {
		[self tapButton:self.tutorialView.nextTurnButton afterDelay:0.5];
		needsNextTurn = NO;
	}
	[self animateInfoLableWithDuration:0.5 Alpha:0.0 andCompleteSelector:nil afterDelay:0.0];
	self.infoIndex++;
	if (self.currentTutorialTextBox == nil) {
		[self quitGame];
		return;
	}
	if ([self.currentTutorialTextBox.autoLetterList count] == 0) {
		[self animateInfoLableWithDuration:0.5 Alpha:1.0 andCompleteSelector:nil afterDelay:0.0];
	} else if (needsNextTurn) {
		[self waitForNextTurn];
	}
}
/*
 #define kTutorialActionSlideDefault @"TA_SLIDE_DEFAULT"
 #define kTutorialActionSlideWordList @"TA_SLIDE_WORD_LIST"
 #define kTutorialActionSlideJunk @"TA_SLIDE_JUNK"
 */
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
	[self doTutorialAction];
}

-(IBAction)nextAction:(id)sender {
	[self doTutorialAction:self.currentTutorialTextBox];
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

-(void)animateRemoveWordDidStopSetup {
	[super animateRemoveWordDidStopSetup];
	[self waitForNextTurn];
}

-(void)doAutoDblTap {
	if (autoDbleTapTal != nil && lettersInFlightCount == 0) {
		if (autoDbleTapTal.autoDblTapLineIndex != -1) {
			DisplayLine *line = gameState.displayLines[autoDbleTapTal.autoDblTapLineIndex];
			if (line.highlightedLetterCount == 0) {
				[self setupAllLines];
			}
			[self startRemoveWordAnimation:gameState.displayLines[autoDbleTapTal.autoDblTapLineIndex]];
		}
	}
}

-(void)autoLetterDidStop:(LetterBlock*)lb {
	lettersInFlightCount--;
    lb.animationStopDelegate = nil;
    lb.animationStopSelector = nil;
	[[gameState getStackForLetter:lb.letter] updateCounter];
}

-(void)autoLetterDidStopFinalLast:(LetterBlock*)lb {
	[self autoLetterDidStop:lb];
	[self setupAllLines];
	[self animateInfoLableWithDuration:0.5 Alpha:1.0 andCompleteSelector:nil afterDelay:0.0];
}

-(void)autoLetterDidStopFinal:(LetterBlock*)lb {
	[self autoLetterDidStop:lb];
	[self doAutoDblTap];
}

-(void)autoLetterDidStopUpOnlyFinal:(LetterBlock*)lb {
	[self autoLetterDidStop:lb];
	[self animateInfoLableWithDuration:0.5 Alpha:1.0 andCompleteSelector:nil afterDelay:0.0];
}

-(void)animateLastSelectedBlock {
	LetterBlock *lb = gameState.selectedBlock;
    mat4 mat = lb.lineMat;
    lb.animationStopDelegate = self;
    lb.animationStopSelector = @selector(lastAutoLetterDidStopFinal:);
    [lb animateMatrix:&mat withDuration:0.5];
	[gameState addCurrentLetterToLine:lb.lineIndex withNoCheck:NO];
}

-(void)lastAutoLetterDidStopFinal:(LetterBlock*)lb {
    lb.animationStopDelegate = nil;
    lb.animationStopSelector = nil;
	[self endTurn:lb.lineIndex];
}

-(void)doNextTurnEvent:(UIButton*)button {
//	[button sendActionsForControlEvents:UIControlEventTouchUpInside];
	[self doNextTurn];
	button.highlighted = NO;
}

-(void)tapButton:(UIButton*)button afterDelay:(float)delay {
	button.highlighted = YES;
	[self performSelector:@selector(doNextTurnEvent:) withObject:button afterDelay:delay];
}

-(void)dealloc {
	[super dealloc];
}

@end