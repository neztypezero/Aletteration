//
//  PhotoChoiceScene.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "PhotoChoiceController.h"
#import "PhotoChoiceView.h"
#import "AletterationGameState.h"

#define THUMBNAIL_SPACE 10.0f
const CGFloat THUMBNAIL_HALF_SPACE = THUMBNAIL_SPACE/2.0;

@interface AssetInfo : NSObject {
@public
	int index;
	UIButton *button;
}
@end

@implementation AssetInfo

+(id)assetInfoWithIndex:(int)index {
	AssetInfo *info = [[AssetInfo alloc] autorelease];
	info->index = index;
	info->button = nil;
	return info;
}

@end

@interface PhotoChoiceController (private)

-(void)addButtonToAssetInfo:(AssetInfo*)info withAction:(SEL)action andIndex:(int)index;
-(AssetInfo*)addButtonWithAction:(SEL)sel;

@end 

@implementation PhotoChoiceController

@synthesize didPickPhotoDelegate;
@synthesize didPickPhotoSelector;

+(void)showModal:(UIViewController*)parentViewController delegate:(id)del selector:(SEL)sel {
	NSString *nibName = @"PhotoChoiceController";
	PhotoChoiceController *controller = [[PhotoChoiceController alloc] initWithNibName:nibName bundle:nil];
	controller.didPickPhotoDelegate = del;
	controller.didPickPhotoSelector = sel;
	[parentViewController presentModalViewController:controller animated:YES];
	[controller release];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        gameState = [AletterationGameState instance];
		
		imagePinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imagePinchAction:)];
		
		imagePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imagePanAction:)];
		imagePanGestureRecognizer.maximumNumberOfTouches = 1;
		
		assetGroupAlbumsArray = [[NSMutableArray alloc] initWithCapacity:16];
		assetGroupEventsArray = [[NSMutableArray alloc] initWithCapacity:16];
		assetGroupFacesArray = [[NSMutableArray alloc] initWithCapacity:16];
		assetGroupPhotosArray = [[NSMutableArray alloc] initWithCapacity:16];
		assetArray = [[NSMutableArray alloc] initWithCapacity:64];
		assetGroupArray = assetGroupAlbumsArray;
		
		library = [[ALAssetsLibrary alloc] init];
		
		currentAction = @selector(pressAssetGroupAction:);

		self.didPickPhotoDelegate = nil;
		self.didPickPhotoSelector = nil;
		
		assetTypeSegmentedControl = nil;
		
		thumbnailArray = [[NSMutableArray alloc] initWithCapacity:128];
	}
    return self;
}

-(void)springBack {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;

	CGFloat dw = (absoluteScale*view.mainImageView.image.size.width)/2.0;
	CGFloat dh = (absoluteScale*view.mainImageView.image.size.height)/2.0;
	CGPoint center = view.editOutlineView.center;
	CGFloat topY = view.editOutlineView.frame.origin.y;
	CGFloat bottomY = topY+view.editOutlineView.frame.size.height;
	CGFloat leftX = view.editOutlineView.frame.origin.x;
	CGFloat rightX = leftX+view.editOutlineView.frame.size.width;
	
	CGFloat dy = 0;
	if (center.y+absoluteTranslation.y-dh > topY) {
		dy = (topY-center.y+dh)-absoluteTranslation.y;
	} else if (center.y+absoluteTranslation.y+dh < bottomY) {
		dy = (bottomY-center.y-dh)-absoluteTranslation.y;
	}
	CGFloat dx = 0;
	if (center.x+absoluteTranslation.x-dw > leftX) {
		dx = (leftX-center.x+dw)-absoluteTranslation.x;
	} else if (center.x+absoluteTranslation.x+dw < rightX) {
		dx = (rightX-center.x-dw)-absoluteTranslation.x;
	}
	if (dx != 0 || dy != 0) {
		CGFloat distance = sqrtf((dx*dx)+(dy*dy));
		
		absoluteTranslation.x += dx;
		absoluteTranslation.y += dy;
		
		CGAffineTransform transform = CGAffineTransformMake(absoluteScale, 0, 0, absoluteScale, absoluteTranslation.x, absoluteTranslation.y);
		[UIView animateWithDuration:distance/400.0
			animations:^{
				[view.mainImageView setTransform:transform];
			}
			completion:^(BOOL completed) {
			}
		];
	}
}

