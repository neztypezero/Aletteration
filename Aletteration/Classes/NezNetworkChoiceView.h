//
//  NezNetworkChoiceView.h
//  Aletteration
//
//  Created by David Nesbitt on 5/11/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@class AletterationGameState;

@interface NezNetworkChoiceView : NezBaseSceneView {
   	UIImageView *titleImageView;
	UIButton *bagmanButton;
	UIButton *joinGameButton;
	UIButton *mainMenuButton;
	
	AletterationGameState *gameState;
}

@property (nonatomic, retain) IBOutlet UIImageView *titleImageView;
@property (nonatomic, retain) IBOutlet UIButton *bagmanButton;
@property (nonatomic, retain) IBOutlet UIButton *joinGameButton;
@property (nonatomic, retain) IBOutlet UIButton *mainMenuButton;

@end
