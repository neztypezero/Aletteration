//
//  UIHighScoreItemCell.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-27.
//
//

#import <UIKit/UIKit.h>

@interface UIHighScoreItemCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIImageView *portraitImageView;

@end
