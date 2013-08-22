//
//  EAGLView.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/25/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//

#import "EAGLView.h"
#import "ES2Renderer.h"

#import "AletterationAppDelegate.h"
#import "NezBaseSceneView.h"
#import "NezBaseSceneController.h"

#import "UIDevice+machine.h"

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize context;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];

		NSString *machine = [[UIDevice currentDevice] machine];
		isMachineFast = NO;
		if ([machine hasPrefix:@"iPad"]) {
			if ([machine characterAtIndex:4] > '1') {
				isMachineFast = YES;
			}
		} else if ([machine hasPrefix:@"iPod"]) {
			if ([machine characterAtIndex:4] > '4') {
				isMachineFast = YES;
			}
		} else if ([machine hasPrefix:@"iPhone"]) {
			if ([machine characterAtIndex:4] > '4') {
				isMachineFast = YES;
			}
		}
		
		renderer = [[ES2Renderer alloc] init];
        animating = FALSE;
        animationFrameInterval = isMachineFast?1:3;
        displayLink = nil;
		lastTime = 0;

	}
    return self;
}

-(EAGLContext*)getContext {
	return [renderer getContext];
}

- (void)drawView:(CADisplayLink*)sender {
	CFTimeInterval currentTime = sender.timestamp;
	if (lastTime > 0) {
		AletterationAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		UIViewController *visibleController = delegate.navigationController.visibleViewController;
		if ([visibleController isKindOfClass:[NezBaseSceneController class]]) {
			NezBaseSceneController *controller = (NezBaseSceneController*)visibleController;
			NezBaseSceneView *view = (NezBaseSceneView*)controller.view;
			[controller updateWithCurrentTime:currentTime andPreviousTime:lastTime];
			[renderer render:view];
		}
	}
	lastTime = currentTime;
}

- (void)layoutSubviews {
	static BOOL firstTime = YES;
	if (firstTime) {
		UIScreen *mainScreen = [UIScreen mainScreen];
		float scale = mainScreen.scale;
		float w = mainScreen.bounds.size.width;
		float h = mainScreen.bounds.size.height;
		float sw = w*scale;
		float sh = h*scale;
		self.frame = CGRectMake(0, 0, sw, sh);
		self.bounds = CGRectMake(0, 0, sw, sh);
		CGAffineTransform matrix = {
			1/scale, 0,
			0, 1/scale,
			(w-sw)/2, (h-sh)/2,
		};
		self.transform = matrix;
		
		[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
		firstTime = NO;
	}
}

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

-(void)setAnimationFrameInterval:(NSInteger)frameInterval {
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
//        animationFrameInterval = isMachineFast?frameInterval:frameInterval*2;
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation {
    if (!animating) {
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
		[displayLink setFrameInterval:animationFrameInterval];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];//this will stop opengl rendering during uikit animation
//		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        animating = TRUE;
    }
}

- (void)stopAnimation {
    if (animating) {
		[displayLink invalidate];
		displayLink = nil;
        animating = FALSE;
    }
}

- (void)dealloc {
    [renderer release];
    [super dealloc];
}

@end
