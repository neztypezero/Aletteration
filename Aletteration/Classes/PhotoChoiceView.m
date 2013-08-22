//
//  PhotoChoiceView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "PhotoChoiceView.h"

@implementation PhotoChoiceView

@synthesize mainImageView;
@synthesize thumbnailScrollView;
@synthesize navigationBar;
@synthesize albumNavigationItem;
@synthesize photoNavigationItem;
@synthesize editNavigationItem;
@synthesize editOutlineView;

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)draw {
}

-(void)dealloc {
	//NSLog(@"dealloc:PhotoChoiceView");
	self.mainImageView = nil;
	self.thumbnailScrollView = nil;
	self.navigationBar = nil;
	self.albumNavigationItem = nil;
	self.photoNavigationItem = nil;
	self.editNavigationItem = nil;
	self.editOutlineView = nil;
	[super dealloc];
}

@end
