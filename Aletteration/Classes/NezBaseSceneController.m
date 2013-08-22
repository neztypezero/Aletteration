    //
//  NezBaseSceneController.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/23/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneController.h"
#import "NezBaseSceneView.h"
#import "AletterationAppDelegate.h"
#import "NezBaseSceneView.h"
#import "EAGLView.h"
#import "NezAnimator.h"
#import <objc/runtime.h>

@implementation NezBaseSceneController

@synthesize loadParams;

-(EAGLView*)getGLView {
	AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	return delegate.glView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)replaceTopViewControllerWithNibName:(NSString*)nibName animated:(BOOL)isAnimated loadParameters:(id)params {
	NSMutableArray *controllerArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
	NezBaseSceneController *controller = [[NSClassFromString(nibName) alloc] initWithNibName:nibName bundle:nil];
	controller.loadParams = params;
	[controllerArray replaceObjectAtIndex:[controllerArray count]-1 withObject:controller];
	[self.navigationController setViewControllers:controllerArray animated:isAnimated];
}

-(void)pushViewControllerWithNibName:(NSString*)nibName animated:(BOOL)isAnimated loadParameters:(id)params {
	NezBaseSceneController *controller = [[NSClassFromString(nibName) alloc] initWithNibName:nibName bundle:nil];
	controller.loadParams = params;
	[self.navigationController pushViewController:controller animated:isAnimated];
	[controller release];
}

-(void)popToRootViewControllerAnimated:(BOOL)isAnimated {
	[self.navigationController popToRootViewControllerAnimated:isAnimated];
}

-(void)popViewControllerAnimated:(BOOL)isAnimated {
	[self.navigationController popViewControllerAnimated:isAnimated];
}

-(void)dismissModalViewController {
	if (self.parentViewController != nil) {
		[self.parentViewController dismissModalViewControllerAnimated:YES];
	} else if ([self respondsToSelector:@selector(presentingViewController)]) {
		[self.presentingViewController dismissModalViewControllerAnimated:YES];
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[[self navigationController] setNavigationBarHidden:YES];
}

- (void)viewDidLayout {
	AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NezBaseSceneView *view = (NezBaseSceneView*)self.view;
	[view loadSceneWithContext:delegate.glView.context andArguments:loadParams];
	self.loadParams = nil;
}

-(void)viewWillAppear:(BOOL)animated {
	NezBaseSceneView *view = (NezBaseSceneView*)self.view;
	[view resetViewElements];
	AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.glView.animationFrameInterval = view.animationFrameInterval;
	[super viewWillAppear:animated];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)updateWithCurrentTime:(CFTimeInterval)currentTime andPreviousTime:(CFTimeInterval)lastTime {
	currentTimeInterval = currentTime;
	[[NezAnimator instance] updateWithCurrentTime:currentTime];
	NezBaseSceneView *view = (NezBaseSceneView*)self.view;
	[view updateWithTimeElapsed:currentTime-lastTime];
}

-(void)dealloc {
	//NSLog(@"dealloc:NezBaseSceneController");
	[super dealloc];
}

@end
