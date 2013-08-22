//
//  OptionSceneView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-08-21.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@interface OptionsView : NezBaseSceneView {
	UISlider *redSlider;
	UISlider *greenSlider;
	UISlider *blueSlider;
	UIImageView *colorBox;
	UIView *soundArea;
	UIView *colorArea;
	UIView *playerArea;

	UISwitch *musicSwitch;
	UISlider *musicSlider;
	UIImageView *musicVolumeImageView;

	UISwitch *soundSwitch;
	UISlider *soundSlider;
	UIImageView *soundVolumeImageView;
	
	UITextField *nameTextField;
	UIImageView *portraitImageView;

	UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UISlider *redSlider;
@property (nonatomic, retain) IBOutlet UISlider *greenSlider;
@property (nonatomic, retain) IBOutlet UISlider *blueSlider;
@property (nonatomic, retain) IBOutlet UIImageView *colorBox;
@property (nonatomic, retain) IBOutlet UIView *soundArea;
@property (nonatomic, retain) IBOutlet UIView *colorArea;
@property (nonatomic, retain) IBOutlet UIView *playerArea;
@property (nonatomic, retain) IBOutlet UISwitch *musicSwitch;
@property (nonatomic, retain) IBOutlet UISlider *musicSlider;
@property (nonatomic, retain) IBOutlet UIImageView *musicVolumeImageView;
@property (nonatomic, retain) IBOutlet UISwitch *soundSwitch;
@property (nonatomic, retain) IBOutlet UISlider *soundSlider;
@property (nonatomic, retain) IBOutlet UIImageView *soundVolumeImageView;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UIImageView *portraitImageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isDrawing;

@end
