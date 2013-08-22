//
//  UIPlayerInfoButton.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-24.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AletterationPlayerInfo;

@interface UIPlayerInfoButton : UIButton

+(id)buttonWithPlayerInfo:(AletterationPlayerInfo*)playerInfo andFrame:(CGRect)frame;

@property (nonatomic, retain) AletterationPlayerInfo *playerInfo;

@end
