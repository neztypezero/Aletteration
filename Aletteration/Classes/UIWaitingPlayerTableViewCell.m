//
//  UIWaitingPlayerTableViewCell.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-05.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIWaitingPlayerTableViewCell.h"

@implementation UIWaitingPlayerTableViewCell

@synthesize portraitImageView;
@synthesize nameLabel;
@synthesize checkLabel;
@synthesize waitingIndicatorView;
@synthesize isWaiting;
@synthesize shouldDisplayCheckmark;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		shouldDisplayCheckmark = YES;
	}
	return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		shouldDisplayCheckmark = YES;
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setPortraitImageView:(UIImageView*)imageView {
	if (portraitImageView != imageView) {
		[portraitImageView release];
		portraitImageView = [imageView retain];
		portraitImageView.layer.borderColor = [UIColor blackColor].CGColor;
		portraitImageView.layer.borderWidth = 2.0;
		portraitImageView.layer.cornerRadius = 6;
		portraitImageView.clipsToBounds = YES;
	}
}

-(void)setIsWaiting:(BOOL)waitingFlag {
	isWaiting = waitingFlag;
	if (isWaiting) {
		[self.waitingIndicatorView startAnimating];
		self.checkLabel.hidden = YES;
	} else {
		[self.waitingIndicatorView stopAnimating];
		self.checkLabel.hidden = !shouldDisplayCheckmark;
	}
}

@end
