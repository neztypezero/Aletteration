//
//  NezUILabel.m
//  Aletteration
//
//  Created by David Nesbitt on 4/15/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezUILabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezUILabel

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.layer.borderWidth = 3.0;
		self.layer.cornerRadius = 16;
	}
    return self;
}

@end
