//
//  UIScrollViewLoopDelegate.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-26.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollViewLoopDelegate : NSObject <UIScrollViewDelegate> {
	
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *leftCapView;
@property (nonatomic, retain) UIView *rightCapView;

@end