-(void)imagePinchAction:(UIPinchGestureRecognizer*)sender {
	if (mode == PhotoChoiceModeEditing) {
		PhotoChoiceView *view = (PhotoChoiceView*)self.view;

		float scale = absoluteScale*sender.scale;
		
		if (scale > 2.0) {
			scale = 2.0;
		} else if (scale < minimumScale) {
			scale = minimumScale;
		}
		
		CGAffineTransform transform = CGAffineTransformMake(scale, 0, 0, scale, absoluteTranslation.x, absoluteTranslation.y);
		
		[view.mainImageView setTransform:transform];
		
		if (sender.state == UIGestureRecognizerStateEnded) {
			absoluteScale = scale;
			[self springBack];
		}
	}
}

-(void)imagePanAction:(UIPanGestureRecognizer*)sender {
	if (mode == PhotoChoiceModeEditing) {
		PhotoChoiceView *view = (PhotoChoiceView*)self.view;
		CGPoint translation = [sender translationInView:view];
		
		CGFloat tx = absoluteTranslation.x+translation.x;
		CGFloat ty = absoluteTranslation.y+translation.y;
		
		CGAffineTransform transform = CGAffineTransformMake(absoluteScale, 0, 0, absoluteScale, tx, ty);
		[view.mainImageView setTransform:transform];
		
		if (sender.state == UIGestureRecognizerStateEnded) {
			absoluteTranslation.x += translation.x;
			absoluteTranslation.y += translation.y;
			[self springBack];
		}
	}
}

-(void)loadPickMode {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	
	[self removeAllThumbnails];
	
	CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0); //Identity Matrix
	[view.mainImageView setTransform:transform];

	view.editOutlineView.hidden = YES;
	
	// Load Albums into assetGroups
	// Group enumerator Block
	void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
	   if (group != nil && group.numberOfAssets > 0 && group.posterImage != nil) {
		   int segmentIndex = assetTypeSegmentedControl.selectedSegmentIndex;
		   ALAssetsGroupType assetType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
		   switch (assetType) {
			   case ALAssetsGroupAlbum:
				   [assetGroupAlbumsArray addObject:group];
				   if (segmentIndex == 0) {
					   [self showAssetGroupImage:group];
				   }
				   break;
			   case ALAssetsGroupEvent:
				   [assetGroupEventsArray addObject:group];
				   if (segmentIndex == 1) {
					   [self showAssetGroupImage:group];
				   }
				   break;
			   case ALAssetsGroupFaces:
				   [assetGroupFacesArray addObject:group];
				   if (segmentIndex == 2) {
					   [self showAssetGroupImage:group];
				   }
				   break;
			   default:
				   [assetGroupPhotosArray addObject:group];
				   if (segmentIndex == 3) {
					   [self showAssetGroupImage:group];
				   }
				   break;
		   }
	   }
	};
   
	// Group Enumerator Failure Block
	void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
		//NSLog(@"A problem occured %@", [error description]);       
	};	
	// Enumerate Albums
	[library enumerateGroupsWithTypes:ALAssetsGroupLibrary
						  usingBlock:assetGroupEnumerator 
						failureBlock:assetGroupEnumberatorFailure];

	[library enumerateGroupsWithTypes:ALAssetsGroupAll
						   usingBlock:assetGroupEnumerator 
						 failureBlock:assetGroupEnumberatorFailure];

	view.mainImageView.image = gameState.localPlayerInfo.portrait;
}

