//
//  AletterationPlayerInfoView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-07-08.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameView.h"

@class AletterationPlayerInfo;
@class AletterationPlayerInfoTableViewDelegate;

@interface AletterationPlayerInfoView : AletterationGameView {
    UIImageView *portraitImageView;
    UILabel *nameLabel;
    UILabel *wordsLabel;
    UILabel *scoreLabel;
	UIView *wordsAreaView;
	UITableView *wordsTableView;
	AletterationPlayerInfo *playerInfo;
	AletterationPlayerInfoTableViewDelegate *wordsTableViewDelegate;
}

@property (nonatomic, retain, setter = setPlayerInfo:) AletterationPlayerInfo *playerInfo;

@property (nonatomic, retain) IBOutlet UIImageView *portraitImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *wordsLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIView *wordsAreaView;
@property (nonatomic, retain) IBOutlet UITableView *wordsTableView;

@end
