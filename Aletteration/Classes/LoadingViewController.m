//
//  RootViewController.m
//  Aletteration
//
//  Created by David Nesbitt on 1/19/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "LoadingViewController.h"
#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "AnimatedCamera.h"
#import "MainSelectionController.h"
#import "MainSelectionView.h"

@implementation LoadingViewController


#pragma mark -
#pragma mark View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];

	LoadingView *view = (LoadingView*)self.view;
	view.logoImageView.hidden = NO;
	view.logoImageView.alpha = 0.0;
	view.titleImageView.hidden = YES;
	view.titleImageView.alpha = 0.0;
	view.progressView.hidden = YES;
	view.progressView.alpha = 0.0;
	
	[UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
		animations:^{
			view.logoImageView.alpha = 1.0;

			AletterationGameState *gameState = [AletterationGameState instance];
			
			[gameState loadSounds];
			[gameState playSound:gameState.sounds->intro];
		}
		completion:^(BOOL completed) {
			[UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut
				animations:^{
					view.logoImageView.alpha = 0.0;
				}
				completion:^(BOOL completed) {
					AletterationGameState *gameState = [AletterationGameState instance];
					[gameState loadMusic];

					view.logoImageView.hidden = YES;
					view.titleImageView.hidden = NO;
					view.progressView.hidden = NO;
					[UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
						animations:^{
							view.titleImageView.alpha = 1.0;
							view.progressView.alpha = 1.0;
						}
						completion:^(BOOL completed) {
							NezAnimation *progressAni = [[[NezAnimation alloc] initFloatWithFromData:0 ToData:1 Duration:6.5 EasingFunction:&easeLinear CallbackObject:self UpdateSelector:@selector(progressAnimation:) DidStopSelector:@selector(progressAnimationDidStop:)] autorelease];
							[[NezAnimator instance] addAnimation:progressAni];
						}
					];
				}
			];
		}
	];
}

-(void)progressAnimation:(NezAnimation*)animation {
	LoadingView *view = (LoadingView*)self.view;
	view.progressView.progress = animation->newData[0];
	if (view.isSceneLoaded && animation->newData[0] < 0.9) {
		[[NezAnimator instance] removeAnimation:animation];
		NezAnimation *progressAni = [[[NezAnimation alloc] initFloatWithFromData:animation->newData[0] ToData:1 Duration:0.5 EasingFunction:&easeLinear CallbackObject:self UpdateSelector:@selector(progressAnimation2:) DidStopSelector:@selector(progressAnimationDidStop:)] autorelease];
		[[NezAnimator instance] addAnimation:progressAni];
	}
}

-(void)progressAnimation2:(NezAnimation*)animation {
	LoadingView *view = (LoadingView*)self.view;
	view.progressView.progress = animation->newData[0];
}

-(void)progressAnimationDidStop:(NezAnimation*)animation {
	NSString *nibName = @"MainSelectionController";
	MainSelectionController *controller = [[MainSelectionController alloc] initWithNibName:nibName bundle:nil];
	MainSelectionView *msView = (MainSelectionView*)controller.view;
	CGRect frame = msView.titleImageView.frame;
	[controller release];
	[UIView animateWithDuration:0.5
		animations:^{
			LoadingView *view = (LoadingView*)self.view;
			view.titleImageView.frame = frame;
			view.progressView.alpha = 0.0;
			view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
		}
		completion:^(BOOL completed) {
			[self replaceTopViewControllerWithNibName:nibName animated:NO loadParameters:nil];
		}
	];
}

-(void)dealloc {
	//NSLog(@"dealloc:RootViewController");
    [super dealloc];
}


@end