-(void)setPickMode {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;

	mode = PhotoChoiceModePicking;

	view.mainImageView.image = gameState.localPlayerInfo.portrait;
	view.editOutlineView.hidden = YES;
	[self showPhotoList];
}

-(void)showPhotoList {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	
	UIScrollView *thumbnailScrollView = view.thumbnailScrollView;

	CGRect f = imageViewFrame;
	CGFloat h = thumbnailScrollView.frame.size.height;
	thumbnailScrollView.frame = CGRectMake(0, f.origin.y+f.size.height, f.size.width, h);
	thumbnailScrollView.hidden = NO;
	
	[UIView animateWithDuration:0.25
		animations:^{
			thumbnailScrollView.frame = CGRectMake(0, f.origin.y+f.size.height-h, f.size.width, h);

			CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
			[view.mainImageView setTransform:transform];
			view.mainImageView.frame = f;
		}
		completion:^(BOOL completed) {
		}
	];
}

-(void)hidePhotoList {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	
	UIScrollView *thumbnailScrollView = view.thumbnailScrollView;
	
	CGRect f = imageViewFrame;
	CGFloat h = thumbnailScrollView.frame.size.height;
	
	[UIView animateWithDuration:0.25
		animations:^{
			thumbnailScrollView.frame = CGRectMake(0, f.origin.y+f.size.height, f.size.width, h);
		}
		completion:^(BOOL completed) {
			thumbnailScrollView.hidden = YES;
		}
	];
}

-(NSRange)getViewableThumbnailRange {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	UIScrollView *thumbnailScrollView = view.thumbnailScrollView;

	CGFloat w = thumbnailScrollView.frame.size.width-THUMBNAIL_SPACE;
	int count = (int)(w/(thumbnailWidth+THUMBNAIL_HALF_SPACE))+4;
	
	int offset = (int)(thumbnailScrollView.contentOffset.x);
	int start = (int)(offset/(thumbnailWidth+THUMBNAIL_HALF_SPACE))-2;

	if (start < 0) {
		start = 0;
	}
	if (count < 0) {
		count = 0;
	}
	
	NSRange range = { start, count };
	return range;
}

-(void)removeAllThumbnails {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	for (UIButton *button in [view.thumbnailScrollView subviews]) {
		[button removeFromSuperview];
	}
	currentThumbnailRange = [self getViewableThumbnailRange];
	[thumbnailArray removeAllObjects];
}

-(void)setupThumbnailButtonsWithStart:(int)start End:(int)end andAddFlag:(BOOL)addFlag {
	if (start > [thumbnailArray count]) {
		start = [thumbnailArray count];
	}
	if (end > [thumbnailArray count]) {
		end = [thumbnailArray count];
	}
	if (addFlag) {
		PhotoChoiceView *view = (PhotoChoiceView*)self.view;
		UIScrollView *thumbnailScrollView = view.thumbnailScrollView;
		for (int i=start; i<end; i++) {
			AssetInfo *info = [thumbnailArray objectAtIndex:i];
			if (info->button == nil) {
				[self addButtonToAssetInfo:info withAction:currentAction andIndex:i];
			}
			UIButton *button = info->button;
			if (button.superview == nil) {
				[thumbnailScrollView addSubview:button];
			}
		}
	} else {
		for (int i=start; i<end; i++) {
			AssetInfo *info = [thumbnailArray objectAtIndex:i];
			UIButton *button = info->button;
			if (button != nil) {
				[button removeFromSuperview];
				info->button = nil;
			}
		}
	}
}

-(CGRect)getButtonFrameWithIndex:(int)index {
	return CGRectMake(THUMBNAIL_HALF_SPACE+(THUMBNAIL_HALF_SPACE+thumbnailWidth)*index, THUMBNAIL_HALF_SPACE, thumbnailWidth, thumbnailHeight);
}

