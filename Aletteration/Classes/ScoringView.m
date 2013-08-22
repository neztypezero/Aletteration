//
//  ScoringView.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-30.
//
//

#import "ScoringView.h"

@implementation ScoringView

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        gameState = [AletterationGameState instance];
	}
    return self;
}

-(void)draw {
	[gameState draw];
}

@end
