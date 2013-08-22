//
//  EAGLView.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/25/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView {    
@private
    id <ESRenderer> renderer;
	
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
	CFTimeInterval lastTime;
	
	BOOL isMachineFast;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (readonly, nonatomic, getter=getContext) EAGLContext *context;

-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView:(id)sender;
-(void)setAnimationFrameInterval:(NSInteger)frameInterval;

@end
