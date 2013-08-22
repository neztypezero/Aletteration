//
//  GameKitBagmanNamingView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@class AletterationGameState;

@interface GameKitBagmanNamingView : NezBaseSceneView {
	AletterationGameState *gameState;
}

@property (nonatomic, retain) IBOutlet UIView *areaView;
@property (nonatomic, retain) IBOutlet UITableView *playersTableView;
@property (nonatomic, retain) IBOutlet UITextField *playerNameField;
@property (nonatomic, retain) IBOutlet UIButton *startGameButton;
@property (nonatomic, retain) IBOutlet UIImageView *portraitImageView;
@property (nonatomic, retain) IBOutlet UIView *gameInfoView;
@property (nonatomic, retain) IBOutlet UILabel *gameInfoLabel;

@end
