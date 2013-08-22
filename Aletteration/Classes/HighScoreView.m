//
//  HighScoreView.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-16.
//
//

#import "HighScoreView.h"

@implementation HighScoreView

@synthesize mainArea;
@synthesize highScoreArea;
@synthesize wordListArea;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        gameState = [AletterationGameState instance];
	}
    return self;
}

-(void)draw {
	[gameState draw];
}

-(void)dealloc {
    self.mainArea = nil;
    self.highScoreArea = nil;
    self.wordListArea = nil;
    [super dealloc];
}

@end
