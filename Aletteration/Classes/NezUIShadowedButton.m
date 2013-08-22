//
//  NezUIShadowedButton.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-10-13.
//
//

#import "NezUIShadowedButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezUIShadowedButton

-(void)setupShadows {
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.5f;
	self.layer.shadowRadius = 1.0f;
	self.layer.shadowOffset = CGSizeMake(2, 2);
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		[self setupShadows];
	}
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setupShadows];
    }
    return self;
}
@end
