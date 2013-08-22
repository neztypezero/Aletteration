//
//  AletterationAppDelegate.h
//  Aletteration
//
//  Created by David Nesbitt on 1/19/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface AletterationAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

-(void)viewDidLayout;
-(void)setAnimationFrameInterval:(NSInteger)frameInterval;

@end

