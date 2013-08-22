//
//  AletterationPlayerInfoTableViewDelegate.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-29.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AletterationPlayerInfo;

@interface AletterationPlayerInfoTableViewDelegate : NSObject<UITableViewDelegate,UITableViewDataSource> {
	AletterationPlayerInfo *playerInfo;
}

@property (nonatomic, retain, setter = setPlayerInfo:) AletterationPlayerInfo *playerInfo;
@property (nonatomic, retain) UITableView *wordsTableView;

@end
