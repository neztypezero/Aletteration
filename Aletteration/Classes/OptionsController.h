//
//  OptionSceneController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-08-21.
//  Copyright 2011 David Nesbitt. All rights reserved.
//


#import "NezBaseSceneController.h"

@interface OptionsController : NezBaseSceneController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	AletterationGameState *gameState;
	UITextField *activeField;
	UITapGestureRecognizer *tapToHideKeyboad;
	
	BOOL didNameChange;
	BOOL didPortraitChange;
}

@property(nonatomic, retain) id onCloseDelegate;
@property(nonatomic, assign) SEL onCloseSelector;

@property(nonatomic, retain) UIViewController *parentViewController;

+(void)showView:(UIViewController*)parentViewController onCloseSelector:(SEL)onClose;
-(IBAction)closeDialog:(id)sender;

-(void)registerForKeyboardNotifications;
-(void)unregisterForKeyboardNotifications;

-(IBAction)dismissKeyboard:(id)sender;

-(IBAction)blockColorChanged:(id)sender;

-(IBAction)soundSwitchChanged:(id)sender;
-(IBAction)soundVolumeChanged:(id)sender;

-(IBAction)musicSwitchChanged:(id)sender;
-(IBAction)musicVolumeChanged:(id)sender;

-(IBAction)chooseImage:(id)sender;
-(IBAction)takePhoto:(id)sender;

@end