-(void)setupThumbnailButtons {
	NSRange range = [self getViewableThumbnailRange];
	if (currentThumbnailRange.location == range.location) {
		return;
	}
	if (currentThumbnailRange.location < range.location) {
		[self setupThumbnailButtonsWithStart:currentThumbnailRange.location End:range.location andAddFlag:NO];
	} else {
		[self setupThumbnailButtonsWithStart:range.location+range.length End:currentThumbnailRange.location+currentThumbnailRange.length andAddFlag:NO];
	}
	[self setupThumbnailButtonsWithStart:range.location End:range.location+range.length andAddFlag:YES];
	currentThumbnailRange = range;
}

-(void)addButtonToAssetInfo:(AssetInfo*)info withAction:(SEL)action andIndex:(int)index {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = [self getButtonFrameWithIndex:info->index];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	[button setAdjustsImageWhenHighlighted:YES];
	button.alpha = 1.0;
	if ([assetArray count] > 0) {
		ALAsset *asset = [assetArray objectAtIndex:index];
		[button setImage:[UIImage imageWithCGImage:asset.thumbnail] forState:UIControlStateNormal];
	} else {
		ALAssetsGroup *group = [assetGroupArray objectAtIndex:index];
		[button setImage:[UIImage imageWithCGImage:group.posterImage] forState:UIControlStateNormal];
	}
	button.tag = index;
	info->button = button;
}

-(AssetInfo*)addButtonWithAction:(SEL)sel {
	int index = [thumbnailArray count];
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	UIScrollView *thumbnailScrollView = view.thumbnailScrollView;
	
	CGRect frame = [self getButtonFrameWithIndex:index];
	AssetInfo *info = [AssetInfo assetInfoWithIndex:index];
	
	[thumbnailArray addObject:info];
	if (index >= currentThumbnailRange.location && index < currentThumbnailRange.location+currentThumbnailRange.length) {
		[self addButtonToAssetInfo:info withAction:sel andIndex:index];
		[thumbnailScrollView addSubview:info->button];
		info->button.alpha = 0.0;
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				info->button.alpha = 1.0;
			}
			completion:^(BOOL completed) {
			}
		];
	}
	thumbnailScrollView.contentSize = CGSizeMake(frame.origin.x+thumbnailWidth+THUMBNAIL_HALF_SPACE, thumbnailHeight);
	
	return info;
}

-(void)showAssetGroupImage:(ALAssetsGroup*)assetGroup {
	[self addButtonWithAction:@selector(pressAssetGroupAction:)];
}

-(void)showAssetGroups {
	currentAction = @selector(pressAssetGroupAction:);

	[assetArray removeAllObjects];
	[self removeAllThumbnails];
	if (assetTypeSegmentedControl != nil) {
		switch (assetTypeSegmentedControl.selectedSegmentIndex) {
			case 3:
				assetGroupArray = assetGroupPhotosArray;
				break;
			case 2:
				assetGroupArray = assetGroupFacesArray;
				break;
			case 1:
				assetGroupArray = assetGroupEventsArray;
				break;
			default:
				assetGroupArray = assetGroupAlbumsArray;
				break;
		}
		for (ALAssetsGroup *group in assetGroupArray) {
			[self showAssetGroupImage:group];
		}
	}
}

-(void)assetSegementChanged:(id)sender {
	[self showAssetGroups];
}

-(void)pressAssetGroupAction:(UIButton*)sender {
	currentAction = @selector(pressAssetAction:);

	ALAssetsGroup *assetGroup = [assetGroupArray objectAtIndex:sender.tag];
	
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	view.photoNavigationItem.title = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
	view.albumNavigationItem.backBarButtonItem.title = [assetTypeSegmentedControl titleForSegmentAtIndex:assetTypeSegmentedControl.selectedSegmentIndex];
	[view.navigationBar pushNavigationItem:view.photoNavigationItem animated:YES];
	
	[self enumerateAssets:assetGroup];
}

