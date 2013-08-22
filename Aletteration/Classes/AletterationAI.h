//
//  AletterationAI.h
//  Aletteration
//
//  Created by David Nesbitt on 2/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameState.h"


@interface AletterationAI : NSObject {
	AletterationGameState *gameState;
	
	int junkLine;
}

-(id)initWithGameState:(AletterationGameState*)gs;
-(int)pickLineForCurrentState;

@end
