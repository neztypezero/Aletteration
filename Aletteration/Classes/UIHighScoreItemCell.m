//
//  UIHighScoreItemCell.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-27.
//
//

#import "UIHighScoreItemCell.h"

@implementation UIHighScoreItemCell

@synthesize nameLabel;
@synthesize dateLabel;
@synthesize scoreLabel;
@synthesize portraitImageView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		//NSLog(@"UICompletedWordTableViewCell:initWithCoder");
	}
	return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)dealloc {
    self.nameLabel = nil;
    self.dateLabel = nil;
    self.portraitImageView = nil;
    [super dealloc];
}

@end
