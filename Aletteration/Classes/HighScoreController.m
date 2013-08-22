//
//  HighScoreController.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-16.
//
//
#import <QuartzCore/QuartzCore.h>

#import "HighScoreController.h"
#import "HighScoreView.h"
#import "NezSQLiteHighScores.h"
#import "UIHighScoreItemCell.h"

@interface HighScoreController ()

@end

@implementation HighScoreController

@synthesize highScoreList;
@synthesize selectedWordList;
@synthesize onCloseDelegate;
@synthesize onCloseSelector;

+(void)showView:(UIViewController*)parentViewController onCloseSelector:(SEL)onClose {
	NSString *nibName = @"HighScoreController";
	HighScoreController *controller = [[HighScoreController alloc] initWithNibName:nibName bundle:nil];

    controller.onCloseDelegate = parentViewController;
    controller.onCloseSelector = onClose;

    CGSize size = controller.view.frame.size;
    CGRect r = CGRectMake(0, size.height, size.width, size.height);
    controller.view.frame = r;
    
	[parentViewController.view addSubview:controller.view];
    
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         controller.view.frame = CGRectMake(0, 0, size.width, size.height);
                     }
                     completion:^(BOOL completed) {
                     }
     ];
}

-(void)closeDialog:(id)sender {
    CGSize size = self.view.frame.size;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.frame = CGRectMake(0, size.height, size.width, size.height);
                     }
                     completion:^(BOOL completed) {
                         if (self.onCloseSelector && self.onCloseDelegate) {
                             [self.onCloseDelegate performSelector:self.onCloseSelector withObject:nil];
                         }
                         [self.view removeFromSuperview];
                         [self release];
                     }
     ];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	HighScoreView *view = (HighScoreView*)self.view;
	
    NSArray *roundRectViewList = [NSArray arrayWithObjects: view.mainArea, view.highScoreArea, view.wordListArea, nil];
    
    for (UIView *roundRectView in roundRectViewList) {
        roundRectView.layer.borderColor = [UIColor blackColor].CGColor;
        roundRectView.layer.borderWidth = 2.0;
        roundRectView.layer.cornerRadius = 9;
    }
    
    self.highScoreList = [NezSQLiteHighScores getHighScoreListWithLimit:20];
}

-(void)viewDidAppear:(BOOL)animated {
	if ([self.highScoreList count] > 0) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.highScoreView.highScoreTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self tableView:self.highScoreView.highScoreTableView didSelectRowAtIndexPath:path];
	}
}

-(HighScoreView*)getHighScoreView {
    return (HighScoreView*)self.view;
}


#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.highScoreView.highScoreTableView) {
        return [self.highScoreList count];
    } else if (self.selectedWordList) {
        return [self.selectedWordList count];
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.highScoreView.highScoreTableView) {
        return @"High Scores";
    } else {
        if (self.selectedWordList != nil) {
            return [NSString stringWithFormat:@"Word List"];
        }
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *HighScoreCellIdentifier = @"UICellHighScoreItem";
    static NSString *WordCellIdentifier = @"UICellHighScoreWordItem";
	
    NSString *cellIdentifier;
    if (tableView == self.highScoreView.highScoreTableView) {
        cellIdentifier = HighScoreCellIdentifier;
    } else {
        cellIdentifier = WordCellIdentifier;
    }
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (UITableViewCell*)[nib objectAtIndex:0];
    }

    if (tableView == self.highScoreView.highScoreTableView) {
        UIHighScoreItemCell *highScoreCell = (UIHighScoreItemCell*)cell;
        NezAletterationSQLiteHighScoreItem *hsi = (NezAletterationSQLiteHighScoreItem*)[self.highScoreList objectAtIndex:indexPath.row];
        highScoreCell.nameLabel.text = [NSString stringWithFormat:@"%@", hsi.name];
        highScoreCell.scoreLabel.text = [NSString stringWithFormat:@"%d", hsi.score];
        highScoreCell.dateLabel.text = hsi.date;
    } else {
        UITableViewCell *wordCell = (UITableViewCell*)cell;
        if (self.selectedWordList) {
            NezSQLiteHighScoreWord *hsw = (NezSQLiteHighScoreWord*)[self.selectedWordList objectAtIndex:indexPath.row];
            wordCell.textLabel.text = hsw.word;
        }
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.highScoreView.highScoreTableView) {
        NezAletterationSQLiteHighScoreItem *hsi = (NezAletterationSQLiteHighScoreItem*)[self.highScoreList objectAtIndex:indexPath.row];
        if (hsi.wordList == nil) {
            if (![NezSQLiteHighScores getHighScoreWordListWithHighScoreItem:hsi]) {
                //error!!!
            }
        }
        self.selectedWordList = hsi.wordList;
        [self.highScoreView.wordListTableView reloadData];
		[self.highScoreView.wordListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)dealloc {
    self.highScoreList = nil;
    self.selectedWordList = nil;
    
	self.onCloseDelegate = nil;
	self.onCloseSelector = nil;
	[super dealloc];
}

@end
