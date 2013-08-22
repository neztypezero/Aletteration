//
//  QuickRulesController.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-30.
//
//

#import "NezBaseSceneController.h"

@interface QuickRulesController : NezBaseSceneController

@property(nonatomic, retain) id onCloseDelegate;
@property(nonatomic, assign) SEL onCloseSelector;
@property(nonatomic, assign) SEL onContinueSelector;

+(void)showView:(UIViewController*)parentViewController onCloseSelector:(SEL)onClose onContinueSelector:(SEL)onContinue;

-(IBAction)closeDialog:(id)sender;

@end
