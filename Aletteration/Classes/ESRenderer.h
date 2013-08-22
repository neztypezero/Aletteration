//
//  ESRenderer.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/25/10.
//  Copyright David Nesbitt 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@class NezBaseSceneView;

@protocol ESRenderer <NSObject>

-(EAGLContext*)getContext;
-(void)render:(NezBaseSceneView*)scene;
-(BOOL)resizeFromLayer:(CAEAGLLayer*)layer;

@end
