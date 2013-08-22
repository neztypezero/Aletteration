//
//  OptionSceneController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-08-21.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AletterationGameState.h"
#import "OptionsController.h"
#import "OptionsView.h"
#import "PhotoChoiceController.h"
#import "TakePictureController.h"
#import "AletterationPreferences.h"

@implementation OptionsController

@synthesize onCloseDelegate;
@synthesize onCloseSelector;

+(void)showView:(UIViewController*)parentViewController onCloseSelector:(SEL)onCloseSelector {
    NSString *nibName = @"OptionsController";
    OptionsController *controller = [[OptionsController alloc] initWithNibName:nibName bundle:nil];

    CGSize size = controller.view.frame.size;
    CGRect r = CGRectMake(0, size.height, size.width, size.height);
    controller.view.frame = r;

    [parentViewController.view addSubview:controller.view];

    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            controller.view.frame = CGRectMake(0, 0, size.width, size.height);
        }
        completion:^(BOOL completed) {
			controller.parentViewController = parentViewController;
            controller.onCloseDelegate = parentViewController;
            controller.onCloseSelector = onCloseSelector;
        }
    ];
}

-(void)closeDialog:(id)sender {
    CGSize size = self.view.frame.size;
    	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
    	animations:^{
    		self.view.frame = CGRectMake(0, size.height, size.width, size.height);
    	}
    	completion:^(BOOL completed) {
            OptionsView *view = (OptionsView*)self.view;
            AletterationPlayerInfo *pInfo = gameState.localPlayerInfo;
            
            pInfo.name = view.nameTextField.text;
            pInfo.portrait = view.portraitImageView.image;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setObject:pInfo.name forKey:PREF_PLAYER_NAME];
            [defaults setFloat:view.redSlider.value forKey:PREF_PLAYER_LETTER_COLOR_RED];
            [defaults setFloat:view.greenSlider.value forKey:PREF_PLAYER_LETTER_COLOR_GREEN];
            [defaults setFloat:view.blueSlider.value forKey:PREF_PLAYER_LETTER_COLOR_BLUE];
            
            [defaults setBool:view.musicSwitch.on forKey:PREF_PLAYER_MUSIC_ENABLED];
            [defaults setFloat:view.musicSlider.value forKey:PREF_PLAYER_MUSIC_VOLUME];
            [defaults setBool:view.soundSwitch.on forKey:PREF_PLAYER_SOUND_ENABLED];
            [defaults setFloat:view.soundSlider.value forKey:PREF_PLAYER_SOUND_VOLUME];
            
            [defaults synchronize];
            
            if (self.onCloseSelector && self.onCloseDelegate) {
                int flags = 0;
                if (didNameChange) {
                    flags |= 1;
                }
                if (didPortraitChange) {
                    flags |= 2;
                }
                [self.onCloseDelegate performSelector:self.onCloseSelector withObject:[NSNumber numberWithInt:flags]];
            }
    		[self.view removeFromSuperview];
    		[self release];
    	}
    ];
}
/*
+(void)showModal:(UIViewController*)parentViewController onCloseSelector:(SEL)onCloseSelector {
	NSString *nibName = @"OptionsController";
	OptionsController *controller = [[OptionsController alloc] initWithNibName:nibName bundle:nil];
	controller.onCloseDelegate = parentViewController;
	controller.onCloseSelector = onCloseSelector;
	[parentViewController presentModalViewController:controller animated:YES];
	[controller release];
}

-(void)saveChanges:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	AletterationPlayerInfo *pInfo = gameState.localPlayerInfo;
	
	pInfo.name = view.nameTextField.text;
	pInfo.portrait = view.portraitImageView.image;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:pInfo.name forKey:PREF_PLAYER_NAME];
	[defaults setFloat:view.redSlider.value forKey:PREF_PLAYER_LETTER_COLOR_RED];
	[defaults setFloat:view.greenSlider.value forKey:PREF_PLAYER_LETTER_COLOR_GREEN];
	[defaults setFloat:view.blueSlider.value forKey:PREF_PLAYER_LETTER_COLOR_BLUE];
	
	[defaults setBool:view.musicSwitch.on forKey:PREF_PLAYER_MUSIC_ENABLED];
	[defaults setFloat:view.musicSlider.value forKey:PREF_PLAYER_MUSIC_VOLUME];
	[defaults setBool:view.soundSwitch.on forKey:PREF_PLAYER_SOUND_ENABLED];
	[defaults setFloat:view.soundSlider.value forKey:PREF_PLAYER_SOUND_VOLUME];
	
	[defaults synchronize];
	
	if (self.onCloseSelector && self.onCloseDelegate) {
		int flags = 0;
		if (didNameChange) {
			flags |= 1;
		}
		if (didPortraitChange) {
			flags |= 2;
		}
		[self.onCloseDelegate performSelector:self.onCloseSelector withObject:[NSNumber numberWithInt:flags]];
	}
	
	[self dismissModalViewController];
}
*/
-(UIImage*)namedSliderImage:(NSString*)filename {
	NSString *fileType = @"png";
	NSString *dir = @"Textures/SliderColors";
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:fileType inDirectory:dir];
	UIImage *uiImage = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
	return uiImage;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		gameState = [AletterationGameState instance];

		tapToHideKeyboad = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
		tapToHideKeyboad.cancelsTouchesInView = NO;
		tapToHideKeyboad.delaysTouchesBegan = NO;
		tapToHideKeyboad.delaysTouchesEnded = NO;

		didNameChange = NO;
		didPortraitChange = NO;
}
    return self;
}

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	OptionsView *view = (OptionsView*)self.view;
	
	[view.redSlider setMinimumTrackImage:[[self namedSliderImage:@"redSlider"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[view.greenSlider setMinimumTrackImage:[[self namedSliderImage:@"greenSlider"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[view.blueSlider setMinimumTrackImage:[[self namedSliderImage:@"blueSlider"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
	
	NSArray *roundedCornerViewArray = [NSArray arrayWithObjects:view.soundArea, view.colorArea, view.playerArea, nil];
	
	for (UIView *rView in roundedCornerViewArray) {
		rView.layer.borderColor = [UIColor blackColor].CGColor;
		rView.layer.borderWidth = 2.0;
		rView.layer.cornerRadius = 9;
	}
	view.scrollView.contentSize = CGSizeMake(480, 320);

	view.colorBox.layer.borderColor = [UIColor blackColor].CGColor;
	view.colorBox.layer.borderWidth = 2.0;
	view.colorBox.layer.cornerRadius = 9;
	
	view.portraitImageView.layer.masksToBounds = YES;
	view.portraitImageView.layer.cornerRadius = 10;
	
	view.nameTextField.text = gameState.localPlayerInfo.name;
	
	color4uc blockColor = gameState.letterColor;
	view.redSlider.value = blockColor.r/255.0;
	view.greenSlider.value = blockColor.g/255.0;
	view.blueSlider.value = blockColor.b/255.0;
	
	view.portraitImageView.image = gameState.localPlayerInfo.portrait;

	view.musicSlider.value = gameState.musicVolume;
	[self musicVolumeChanged:view.musicSlider];
	view.musicSwitch.on = gameState.musicEnabled;
	[self musicSwitchChanged:view.musicSwitch];
	
	view.soundSlider.value = gameState.soundVolume;
	[self soundVolumeChanged:nil];
	view.soundSwitch.on = gameState.soundEnabled;
	[self soundSwitchChanged:nil];

	[self blockColorChanged:nil];

	activeField = nil;
	[self registerForKeyboardNotifications];

	[view addGestureRecognizer:tapToHideKeyboad];
}

-(void)viewDidUnload {
    [self unregisterForKeyboardNotifications];

    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
	OptionsView *view = (OptionsView*)self.view;
	view.isDrawing = YES;
}

-(IBAction)dismissKeyboard:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	if (view.nameTextField.text.length > 0) {
		[view.nameTextField resignFirstResponder];
	}
}

-(void)blockColorChanged:(id)sender {
	OptionsView *view = (OptionsView*)self.view;

	float r = view.redSlider.value;
	float g = view.greenSlider.value;
	float b = view.blueSlider.value;
	
	view.colorBox.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];

	float luma = [[AletterationGameState instance] setLetterRed:r Green:g Blue:b];
	if (luma > 0.5) {
		view.colorBox.image = [UIImage imageNamed:@"a-black.png"];
	} else {
		view.colorBox.image = [UIImage imageNamed:@"a-white.png"];
	}
}

-(void)soundSwitchChanged:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	view.soundSlider.enabled = view.soundSwitch.on;
	view.soundVolumeImageView.alpha = view.soundSwitch.on?1.0:0.3;
	gameState.soundEnabled = view.soundSwitch.on;
}

-(void)musicSwitchChanged:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	view.musicSlider.enabled = view.musicSwitch.on;
	view.musicVolumeImageView.alpha = view.musicSwitch.on?1.0:0.3;
	gameState.musicEnabled = view.musicSwitch.on;
}

-(void)changeVolumeIcon:(UIImageView*)volumeIconView Volume:(float)vol {
	if (vol > 0.666) {
		volumeIconView.image = [UIImage imageNamed:@"vol3.png"];
	} else if (vol > 0.333) {
		volumeIconView.image = [UIImage imageNamed:@"vol2.png"];
	} else if (vol > 0) {
		volumeIconView.image = [UIImage imageNamed:@"vol1.png"];
	} else {
		volumeIconView.image = [UIImage imageNamed:@"vol0.png"];
	}
}

-(void)soundVolumeChanged:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	[self changeVolumeIcon:view.soundVolumeImageView Volume:view.soundSlider.value];
	gameState.soundVolume = view.soundSlider.value;
}

-(void)musicVolumeChanged:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	[self changeVolumeIcon:view.musicVolumeImageView Volume:view.musicSlider.value];
	gameState.musicVolume = view.musicSlider.value;
}

-(IBAction)chooseImage:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	view.isDrawing = NO;
	
	[PhotoChoiceController showModal:self.parentViewController delegate:self selector:@selector(photoPicked:)];
}

-(IBAction)takePhoto:(id)sender {
	OptionsView *view = (OptionsView*)self.view;
	view.isDrawing = NO;
	
	[TakePictureController showModal:self.parentViewController delegate:self selector:@selector(photoPicked:)];
}

-(void)photoPicked:(UIImage*)photoImage {
	OptionsView *view = (OptionsView*)self.view;
	view.portraitImageView.image = photoImage;
	gameState.localPlayerInfo.portrait = photoImage;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:UIImageJPEGRepresentation(photoImage, 1.0) forKey:PREF_PLAYER_PORTRAIT];
	[defaults setInteger:photoImage.imageOrientation forKey:PREF_PLAYER_PORTRAIT_ORIENTATION];
	[defaults synchronize];
    
    didPortraitChange = YES;
}

#pragma mark - Scrollview textbox movement

-(void)unregisterForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)aNotification {
	OptionsView *view = (OptionsView*)self.view;
	
	view.isDrawing = NO;
	
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	view.scrollView.contentSize = CGSizeMake(480, 320+kbSize.width);
	
	float y = activeField.superview.frame.origin.y + activeField.superview.frame.size.height + 10;
	
	[view.scrollView setContentOffset:CGPointMake(0.0, y-kbSize.width) animated:YES];
}

-(void)keyboardDidShow:(NSNotification*)aNotification {
	[activeField selectAll:self];
}

// Called when the UIKeyboardWillHideNotification is sent
-(void)keyboardWillHide:(NSNotification*)aNotification {
	OptionsView *view = (OptionsView*)self.view;
    [view.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

-(void)keyboardDidHide:(NSNotification*)aNotification {
	OptionsView *view = (OptionsView*)self.view;
	view.isDrawing = YES;
	didNameChange = YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

-(void)dealloc {
	[tapToHideKeyboad release];
	self.onCloseDelegate = nil;
	self.onCloseSelector = nil;
	[super dealloc];
}

@end
