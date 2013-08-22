//
//  AletterationResultsController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-09-16.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "AletterationGameState.h"
#import "AletterationPlayerInfo.h"
#import "AletterationResultsController.h"
#import "AletterationResultsView.h"
#import "UICALayerLabel.h"
#import "AletterationGameState.h"
#import "ScoreBoard.h"
#import "AletterationNetCmd.h"
#import "UICompletedWordTableViewCell.h"
#import "UIPlayerInfoButton.h"
#import "NezRectangle2D.h"
#import "NezSQLiteHighScores.h"

@implementation AletterationResultsController

@synthesize wordList;
@synthesize longWordsList;
@synthesize closeDialogDelegate;
@synthesize closeDialogSelector;

+(void)showModal:(UIViewController*)parentViewController withCloseDelegate:(id)delegate andCloseSelector:(SEL)selector {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSString *nibName = @"AletterationResultsController";
		AletterationResultsController *controller = [[AletterationResultsController alloc] initWithNibName:nibName bundle:nil];

		controller.closeDialogDelegate = delegate;
		controller.closeDialogSelector = selector;
        
        AletterationPlayerInfo *pInfo = [AletterationGameState instance].localPlayerInfo;
        [NezSQLiteHighScores insertHighScoreWithPlayerName:pInfo.name Score:pInfo.score WordList:pInfo.completedWordList];

		dispatch_async(dispatch_get_main_queue(), ^{
			[parentViewController presentModalViewController:controller animated:YES];
			[controller release];
		});
		
		[pool release];
	});
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		playerPortraitsDic = [[NSMutableDictionary alloc] initWithCapacity:32];
	}
    return self;
}

-(void)makeWordListWith:(AletterationPlayerInfo*)playerInfo {
	NSArray *sortedWordList = [playerInfo.completedWordList 
		sortedArrayWithOptions:NSSortStable 
		usingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSString *s1 = obj1;
			NSString *s2 = obj2;
			if (s1.length < s2.length) {
				return NSOrderedAscending;
			} else if (s1.length > s2.length) {
				return NSOrderedDescending;
			} else {
				return [s1 compare:s2];
			}
		}
	];
	NSRange shortRange = {0,0};
	for (NSString *s in sortedWordList) {
		if ([s length] >= 8) {
			break;
		}
		shortRange.length++;
	}
	self.wordList = [sortedWordList subarrayWithRange:shortRange];
	if (shortRange.length < [sortedWordList count]) {
		NSRange longRange = {shortRange.length,[sortedWordList count]-shortRange.length};
		self.longWordsList = [sortedWordList subarrayWithRange:longRange];
	} else {
		self.longWordsList = nil;
	}
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];

	gameState = [AletterationGameState instance];
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	
	AletterationResultsView *view = (AletterationResultsView*)self.view;
	
	float brightness = [gameState getBrightnessWithColor:gameState.letterColor];
	if (brightness > 0.5) {
		view.jArea.image = [UIImage imageNamed:@"j-black"];
		view.qArea.image = [UIImage imageNamed:@"q-black"];
		view.xArea.image = [UIImage imageNamed:@"x-black"];
		view.zArea.image = [UIImage imageNamed:@"z-black"];
	} else {
		view.jArea.image = [UIImage imageNamed:@"j-white"];
		view.qArea.image = [UIImage imageNamed:@"q-white"];
		view.xArea.image = [UIImage imageNamed:@"x-white"];
		view.zArea.image = [UIImage imageNamed:@"z-white"];
	}
	
	if ([playerInfo isLetterUsed:'j']) {
		view.jUsed.image = [UIImage imageNamed:@"checkmark"];
	} else {
		view.jUsed.image = [UIImage imageNamed:@"cross"];
	}
	if ([playerInfo isLetterUsed:'q']) {
		view.qUsed.image = [UIImage imageNamed:@"checkmark"];
	} else {
		view.qUsed.image = [UIImage imageNamed:@"cross"];
	}
	if ([playerInfo isLetterUsed:'x']) {
		view.xUsed.image = [UIImage imageNamed:@"checkmark"];
	} else {
		view.xUsed.image = [UIImage imageNamed:@"cross"];
	}
	if ([playerInfo isLetterUsed:'z']) {
		view.zUsed.image = [UIImage imageNamed:@"checkmark"];
	} else {
		view.zUsed.image = [UIImage imageNamed:@"cross"];
	}
	
	longestWordLengthInGame = [gameState getLongestWordLength];
	longestWordBonus = [gameState getLongestWordBonus];

	UIImage *maskingImage = [UIImage imageNamed:@"resultsMask"];
	CALayer *maskingLayer = [CALayer layer];
	
	maskingLayer.frame = self.view.bounds;
	[maskingLayer setContents:(id)[maskingImage CGImage]];
	[self.view.layer setMask:maskingLayer];
	
	[playerPortraitsDic removeAllObjects];

	view.portraitImageView.image = gameState.localPlayerInfo.portrait;
	view.portraitArea.clipsToBounds = YES;
	view.playerNameLabel.text = gameState.localPlayerInfo.name;
	
	NSArray *roundedCornerViewArray = [NSArray arrayWithObjects:view.backgroundArea, view.portraitArea, view.wordListArea, view.aletterationLinkBackground, nil];
	
	for (UIView *rView in roundedCornerViewArray) {
		rView.layer.borderColor = [UIColor blackColor].CGColor;
		rView.layer.borderWidth = 2.0;
		rView.layer.cornerRadius = 9;
	}
	color4uc blockColor = gameState.letterColor;
	float r = blockColor.r/255.0;
	float g = blockColor.g/255.0;
	float b = blockColor.b/255.0;
	
	UIColor *blockUIColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];

	NSArray *letterRoundedCornerViewArray = [NSArray arrayWithObjects:view.jArea, view.qArea, view.xArea, view.zArea, nil];

	for (UIView *rView in letterRoundedCornerViewArray) {
		rView.layer.borderColor = [UIColor blackColor].CGColor;
		rView.layer.borderWidth = 1.0;
		rView.layer.cornerRadius = 6;
		rView.backgroundColor = blockUIColor;
		rView.clipsToBounds = YES;
	}

	view.wordListTableView.layer.cornerRadius = 6;
	
	aletterationLinkTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkTap:)];
	[view.aletterationLinkLabel addGestureRecognizer:aletterationLinkTapRecognizer];
	
	[self makeWordListWith:gameState.localPlayerInfo];
}

