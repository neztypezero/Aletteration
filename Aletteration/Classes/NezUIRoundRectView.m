//
//  NezUIRoundRectView.m
//  Aletteration
//
//  Created by David Nesbitt on 12-03-30.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezUIRoundRectView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezUIRoundRectView

-(void)setupRoundBorders {
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 2.0;
	self.layer.cornerRadius = 13;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		[self setupRoundBorders];
	}
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setupRoundBorders];
    }
    return self;
}

@end
