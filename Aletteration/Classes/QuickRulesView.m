//
//  QuickRulesView.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-30.
//
//

#import "QuickRulesView.h"

@implementation QuickRulesView

@synthesize closeButton;
@synthesize nextButton;

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
	self.closeButton = nil;
	self.nextButton = nil;
	[super dealloc];
}

@end
