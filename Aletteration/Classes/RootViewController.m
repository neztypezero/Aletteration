//
//  RootViewController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-08.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

-(void)viewDidAppear:(BOOL)animated {
	[self replaceTopViewControllerWithNibName:@"LoadingViewController" animated:NO loadParameters:nil];
}

@end
