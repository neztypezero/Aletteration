//
//  HighScoreView.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-16.
//
//

#import "NezBaseSceneView.h"
#import "AletterationGameState.h"

@interface HighScoreView : NezBaseSceneView {
	AletterationGameState *gameState;
}

@property (nonatomic, retain) IBOutlet UIView *mainArea;
@property (nonatomic, retain) IBOutlet UIView *highScoreArea;
@property (nonatomic, retain) IBOutlet UIView *wordListArea;
@property (nonatomic, retain) IBOutlet UITableView *highScoreTableView;
@property (nonatomic, retain) IBOutlet UITableView *wordListTableView;

@end
