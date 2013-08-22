//
//  TakePictureView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@interface TakePictureView : NezBaseSceneView {
	
}

@property (nonatomic, retain) IBOutlet UIImageView *cameraView;
@property (nonatomic, retain) IBOutlet UIButton *toggleCameraButton;

@end
