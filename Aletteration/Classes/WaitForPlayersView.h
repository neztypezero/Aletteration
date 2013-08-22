//
//  WaitForPlayersView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameView.h"

@interface WaitForPlayersView : AletterationGameView

@property (nonatomic, retain) IBOutlet UILabel *waitingLabel;
@property (nonatomic, retain) IBOutlet UIView *waitingView;
@property (nonatomic, retain) IBOutlet UIView *playerView;
@property (nonatomic, retain) IBOutlet UITableView *playerTableView;

-(void)loadRoundCornersAndBorders;

@end
