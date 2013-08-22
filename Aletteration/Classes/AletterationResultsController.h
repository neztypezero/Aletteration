//
//  AletterationResultsController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-09-16.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneController.h"

@interface AletterationResultsController : NezBaseSceneController {
	UITapGestureRecognizer *aletterationLinkTapRecognizer;
	NSMutableDictionary *playerPortraitsDic;
	AletterationGameState *gameState;
	int longestWordLengthInGame;
	int longestWordBonus;
}

+(void)showModal:(UIViewController*)parentViewController withCloseDelegate:(id)delegate andCloseSelector:(SEL)selector;

@property (nonatomic, retain) NSArray *wordList;
@property (nonatomic, retain) NSArray *longWordsList;

@property(nonatomic, retain) id closeDialogDelegate;
@property(nonatomic, assign) SEL closeDialogSelector;

-(IBAction)exitDialog:(id)sender;

@end
