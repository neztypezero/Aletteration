//
//  NezBaseSceneController.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/23/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NezAnimator;

@interface NezBaseSceneController : UIViewController {
	id loadParams;
	CFTimeInterval currentTimeInterval;
}

@property (nonatomic, retain) id loadParams;

-(void)replaceTopViewControllerWithNibName:(NSString*)nibName animated:(BOOL)isAnimated loadParameters:(id)params;
-(void)pushViewControllerWithNibName:(NSString*)viewController animated:(BOOL)isAnimated loadParameters:(id)params;
-(void)popToRootViewControllerAnimated:(BOOL)isAnimate;
-(void)popViewControllerAnimated:(BOOL)isAnimated;
-(void)dismissModalViewController;

-(void)viewDidLayout;
-(void)updateWithCurrentTime:(CFTimeInterval)currentTime andPreviousTime:(CFTimeInterval)lastTime;

@end
