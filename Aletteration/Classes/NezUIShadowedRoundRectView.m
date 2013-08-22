//
//  NezUIRoundRectView.m
//  Aletteration
//
//  Created by David Nesbitt on 12-03-30.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezUIShadowedRoundRectView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezUIShadowedRoundRectView

-(void)setupRoundBorders {
    [[self layer] setCornerRadius:15];
    [[self layer] setMasksToBounds:NO];
    [[self layer] setShadowColor:[UIColor blackColor].CGColor];
    [[self layer] setShadowOpacity:1.0f];
    [[self layer] setShadowRadius:10.0f];
    [[self layer] setShadowOffset:CGSizeMake(5, 5)];
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
