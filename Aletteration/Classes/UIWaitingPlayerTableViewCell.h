//
//  UIWaitingPlayerTableViewCell.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-05.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWaitingPlayerTableViewCell : UITableViewCell {
	UIImageView *portraitImageView;
	BOOL isWaiting;
}

@property (nonatomic, retain, setter = setPortraitImageView:) IBOutlet UIImageView *portraitImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *checkLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitingIndicatorView;

@property (nonatomic, assign) BOOL shouldDisplayCheckmark;
@property (nonatomic, assign, setter=setIsWaiting:) BOOL isWaiting;

@end
