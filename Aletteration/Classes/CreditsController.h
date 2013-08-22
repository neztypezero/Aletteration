//
//  CreditsController.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-10-22.
//
//

#import "NezBaseSceneController.h"

@interface CreditsController : NezBaseSceneController {
	BOOL scrollingCredits;
	CGPoint scrolledToPoint;
}

+(void)showView:(UIViewController*)parentViewController;

-(IBAction)closeDialog:(id)sender;
-(IBAction)linkTap:(id)sender;

@end
