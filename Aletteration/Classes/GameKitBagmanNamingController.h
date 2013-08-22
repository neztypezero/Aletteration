//
//  GameKitBagmanNamingController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGKSessionController.h"

@interface GameKitBagmanNamingController : AletterationGKSessionController {
	UITapGestureRecognizer *tapToHideKeyboad;
}

-(IBAction)chooseImage:(id)sender;
-(IBAction)takePhoto:(id)sender;
-(IBAction)dismissKeyboard:(id)textField;
-(IBAction)cancelGame:(id)cancelButton;
-(IBAction)startGame:(id)startButton;

@end
