//
//  AletterationAppDelegate.m
//  Aletteration
//
//  Created by David Nesbitt on 1/19/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationAppDelegate.h"
#import "AletterationGameState.h"
#import "RootViewController.h"
#import "NezBaseSceneController.h"
#import "EAGLView.h"


@implementation AletterationAppDelegate

@synthesize window;
@synthesize glView;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    [glView startAnimation];

    return YES;
}

-(void)setAnimationFrameInterval:(NSInteger)frameInterval {
	[glView setAnimationFrameInterval:frameInterval];
}

-(void)viewDidLayout {
	UIViewController *visibleController = navigationController.visibleViewController;
	if ([visibleController isKindOfClass:[NezBaseSceneController class]]) {
		NezBaseSceneController *controller = (NezBaseSceneController*)visibleController;
		[controller viewDidLayout];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[AletterationGameState instance] saveState];
    [glView stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [glView stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [glView startAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [glView stopAnimation];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[glView release];
	[window release];

    self.window = nil;
    self.glView = nil;
	self.navigationController = nil;

	[super dealloc];
}


@end

