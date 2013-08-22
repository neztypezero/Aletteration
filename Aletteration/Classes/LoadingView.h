//
//  RootView.h
//  Aletteration
//
//  Created by David Nesbitt on 1/19/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"
#import "GLSLProgram.h"

@class AletterationGameState;

@interface LoadingView : NezBaseSceneView {
	UIProgressView *progressView;
	UIImageView *titleImageView;
	UIImageView *logoImageView;
	BOOL isSceneLoaded;
	BOOL isSceneLoading;
    AletterationGameState *gameState;
}

@property (nonatomic, readonly) BOOL isSceneLoaded;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIImageView *titleImageView;
@property (nonatomic, retain) IBOutlet UIImageView *logoImageView;

@end
