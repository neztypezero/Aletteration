//
//  PhotoChoiceScene.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneController.h"

@class AletterationGameState;
@class ALAssetsLibrary;
@class ALAssetsGroup;
@class ALAsset;

typedef enum PhotoChoiceMode {
	PhotoChoiceModeNone,
	PhotoChoiceModePicking,
	PhotoChoiceModeEditing,
} PhotoChoiceMode;

@interface PhotoChoiceController : NezBaseSceneController {
	AletterationGameState *gameState;
	UIPinchGestureRecognizer *imagePinchGestureRecognizer;
	UIPanGestureRecognizer *imagePanGestureRecognizer;
	
	CGFloat minimumScale;
	CGFloat absoluteScale;
	CGPoint absoluteTranslation;
	CGRect imageViewFrame;
	
	PhotoChoiceMode mode;
	
	UISegmentedControl *assetTypeSegmentedControl;
	
	NSMutableArray *assetGroupAlbumsArray;
	NSMutableArray *assetGroupEventsArray;
	NSMutableArray *assetGroupFacesArray;
	NSMutableArray *assetGroupPhotosArray;
	NSMutableArray *assetGroupArray;

	NSMutableArray *assetArray;
	SEL currentAction;
	
	NSMutableArray *thumbnailArray;
	CGFloat thumbnailWidth;
	CGFloat thumbnailHeight;
	NSRange currentThumbnailRange;
	
	ALAssetsLibrary *library;
}

+(void)showModal:(UIViewController*)parentViewController delegate:(id)del selector:(SEL)sel;

-(void)loadPickMode;

-(void)setPickMode;
-(void)setEditMode;

-(void)showPhotoList;
-(void)hidePhotoList;

-(void)showAssetGroupImage:(ALAssetsGroup*)assetGroup;
-(void)showAssetImage:(ALAsset*)asset;
-(void)enumerateAssets:(ALAssetsGroup*)assetGroup;

-(void)removeAllThumbnails;

-(IBAction)doneAction:(UIButton*)sender;
-(IBAction)saveAction:(UIButton*)sender;

@property (nonatomic, retain) id didPickPhotoDelegate;
@property (nonatomic, assign) SEL didPickPhotoSelector;

@end
