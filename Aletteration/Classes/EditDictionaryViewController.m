//
//  EditDictionaryViewController.m
//  Aletteration
//
//  Created by David Nesbitt on 2013-01-11.
//
//

#import "EditDictionaryViewController.h"
#import "NezAletterationSQLiteDictionary.h"
#import "NezSQLite.h"

#define DICTIONARY_CURSOR_SIZE 40

int WordSelectCallback(void *arg, int nColumns, char **values,char **columnNames) {
	if (nColumns == 1 && values[0] != NULL) {
		NSMutableArray *wordList = (NSMutableArray*)arg;
		[wordList addObject:[NSString stringWithFormat:@"%s", values[0]]];
	}
	return 0;
}

@implementation WordSelectionCursor

+(id)cursorWithTableLetter:(char)tableLetter {
	return [[[WordSelectionCursor alloc] initWithTableLetter:tableLetter] autorelease];
}

-(id)initWithTableLetter:(char)tableLetter {
    self = [super init];
    if (self) {
		self.start = 0;
		self.tableLetter = tableLetter;
		self.total = [NezAletterationSQLiteDictionary getWordCountForTable:tableLetter];
		self.wordListP = [self getWordListForwardFromWord:@""];
		if (self.wordListP.count == DICTIONARY_CURSOR_SIZE) {
			self.wordListM = [self getWordListForwardFromWord:self.wordListP.lastObject];
			if (self.wordListM.count == DICTIONARY_CURSOR_SIZE) {
				self.wordListN = [self getWordListForwardFromWord:self.wordListM.lastObject];
			}
		}
	}
    return self;
}

-(NSArray*)getWordListForwardFromWord:(NSString*)fromWord {
	NSMutableArray *wordList = [NSMutableArray arrayWithCapacity:DICTIONARY_CURSOR_SIZE];
	[NezAletterationSQLiteDictionary getWordsForwardForTable:self.tableLetter FromWord:[fromWord UTF8String] Limit:DICTIONARY_CURSOR_SIZE Callback:WordSelectCallback CallbackArgument:(void *)wordList];
	return wordList;
}

-(NSArray*)getWordListBackwardFromWord:(NSString*)fromWord {
	NSMutableArray *wordList = [NSMutableArray arrayWithCapacity:DICTIONARY_CURSOR_SIZE];
	[NezAletterationSQLiteDictionary getWordsBackwardForTable:self.tableLetter FromWord:[fromWord UTF8String] Limit:DICTIONARY_CURSOR_SIZE Callback:WordSelectCallback CallbackArgument:(void *)wordList];
	return [[wordList reverseObjectEnumerator] allObjects];
}

-(NSString*)getWordForIndex:(int)index andTableView:(UITableView*)tableView {
	NSArray *indexPaths = [tableView indexPathsForVisibleRows];
	int middleIndex = indexPaths.count/2;
	NSIndexPath *middleIndexPath = [indexPaths objectAtIndex:middleIndex];
	for(;;) {
		if (_start > 0) {
			if (middleIndexPath.row <= _start+(DICTIONARY_CURSOR_SIZE/2)) {
				self.wordListN = self.wordListM;
				self.wordListM = self.wordListP;
				self.wordListP = [self getWordListBackwardFromWord:[self.wordListM objectAtIndex:0]];
				_start -= DICTIONARY_CURSOR_SIZE;
			} else {
				break;
			}
		} else {
			break;
		}
	}
	for(;;) {
		if (_start+_wordListP.count+_wordListM.count+_wordListN.count < _total) {
			if (middleIndexPath.row >= _start+_wordListP.count+_wordListM.count+(DICTIONARY_CURSOR_SIZE/2)) {
				self.wordListP = self.wordListM;
				self.wordListM = self.wordListN;
				self.wordListN = [self getWordListForwardFromWord:self.wordListM.lastObject];
				_start += DICTIONARY_CURSOR_SIZE;
			} else {
				break;
			}
		} else {
			break;
		}
	}
	if (index < _start+_wordListP.count) {
		return [_wordListP objectAtIndex:index-_start];
	} else if (index < _start+_wordListP.count+_wordListM.count) {
		return [_wordListM objectAtIndex:index-_start-_wordListP.count];
	} else if (index < _start+_wordListP.count+_wordListM.count+_wordListN.count) {
		return [_wordListN objectAtIndex:index-_start-_wordListP.count-_wordListM.count];
	}
	return @"Loading...";
}

@end

@interface EditDictionaryViewController ()

@end

@implementation EditDictionaryViewController

+(void)showView:(UIViewController*)parentViewController {
	NSString *nibName = @"EditDictionaryViewController";
	EditDictionaryViewController *controller = [[EditDictionaryViewController alloc] initWithNibName:nibName bundle:nil];
	
	controller.view.alpha = 0.0;
	[parentViewController.view addSubview:controller.view];
	
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 controller.view.alpha = 1.0;
					 }
					 completion:^(BOOL completed) {
					 }
	 ];
}

-(void)closeDialog:(id)sender {
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.view.alpha = 0.0;
					 }
					 completion:^(BOOL completed) {
						 [self.view removeFromSuperview];
						 [self release];
					 }
	 ];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.selectionCursor = [WordSelectionCursor cursorWithTableLetter:'a'];
	}
    return self;
}

#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectionCursor.total;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"UICellDictionaryWord";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	}
	cell.textLabel.text = [self.selectionCursor getWordForIndex:indexPath.row andTableView:tableView];
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(void)dealloc {
    self.wordListTableView = nil;

	[super dealloc];
}

@end
