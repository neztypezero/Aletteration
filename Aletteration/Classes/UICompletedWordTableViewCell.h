//
//  UICompletedWordCell.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-19.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICompletedWordTableViewCell : UITableViewCell {
	
}

@property (nonatomic, retain) IBOutlet UILabel *wordLabel;
@property (nonatomic, retain) IBOutlet UILabel *bonusLabel;
@property (nonatomic, retain) IBOutlet UIImageView *bonusLengthImageView;

@end
