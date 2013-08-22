//
//  AletterationGameView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-31.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@class AletterationGameState;

@interface AletterationGameView : NezBaseSceneView {
	AletterationGameState *gameState;
}

-(void)hideControls;
-(void)showControls;

@end
