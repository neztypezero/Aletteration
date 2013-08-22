//
//  TakePictureController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneController.h"
#import "CaptureSessionManager.h"

@class AletterationGameState;

@interface TakePictureController : NezBaseSceneController<ImageCapturedDelegate> {
    CaptureSessionManager *captureManager;
	AletterationGameState *gameState;
	AVCaptureDevicePosition currentCameraPosition;
}

@property (nonatomic, retain) id didTakePhotoDelegate;
@property (nonatomic, assign) SEL didTakePhotoSelector;

+(void)showModal:(UIViewController*)parentViewController delegate:(id)del selector:(SEL)sel;

-(IBAction)cancelDialogAction:(id)sender;
-(IBAction)capturePortrait:(id)captureButton;
-(IBAction)toggleCameraAction:(id)toggleButton;

-(void)startCapturing;

@end
