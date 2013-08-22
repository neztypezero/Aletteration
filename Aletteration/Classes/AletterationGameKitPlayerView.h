//
//  GameKitPlayerView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameView.h"

@class WaitForPlayersView;

@interface AletterationGameKitPlayerView : AletterationSinglePlayerGameView

@property (nonatomic, retain) WaitForPlayersView *waitingForPlayersView;

@end
