//
//  QuickRulesView.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-30.
//
//

#import "NezBaseSceneView.h"
#import "AletterationGameState.h"

@interface QuickRulesView : NezBaseSceneView {
	AletterationGameState *gameState;
}

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

@end
