//
//  TakePictureController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TakePictureController.h"
#import "AletterationGameState.h"
#import "TakePictureView.h"

UIImage* flip(CGImageRef im) {
	CGSize sz = CGSizeMake(CGImageGetWidth(im), CGImageGetHeight(im));
	UIGraphicsBeginImageContext(sz);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(0, 0, sz.width, sz.height), im);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}

@implementation TakePictureController

@synthesize didTakePhotoDelegate;
@synthesize didTakePhotoSelector;

+(void)showModal:(UIViewController*)parentViewController delegate:(id)del selector:(SEL)sel {
	NSString *nibName = @"TakePictureController";
	TakePictureController *controller = [[TakePictureController alloc] initWithNibName:nibName bundle:nil];
	controller.didTakePhotoDelegate = del;
	controller.didTakePhotoSelector = sel;
	[parentViewController presentModalViewController:controller animated:YES];
	[controller release];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		gameState = [AletterationGameState instance];
		captureManager = nil;
    }
    return self;
}

-(void)viewDidLoad {
	TakePictureView *view = (TakePictureView*)self.view;
	view.cameraView.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
	if (captureManager == nil) {
		[self performSelector:@selector(startCapturing) withObject:nil afterDelay:0.1];
	}
}

-(void)startCapturing {
	TakePictureView *view = (TakePictureView*)self.view;
	
	captureManager = [[CaptureSessionManager alloc] initWithCaptureDelegate:self];
	
	BOOL hasFront = [captureManager hasFrontCamera];
	BOOL hasBack = [captureManager hasBackCamera];
	
	if (hasBack && !hasFront) {
		view.toggleCameraButton.hidden = YES;
		currentCameraPosition = AVCaptureDevicePositionBack;
		view.cameraView.hidden = NO;
	} else {
		currentCameraPosition = AVCaptureDevicePositionFront;
		view.cameraView.hidden = NO;
	}
	[captureManager addVideoInputWithPosition:currentCameraPosition];
	[captureManager setPreview:view.cameraView];
	[captureManager.captureSession startRunning];
}

-(UIImage*)cropImage:(UIImage*)image {
	CGFloat w = image.size.width;
	CGFloat h = (int)(w/1.5);
	CGFloat y = (int)((image.size.height-h)/2.0);
	
	if (currentCameraPosition == AVCaptureDevicePositionFront) {
		image = flip([image CGImage]);
	}
	
	CGRect cropRect = CGRectMake(0, y, w, h);
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
	image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return image;
}

-(void)toggleCameraPosition {
//	TakePictureView *view = (TakePictureView*)self.view;

//	UIImageView *viewToShow = view.cameraView;
	if (currentCameraPosition == AVCaptureDevicePositionBack) {
		currentCameraPosition = AVCaptureDevicePositionFront;
	} else {
		currentCameraPosition = AVCaptureDevicePositionBack;
	}
	[captureManager addVideoInputWithPosition:currentCameraPosition];

//	CGFloat duration = 0.7;
/*	
	[UIView beginAnimations:@"ToggleCameraAimation" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view.frontPreView cache:NO]; 
	[UIView commitAnimations];
	
	[UIView beginAnimations:@"ToggleCameraAimation" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view.backPreView cache:NO]; 
	[UIView commitAnimations];
	*/
//	[self performSelector:@selector(toggleImageViews:) withObject:viewToShow afterDelay:duration/2.0];
}
/*
-(void)toggleImageViews:(UIImageView*)viewToShow {
	TakePictureView *view = (TakePictureView*)self.view;
	if (viewToShow == view.backPreView) {
		view.backPreView.hidden = NO;
		view.frontPreView.hidden = YES;
	} else {
		view.backPreView.hidden = YES;
		view.frontPreView.hidden = NO;
	}
}
*/
-(void)imageCaptured:(UIImage*)image {
	[captureManager.captureSession stopRunning];
	
	TakePictureView *view = (TakePictureView*)self.view;
	
	gameState.localPlayerInfo.portrait = [self cropImage:image];
	view.cameraView.image = gameState.localPlayerInfo.portrait;
//	view.frontPreView.image = gameState.localPlayerInfo.portrait;
	
	if (self.didTakePhotoDelegate != nil && self.didTakePhotoSelector != nil) {
		[self.didTakePhotoDelegate performSelector:self.didTakePhotoSelector withObject:gameState.localPlayerInfo.portrait];
	}
	[self dismissModalViewController];
}
/*
-(void)frameCaptured:(UIImage*)image {
	if (skipFrames > 0) {
		skipFrames--;
		return;
	}
	
	TakePictureView *view = (TakePictureView*)self.view;
	if (currentCameraPosition == AVCaptureDevicePositionBack) {
		view.backPreView.image = image;
	} else {
		view.frontPreView.image = flip([image CGImage]);
	}
}
*/
-(IBAction)cancelDialogAction:(id)sender {
	[self dismissModalViewController];
}

-(IBAction)toggleCameraAction:(id)sender {
	[self toggleCameraPosition];
}

-(IBAction)capturePortrait:(id)sender {
	[captureManager captureStillImage];
}

-(void)dealloc {
	[captureManager release];
	[super dealloc];
}

@end
