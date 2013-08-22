//
//  AletterationResultsView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-09-16.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@class AletterationGameState;

@interface AletterationResultsView : NezBaseSceneView {
	AletterationGameState *gameState;
}

@property (nonatomic, retain) IBOutlet UIView *backgroundArea;
@property (nonatomic, retain) IBOutlet UIView *portraitArea;
@property (nonatomic, retain) IBOutlet UIImageView *portraitImageView;
@property (nonatomic, retain) IBOutlet UILabel *playerNameLabel;
@property (nonatomic, retain) IBOutlet UIView *wordListArea;
@property (nonatomic, retain) IBOutlet UITableView *wordListTableView;

@property (nonatomic, retain) IBOutlet UIImageView *jArea;
@property (nonatomic, retain) IBOutlet UIImageView *jUsed;
@property (nonatomic, retain) IBOutlet UIImageView *qArea;
@property (nonatomic, retain) IBOutlet UIImageView *qUsed;
@property (nonatomic, retain) IBOutlet UIImageView *xArea;
@property (nonatomic, retain) IBOutlet UIImageView *xUsed;
@property (nonatomic, retain) IBOutlet UIImageView *zArea;
@property (nonatomic, retain) IBOutlet UIImageView *zUsed;

@property (nonatomic, retain) IBOutlet UILabel *aletterationDescLabel;
@property (nonatomic, retain) IBOutlet UILabel *aletterationLinkLabel;

@property (nonatomic, retain) IBOutlet UIView *aletterationLinkBackground;

@end
