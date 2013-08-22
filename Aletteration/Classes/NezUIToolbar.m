//
//  NezUIToolbar.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/24/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "NezUIToolbar.h"


@implementation NezUIToolbar


- (id)initWithCoder:(NSCoder*)coder {    
    if ((self = [super initWithCoder:coder])) {
		[self setBarStyle:UIBarStyleBlackOpaque];
		[self setBackgroundColor:[UIColor clearColor]];
	}
    return self;
}

- (id) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame:frame])) {
		[self setBarStyle:UIBarStyleBlackOpaque];
		[self setBackgroundColor:[UIColor clearColor]];
	}
    return self;
}

- (void) drawRect: (CGRect) rect {}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
