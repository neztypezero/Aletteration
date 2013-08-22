//
//  EditDictionaryViewController.h
//  Aletteration
//
//  Created by David Nesbitt on 2013-01-11.
//
//

#import "NezBaseSceneController.h"


@interface WordSelectionCursor : NSObject

@property (nonatomic, assign) int total;
@property (nonatomic, assign) int tableLetter;
@property (nonatomic, assign) int start;
@property (nonatomic, retain) NSArray *wordListP;
@property (nonatomic, retain) NSArray *wordListM;
@property (nonatomic, retain) NSArray *wordListN;

+(id)cursorWithTableLetter:(char)tableLetter;

@end

@interface EditDictionaryViewController : NezBaseSceneController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain) WordSelectionCursor *selectionCursor;
@property (nonatomic, retain) IBOutlet UITableView *wordListTableView;

+(void)showView:(UIViewController*)parentViewController;
-(void)closeDialog:(id)sender;

@end
