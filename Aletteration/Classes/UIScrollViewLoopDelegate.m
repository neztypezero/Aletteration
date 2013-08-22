//
//  UIScrollViewLoopDelegate.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-26.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "UIScrollViewLoopDelegate.h"

@implementation UIScrollViewLoopDelegate 

@synthesize scrollView;
@synthesize leftCapView;
@synthesize rightCapView;

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
	CGRect frame;
    if (self.scrollView.contentOffset.x == self.leftCapView.frame.origin.x) {
		CGPoint origin = self.rightCapView.frame.origin;
		CGSize size = self.rightCapView.frame.size;
		frame = CGRectMake(origin.x-size.width, origin.y, size.width, size.height);
    } else if (self.scrollView.contentOffset.x == self.rightCapView.frame.origin.x) {
		CGPoint origin = self.leftCapView.frame.origin;
		CGSize size = self.leftCapView.frame.size;
		frame = CGRectMake(origin.x+size.width, origin.y, size.width, size.height);
    }
	[self.scrollView scrollRectToVisible:frame animated:NO];
}

-(void)dealloc {
	self.scrollView = nil;
	self.leftCapView = nil;
	self.rightCapView = nil;
	[super dealloc];
}

@end
