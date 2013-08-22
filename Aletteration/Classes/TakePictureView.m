//
//  TakePictureView.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "TakePictureView.h"

@implementation TakePictureView

@synthesize cameraView;
@synthesize toggleCameraButton;

-(void)dealloc {
	//NSLog(@"dealloc:TakePictureView");
	self.cameraView = nil;
	self.toggleCameraButton = nil;
	[super dealloc];
}

@end
