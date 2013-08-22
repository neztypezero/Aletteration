//
//  MainSelectionController.m
//  Aletteration
//
//  Created by David Nesbitt on 1/20/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainSelectionController.h"
#import "MainSelectionView.h"
#import "AnimatedCamera.h"
#import "OpenGLES2Graphics.h"
#import "AletterationGameState.h"
#import "OptionsController.h"
#import "HighScoreController.h"
#import "QuickRulesController.h"
#import "AletterationPreferences.h"
#import "CreditsController.h"
#import "EditDictionaryViewController.h"

@implementation MainSelectionController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[[self navigationController] setNavigationBarHidden:YES];
	
	buttonForAction = nil;
	
	MainSelectionView *view = (MainSelectionView*)self.view;
    [view setAllButtonAlpha:0];

	vec3 eye = [AletterationGameState getInitialEye];
	vec3 target = [AletterationGameState getInitialTarget];
	vec3 up = [AletterationGameState getInitialUpVector];

	OpenGLES2Graphics *gameGraphics = [OpenGLES2Graphics instance];
	[gameGraphics.camera setEye:eye andTarget:target andUpVector:up];
    [gameGraphics setupMatrices];
	
	[self performSelector:@selector(setViewGameState) withObject:nil afterDelay:0.1]; 
}

-(void)setViewGameState {
	MainSelectionView *view = (MainSelectionView*)self.view;
	[view setGameState];
}

-(void)hideAllSubViews {
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	
	MainSelectionView *view = (MainSelectionView*)self.view;
	
	if (buttonForAction == view.playGameButton || buttonForAction == view.tutorialButton || buttonForAction == view.tutorialMakerButton) {
		[view.titleImageView setAlpha:0];
	}
	[view setAllButtonAlpha:0];

	[UIView commitAnimations];
}

-(void)startLocalGame {
    buttonForAction = nil;
    [self pushViewControllerWithNibName:@"AletterationSinglePlayerGameController" animated:NO loadParameters:nil];
}

-(void)startNetworkGame {
    buttonForAction = nil;
	[self pushViewControllerWithNibName:@"NezNetworkChoiceController" animated:NO loadParameters:nil];
}

-(void)startTutorial {
    buttonForAction = nil;
	[self pushViewControllerWithNibName:@"AletterationTutorialController" animated:NO loadParameters:nil];
}

-(void)startTutorialMaker {
    buttonForAction = nil;
	[self pushViewControllerWithNibName:@"AletterationTutorialMakerController" animated:NO loadParameters:nil];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	MainSelectionView *view = (MainSelectionView*)self.view;

	[[OpenGLES2Graphics instance].camera stopAnimation];
	
	if (buttonForAction == view.playGameButton) {
		[self startLocalGame];
	} else if (buttonForAction == view.playNetworkGameButton) {
		[self startNetworkGame];
	} else if (buttonForAction == view.tutorialButton) {
        [self startTutorial];
	} else if (buttonForAction == view.tutorialMakerButton) {
        [self startTutorialMaker];
	}
}

-(IBAction)doButtonAction:(id)sender {
	if (buttonForAction == nil) {
		buttonForAction = sender;
        [self hideAllSubViews];
	}
}

-(IBAction)showDialogAction:(id)sender {
    buttonForAction = sender;
    [self showDialog];
}

-(void)hideDialog {
    buttonForAction = nil;
}

-(void)showDialog {
	MainSelectionView *view = (MainSelectionView*)self.view;
    if (buttonForAction == view.setOptionsButton) {
        [OptionsController showView:self onCloseSelector:@selector(hideDialog)];
    } else if (buttonForAction == view.highScoresButton) {
        [HighScoreController showView:self onCloseSelector:@selector(hideDialog)];
//    } else if (buttonForAction == view.tutorialButton) {
//        [QuickRulesController showView:self onCloseSelector:@selector(hideDialog) onContinueSelector:@selector(hideAllSubViews)];
    } else if (buttonForAction == view.editDictionaryButton) {
        [EditDictionaryViewController showView:self];
    } else if (buttonForAction == view.creditsButton) {
        [CreditsController showView:self];
	}
}

-(void)viewWillAppear:(BOOL)animated {
	MainSelectionView *view = (MainSelectionView*)self.view;
	
	if ([AletterationGameState instance].stateObject == nil) {
		[view.playGameButton setTitle:@"Play Game" forState:UIControlStateNormal];
	} else {
		[view.playGameButton setTitle:@"Resume" forState:UIControlStateNormal];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	MainSelectionView *view = (MainSelectionView*)self.view;
    [super viewDidAppear:animated];
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
		 animations:^{
			 view.userInteractionEnabled = NO;
             [view setAllButtonAlpha:1];
			 [view.titleImageView setAlpha:1];
		 }
		 completion:^(BOOL completed){
			 view.userInteractionEnabled = YES;
		 }
	];
}

-(void)dealloc {
    [super dealloc];
}

@end