-(void)enumerateAssets:(ALAssetsGroup*)assetGroup {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	[UIView animateWithDuration:0.5
		animations:^{
			for (UIButton *albumButton in [view.thumbnailScrollView subviews]) {
				albumButton.alpha = 0.0;
			}
		}
		completion:^(BOOL completed) {
			[assetArray removeAllObjects];
			[self removeAllThumbnails];
				
			[assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {         
				if(result != nil) {
					[assetArray addObject:result];
					[self showAssetImage:result];
				}
			}];
		}
	];
}

-(void)showAssetImage:(ALAsset*)asset {
	[self addButtonWithAction:@selector(pressAssetAction:)];
}

-(void)pressAssetAction:(UIButton*)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ALAsset *asset = [assetArray objectAtIndex:sender.tag];
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	
	ALAssetRepresentation *rep = [asset defaultRepresentation];
	CGImageRef iref = [rep fullResolutionImage];
	if (iref) {
        //NSLog(@"rep.orientation:%d", rep.orientation);
		view.mainImageView.image = [UIImage imageWithCGImage:iref scale:1.0f orientation:(UIImageOrientation)rep.orientation];
        //NSLog(@"view.mainImageView.image.orientation:%d", view.mainImageView.image.imageOrientation);
	}
	[view.navigationBar pushNavigationItem:view.editNavigationItem animated:YES];
	[self setEditMode];
	
	[pool drain];
}

-(void)setEditMode {
	mode = PhotoChoiceModeEditing;

	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	
	absoluteTranslation.x = 0.0;
	absoluteTranslation.y = 0.0;

	CGSize size = view.mainImageView.superview.frame.size;

	CGFloat h = size.height*0.75;
	CGFloat w = h*1.5;
	view.editOutlineView.frame = CGRectMake(0, 0, w, h);
	view.editOutlineView.center = CGPointMake(size.width/2.0, size.height/2.0);
	view.editOutlineView.hidden = NO;

	minimumScale = w/view.mainImageView.image.size.width;
	absoluteScale = minimumScale;

	[UIView animateWithDuration:0.25
		animations:^{
			CGFloat imageW = view.mainImageView.image.size.width;
			CGFloat imageH = view.mainImageView.image.size.height;
			view.mainImageView.frame = CGRectMake(size.width/2.0-imageW/2.0, size.height/2.0-imageH/2.0, imageW, imageH);
			CGAffineTransform transform = CGAffineTransformMake(absoluteScale, 0, 0, absoluteScale, absoluteTranslation.x, absoluteTranslation.y);
			[view.mainImageView setTransform:transform];
		}
		completion:^(BOOL completed) {
		}
	];
	[self hidePhotoList];
}

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	if (item == view.editNavigationItem) {
		[self setPickMode];
	} else if (item == view.photoNavigationItem) {
		[self showAssetGroups];
	}
	return YES;
}

-(void)doneAction:(UIButton*)sender {
	[self dismissModalViewController];
}

