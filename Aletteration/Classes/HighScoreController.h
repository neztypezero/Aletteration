//
//  HighScoreController.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-16.
//
//

#import "NezBaseSceneController.h"
#import "HighScoreView.h"

@interface HighScoreController : NezBaseSceneController<UITableViewDelegate,UITableViewDataSource> {
    NSArray *_highScoreList;
    NSArray *_selectedWordList;
}

@property(nonatomic, readonly, getter = getHighScoreView) HighScoreView *highScoreView;

@property(nonatomic, retain) id onCloseDelegate;
@property(nonatomic, assign) SEL onCloseSelector;

@property(nonatomic, retain) NSArray *highScoreList;
@property(nonatomic, retain) NSArray *selectedWordList;

+(void)showView:(UIViewController*)parentViewController onCloseSelector:(SEL)onClose;

-(IBAction)closeDialog:(id)sender;

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