-(void)linkTap:(UITapGestureRecognizer*)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.aletteration.com"]];
}

-(void)exitDialog:(id)sender {
	[self dismissModalViewController];
	if (self.closeDialogDelegate != nil && self.closeDialogSelector != nil) {
		[self.closeDialogDelegate performSelector:self.closeDialogSelector];
        [gameState tryPlayMusic];
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.longWordsList != nil) {
		return 2;
	}
	return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [NSString stringWithFormat:@"Word Count:%d", [self.wordList count]+[self.longWordsList count]];
		case 1:
			return [NSString stringWithFormat:@"Long Words:%d", [self.longWordsList count]];
		default:
			return @"";
	}
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *words;
	switch (section) {
		case 0:
			words = self.wordList;
			break;
		case 1:
			words = self.longWordsList;
			break;
		default:
			words = nil;
			break;
	}
	if (words != nil && [words count] > 0) {
		return [words count];
	}
	return 0;
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"UICellCompletedWord";
	
	UICompletedWordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (UICompletedWordTableViewCell*)[nib objectAtIndex:0];
	}
	NSArray *words;
	switch (indexPath.section) {
		case 0:
			words = self.wordList;
			break;
		case 1:
			words = self.longWordsList;
			break;
		default:
			words = nil;
			break;
	}
	if (words != nil && [words count] > 0) {
		NSString *word = [words objectAtIndex:indexPath.row];
		cell.wordLabel.text = word;
		if (longestWordLengthInGame == [word length] && longestWordBonus > 0) {
			cell.bonusLabel.text = [NSString stringWithFormat:@"+%d", longestWordBonus];
			cell.bonusLabel.hidden = NO;
			cell.bonusLengthImageView.hidden = NO;
		} else {
			cell.bonusLabel.text = @"";
			cell.bonusLabel.hidden = YES;
			cell.bonusLengthImageView.hidden = YES;
		}
	}
	return cell;
}

-(void)dealloc {
	[aletterationLinkTapRecognizer release];
	self.wordList = nil;
	self.longWordsList = nil;
	self.closeDialogDelegate = nil;
	self.closeDialogSelector = nil;
	[playerPortraitsDic release];
	gameState = nil;
	[super dealloc];
}

@end
