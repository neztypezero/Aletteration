//
//  GameKitPlayerNamingController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGKSessionController.h"

@interface GameKitPlayerNamingController : AletterationGKSessionController {
	UITapGestureRecognizer *tapToHideKeyboad;
	BOOL isConnectedToGameServer;
	BOOL isShowingServerPortrait;
}

-(IBAction)chooseImage:(id)sender;
-(IBAction)takePhoto:(id)sender;
-(IBAction)dismissKeyboard:(UITextField*)textField;
-(IBAction)goBack:(UIButton*)button;
-(IBAction)disconnectFromServer:(id)sender;

-(void)removeAllPlayerPortraits;

@end
