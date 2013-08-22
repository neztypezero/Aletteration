//
//  MainSelectionController.h
//  Aletteration
//
//  Created by David Nesbitt on 1/20/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NezBaseSceneController.h"

@interface MainSelectionController : NezBaseSceneController {
	UIButton *buttonForAction;
}

-(void)showDialog;

-(IBAction)doButtonAction:(id)sender;
-(IBAction)showDialogAction:(id)sender;

@end
