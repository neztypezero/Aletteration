//
//  NezNetworkChoiceController.m
//  Aletteration
//
//  Created by David Nesbitt on 5/11/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezNetworkChoiceController.h"
#import "NezNetworkChoiceView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezNetworkChoiceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated {
	NezNetworkChoiceView *view = (NezNetworkChoiceView*)self.view;
    [super viewDidAppear:animated];
	if (view.needsLayoutReset) {
		view.needsLayoutReset = NO;
		[UIView animateWithDuration:0.5
			animations:^{
				view.userInteractionEnabled = NO;

				view.bagmanButton.alpha = 1.0;
				view.joinGameButton.alpha = 1.0;
				view.mainMenuButton.alpha = 1.0;
			}
			completion:^(BOOL completed){
				view.userInteractionEnabled = YES;
			}
		];
	}
}


-(IBAction)startNamingBagman:(id)sender {
	[self pushViewControllerWithNibName:@"GameKitBagmanNamingController" animated:YES loadParameters:nil];
//	[self pushViewControllerWithNibName:@"AletterationGKSessionGameController" animated:YES loadParameters:ALETTERATION_GK_SERVER];
}

-(IBAction)startJoiningGame:(id)sender {
	[self pushViewControllerWithNibName:@"GameKitPlayerNamingController" animated:YES loadParameters:nil];
//	[self pushViewControllerWithNibName:@"AletterationGKSessionGameController" animated:YES loadParameters:ALETTERATION_GK_CLIENT];
}

-(IBAction)goToMainMenu:(id)sender {
	NezNetworkChoiceView *view = (NezNetworkChoiceView*)self.view;
	view.needsLayoutReset = YES;
	[UIView animateWithDuration:0.5
		animations:^{
		view.userInteractionEnabled = NO;
		view.bagmanButton.alpha = 0.0;
		view.joinGameButton.alpha = 0.0;
		view.mainMenuButton.alpha = 0.0;
		}
		completion:^(BOOL completed){
			[self popViewControllerAnimated:NO];
		}
	];
}

@end
