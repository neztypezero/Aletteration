//
//  GameKitPlayerNamingView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@class AletterationGameState;
@class AletterationPlayerInfo;

@interface GameKitPlayerNamingView : NezBaseSceneView {
	AletterationGameState *gameState;
}

@property (nonatomic, retain) NSMutableDictionary *playerPortraitsDic;

@property (nonatomic, retain) IBOutlet UIView *areaView;

@property (nonatomic, retain) IBOutlet UIScrollView *serverScrollView;
@property (nonatomic, retain) IBOutlet UITableView *serversTableView;
@property (nonatomic, retain) IBOutlet UIImageView *serverPortraitImageView;
@property (nonatomic, retain) IBOutlet UIButton *serverDisconnectButton;

@property (nonatomic, retain) IBOutlet UIScrollView *playersScrollView;
@property (nonatomic, retain) IBOutlet UITextField *playerNameField;

@property (nonatomic, retain) IBOutlet UIButton *exitButton;

@property (nonatomic, retain) IBOutlet UIImageView *portraitImageView;

@property (nonatomic, retain) IBOutlet UILabel *playersLabel;
@property (nonatomic, retain) IBOutlet UILabel *serversLabel;
@property (nonatomic, retain) IBOutlet UILabel *waitingLabel;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitingBall;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *connectingBall;

-(void)resetUIElements;
-(void)removeAllPlayerPortraits;
-(void)removePlayerPortrait:(NSString*)peerID;
-(void)updatePlayerPortrait:(AletterationPlayerInfo*)playerInfo;

@end