-(void)saveAction:(UIButton*)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	PhotoChoiceView *view = (PhotoChoiceView*)self.view;

	int height = (int)(view.editOutlineView.frame.size.height/absoluteScale);
	if (height&1) {
		height--;
	}
	int width = (int)((CGFloat)height*1.5);
	
    CGFloat w = view.mainImageView.image.size.width;
    CGFloat h = view.mainImageView.image.size.height;
	CGFloat dw = (absoluteScale*w)/2.0;
	CGFloat dh = (absoluteScale*h)/2.0;
	CGPoint center = view.editOutlineView.center;
	CGFloat topY = view.editOutlineView.frame.origin.y;
	CGFloat leftX = view.editOutlineView.frame.origin.x;
	
	int x = (int)((leftX-(center.x+absoluteTranslation.x-dw))/absoluteScale);
	int y = (int)((topY-(center.y+absoluteTranslation.y-dh))/absoluteScale);

	CGRect cropRect;
    
    switch (view.mainImageView.image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            cropRect = CGRectMake(y, x, height, width);
            break;
        default:
            cropRect = CGRectMake(x, y, width, height);
            break;
    }

	CGImageRef imageRef = CGImageCreateWithImageInRect([view.mainImageView.image CGImage], cropRect);

    //NSLog(@"view.mainImageView.image.imageOrientation:%d", view.mainImageView.image.imageOrientation);
    //NSLog(@"imageSize:%f, %f", view.mainImageView.image.size.width, view.mainImageView.image.size.height);
    //NSLog(@"cropRect:%d, %d, %d, %d", x, y, width, height);

	float scale = 320.0/width;
	if (scale > 1.0) {
		scale = 1.0;
	}
	gameState.localPlayerInfo.portrait = [UIImage imageWithCGImage:imageRef scale:scale orientation:view.mainImageView.image.imageOrientation];
	CGImageRelease(imageRef);
	
	//NSLog(@"Image Scaled to:%f", scale);
	
	if (self.didPickPhotoDelegate != nil && self.didPickPhotoSelector != nil) {
		[self.didPickPhotoDelegate performSelector:self.didPickPhotoSelector withObject:gameState.localPlayerInfo.portrait];
	}
	
	[pool drain];
	
	[self dismissModalViewController];
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
	
	PhotoChoiceView *view = (PhotoChoiceView*)self.view;
	
	imageViewFrame = view.mainImageView.frame;
	thumbnailHeight = view.thumbnailScrollView.frame.size.height-THUMBNAIL_SPACE;
	thumbnailWidth = thumbnailHeight;
	
	[view addGestureRecognizer:imagePinchGestureRecognizer];
	[view addGestureRecognizer:imagePanGestureRecognizer];
	
	view.editOutlineView.layer.borderWidth = 2.0;
	view.editOutlineView.layer.borderColor = [[UIColor whiteColor] CGColor];
	
	assetTypeSegmentedControl = [[UISegmentedControl alloc] initWithFrame: CGRectZero];
	assetTypeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[assetTypeSegmentedControl insertSegmentWithTitle:@"Albums" atIndex:0 animated:NO];
	[assetTypeSegmentedControl insertSegmentWithTitle:@"Events" atIndex:1 animated:NO];
	[assetTypeSegmentedControl insertSegmentWithTitle:@"Faces"  atIndex:2 animated:NO];
	[assetTypeSegmentedControl insertSegmentWithTitle:@"Photos" atIndex:3 animated:NO];
	[assetTypeSegmentedControl sizeToFit];
	assetTypeSegmentedControl.selectedSegmentIndex = 0;
	[assetTypeSegmentedControl addTarget:self action:@selector(assetSegementChanged:) forControlEvents:UIControlEventValueChanged];
	
	// Any of the following produces the expected result:
	view.albumNavigationItem.titleView = assetTypeSegmentedControl;
	[assetTypeSegmentedControl release];
	
	view.thumbnailScrollView.hidden = YES;
	[self loadPickMode];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self performSelector:@selector(setPickMode) withObject:nil afterDelay:0.25];
}


-(void)scrollViewDidScroll:(UIScrollView*)sender {
	[self setupThumbnailButtons];
}

-(void)dealloc {
	//NSLog(@"dealloc:PhotoChoiceController");
	[imagePinchGestureRecognizer release];
	[imagePanGestureRecognizer release];
	
	[assetGroupAlbumsArray release];
	[assetGroupEventsArray release];
	[assetGroupFacesArray release];
	[assetGroupPhotosArray release];
	[assetArray release];
	
	[thumbnailArray release];
	
	if (library != nil) {
		[library release];
	}
	self.didPickPhotoDelegate = nil;
	self.didPickPhotoSelector = nil;

	[super dealloc];
}

@end
