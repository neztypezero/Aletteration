//
//  MainSelectionView.h
//  Aletteration
//
//  Created by David Nesbitt on 1/20/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NezBaseSceneView.h"

@class AletterationGameState;

@interface MainSelectionView : NezBaseSceneView {
	AletterationGameState *gameState;
}

@property (nonatomic, retain) IBOutlet UIImageView *titleImageView;
@property (nonatomic, retain) IBOutlet UIButton *playGameButton;
@property (nonatomic, retain) IBOutlet UIButton *playNetworkGameButton;
@property (nonatomic, retain) IBOutlet UIButton *setOptionsButton;
@property (nonatomic, retain) IBOutlet UIButton *tutorialButton;
@property (nonatomic, retain) IBOutlet UIButton *tutorialMakerButton;
@property (nonatomic, retain) IBOutlet UIButton *creditsButton;
@property (nonatomic, retain) IBOutlet UIButton *highScoresButton;
@property (nonatomic, retain) IBOutlet UIButton *editDictionaryButton;

-(void)setGameState;
-(void)setAllButtonAlpha:(float)alpha;

@end
