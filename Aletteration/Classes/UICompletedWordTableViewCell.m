//
//  UICompletedWordCell.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-19.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "UICompletedWordTableViewCell.h"

@implementation UICompletedWordTableViewCell

@synthesize wordLabel;
@synthesize bonusLabel;
@synthesize bonusLengthImageView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		//NSLog(@"UICompletedWordTableViewCell:initWithCoder");
	}
	return self;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		//NSLog(@"UICompletedWordTableViewCell:initWithStyle");
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
