//
//  AletterationSinglePlayerGameController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameController.h"
#import "AletterationSinglePlayerGameView.h"
#import "AletterationGameState.h"
#import "ToolboxView.h"
#import "OptionsController.h"
#import "AletterationPlayerInfoScrollView.h"
#import "AletterationPlayerInfoView.h"
#import "QuickRulesController.h"
#import "UIScrollViewLoopDelegate.h"
#import "DisplayLine.h"
#import "LetterBlock.h"
#import "ScoringController.h"
#import "AletterationPreferences.h"
#import "NezAnimation.h"
#import "NezAnimator.h"

//#define LETTER_ORDER_SET

#ifdef LETTER_ORDER_SET
static char *letterOrderArray = "lcgxqeckhbmabdehwzaoparlshowdtlimeuye";
int letterIndex = 0;
#endif

@interface AletterationSinglePlayerGameController (private)

-(AletterationPlayerInfoView*)addPlayerInfoView:(AletterationPlayerInfo*)pInfo withKey:(NSString*)key;

-(void)setSlideViewsAlpha:(float)alpha;
-(void)animateSlideViewsAlpha:(float)alpha;

-(void)animateToolbox:(BOOL)open;
-(void)animatePlayerInfo:(BOOL)open;

@end

@implementation AletterationSinglePlayerGameController

@synthesize toolboxView;
@synthesize playerInfoScrollView;
@synthesize playerInfoLooper;

#ifdef LETTER_ORDER_SET
-(void)waitForNextTurn {
	if (letterOrderArray[letterIndex] != '\0') {
		int index = 0;
		for (NSNumber *letterValue in gameState.letterList) {
			char letter = [letterValue charValue];
			if (letterOrderArray[letterIndex] == letter) {
				[gameState setSelectedBlockWithIndex:index];
				break;
			}
			index++;
		}
		letterIndex++;
	}
	[super waitForNextTurn];
}
#endif

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		playerInfoDic = [[NSMutableDictionary alloc] initWithCapacity:16];
		
		nextBGAnimation = nil;
	}
	return self;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	
	isAnimatingDragBox = NO;
	
	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	view.nextTurnButton.hidden = YES;
	view.nextTurnButton.enabled = NO;
	
	nextButtonAlpha = view.nextTurnButton.alpha;
	
	[playerInfoDic removeAllObjects];
	for (UIView *view in [self.playerInfoScrollView subviews]) {
		[view removeFromSuperview];
	}
	NSArray *nibToolbox = [[NSBundle mainBundle] loadNibNamed:@"ToolboxView" owner:self options:nil];
	ToolboxView *tbView = (ToolboxView*)[nibToolbox objectAtIndex:0];
	
	tbView.frame = CGRectMake(0, -tbView.frame.size.height, tbView.frame.size.width, tbView.frame.size.height);
	[self.view addSubview:tbView];
	
	tbView.exitButton.target = self;
	tbView.exitButton.action = @selector(exitButtonAction:);
	
	tbView.optionsButton.target = self;
	tbView.optionsButton.action = @selector(optionsButtonAction:);
	
	tbView.resumeButton.target = self;
	tbView.resumeButton.action = @selector(resumeUpInsideAction:);
	
	tbView.scoringButton.target = self;
	tbView.scoringButton.action = @selector(showScoringDialog:);
	
	tbView.quickRulesButton.target = self;
	tbView.quickRulesButton.action = @selector(showQuickRulesDialog:);

	self.toolboxView = tbView;
	
	NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AletterationPlayerInfoScrollView" owner:self options:nil];
	self.playerInfoScrollView = (AletterationPlayerInfoScrollView*)[nib objectAtIndex:0];
	
	CGRect frame = self.playerInfoScrollView.frame;
	frame.origin.y = self.view.frame.size.height;
	self.playerInfoScrollView.frame = frame;
	[self.view addSubview:self.playerInfoScrollView];
	
	UIScrollView *scrollView = self.playerInfoScrollView.scrollView;
	
	NSArray *playerInfoArray = [gameState.playerInfoList allValues];
	
	if ([playerInfoArray count] == 1) {
		AletterationPlayerInfo *pInfo = [playerInfoArray objectAtIndex:0];
		[self addPlayerInfoView:pInfo withKey:pInfo.ip];
	} else if ([playerInfoArray count] > 1) {
		AletterationPlayerInfo *firstPlayerInfo = [playerInfoArray objectAtIndex:0];
		AletterationPlayerInfo *lastPlayerInfo = [playerInfoArray objectAtIndex:[playerInfoArray count]-1];
		
		self.playerInfoLooper = [[UIScrollViewLoopDelegate alloc] init];
		self.playerInfoLooper.scrollView = scrollView;
		self.playerInfoLooper.leftCapView = [self addPlayerInfoView:lastPlayerInfo withKey:[NSString stringWithFormat:@"%@_cap", lastPlayerInfo.ip]];
		for (AletterationPlayerInfo *pInfo in playerInfoArray) {
			[self addPlayerInfoView:pInfo withKey:pInfo.ip];
		}
		self.playerInfoLooper.rightCapView = [self addPlayerInfoView:firstPlayerInfo withKey:[NSString stringWithFormat:@"%@_cap", firstPlayerInfo.ip]];
		
		scrollView.delegate = self.playerInfoLooper;
		
		AletterationPlayerInfoView *localPlayerInfoView = [playerInfoDic objectForKey:gameState.localPlayerInfo.ip];
		[scrollView scrollRectToVisible:localPlayerInfoView.frame animated:NO];
	}
	isPlayerInfoViewShowing = NO;
	isToolboxShowing = NO;
	shoudDragTheBoard = YES;

	[self setSlideViewsAlpha:0.0];
	[self animateSlideViewsAlpha:1.0];
	
	letterBlockLineIndex = -1;
	
	view.pauseMenuButton.alpha = 0.0;
	view.pauseMenuButton.hidden = NO;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
		animations:^{
			view.pauseMenuButton.alpha = 1.0;
		}
		completion:^(BOOL completed){}
	];
}

-(AletterationPlayerInfoView*)addPlayerInfoView:(AletterationPlayerInfo*)pInfo withKey:(NSString*)key {
	if ([playerInfoDic objectForKey:key] == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AletterationPlayerInfoView" owner:self options:nil];
		AletterationPlayerInfoView *infoView = (AletterationPlayerInfoView*)[nib objectAtIndex:0];
		
		infoView.portraitImageView.layer.borderColor = [UIColor blackColor].CGColor;
		infoView.portraitImageView.layer.borderWidth = 2.0;
		infoView.portraitImageView.layer.cornerRadius = 9;
		infoView.portraitImageView.clipsToBounds = YES;
		
		infoView.wordsAreaView.layer.borderColor = [UIColor blackColor].CGColor;
		infoView.wordsAreaView.layer.borderWidth = 2.0;
		infoView.wordsAreaView.layer.cornerRadius = 9;
		infoView.wordsAreaView.clipsToBounds = YES;
		infoView.wordsTableView.clipsToBounds = YES;
		
		infoView.playerInfo = pInfo;
		
		CGSize size = infoView.frame.size;
		infoView.frame = CGRectMake(size.width*[playerInfoDic count], 0, size.width, size.height);
		
		UIScrollView *scrollView = self.playerInfoScrollView.scrollView;
		
		[scrollView addSubview:infoView];
		[playerInfoDic setObject:infoView forKey:key];
		scrollView.contentSize = CGSizeMake(size.width*[playerInfoDic count], size.height);
		return infoView;
	}
	return nil;
}

-(void)setSlideViewsAlpha:(float)alpha {
	self.playerInfoScrollView.alpha = alpha;
	self.toolboxView.alpha = alpha;
}

-(void)animateSlideViewsAlpha:(float)alpha {
	[UIView animateWithDuration:0.25
		animations:^{
			[self setSlideViewsAlpha:alpha];
		}
		completion:^(BOOL completed){
		}
	];
}

-(void)resetGame {
	[self animateSlideViewsAlpha:0.0];
	[super resetGame];
}

-(void)doLocalGameOver {
    [gameState tryPlayEndMusic];
	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	[UIView animateWithDuration:0.25
		animations:^{
			view.pauseMenuButton.alpha = 0.0;
		}
		completion:^(BOOL completed){
			view.pauseMenuButton.hidden = YES;
			[super doLocalGameOver];
		}
	];
}

-(void)animateToolbox:(BOOL)open {
	CGSize size = self.toolboxView.frame.size;
	isAnimatingDragBox = YES;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
		animations:^{
			if (open) {
				self.toolboxView.frame = CGRectMake(0, 0, size.width, size.height);
				isToolboxShowing = YES;
			} else {
				self.toolboxView.frame = CGRectMake(0, -size.height, size.width, size.height);
				isToolboxShowing = NO;
			}
		}
		completion:^(BOOL completed) {
			isAnimatingDragBox = NO;
			[self animateToolboxDidFinish];
		}
	];
}

-(void)animateToolboxDidFinish {
	
}

-(void)animatePlayerInfo:(BOOL)open {
	CGSize viewSize = self.view.frame.size;
	CGSize size = self.playerInfoScrollView.frame.size;
	isAnimatingDragBox = YES;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
		animations:^{
			if (open) {
				self.playerInfoScrollView.frame = CGRectMake(0, viewSize.height-size.height, size.width, size.height);
				isPlayerInfoViewShowing = YES;
			} else {
				self.playerInfoScrollView.frame = CGRectMake(0, viewSize.height, size.width, size.height);
				isPlayerInfoViewShowing = NO;
			}
		}
		completion:^(BOOL completed) {
			isAnimatingDragBox = NO;
			[self animatePlayerInfoDidFinish];
		}
	];
}

-(void)animatePlayerInfoDidFinish {
	
}

-(void)letterAddedToLineIndex:(int)lineIndex {
	[super endTurn:lineIndex];
}

-(void)doNextTurn {
	[[AletterationGameState instance] playSound:[AletterationGameState instance].sounds->lockLetter];
	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	[UIView animateWithDuration:view.nextTurnButton.alpha/4.0
		animations:^{
			view.nextTurnButton.alpha = 0.0;
		}
		completion:^(BOOL completed) {
			view.nextTurnButton.hidden = YES;
			view.nextTurnButton.enabled = NO;
			if (letterBlockLineIndex != -1) {
				[self letterAddedToLineIndex:letterBlockLineIndex];
			}
		}
	];
}

-(void)endTurn:(int)lineIndex {
	letterBlockLineIndex = lineIndex;
	[gameState setColorsForAllLines];
	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	view.nextTurnButton.alpha = 0.0;
	view.nextTurnButton.hidden = NO;
	view.nextTurnButton.enabled = YES;
	[UIView animateWithDuration:0.25
		animations:^{
			view.nextTurnButton.alpha = nextButtonAlpha;
		}
		completion:^(BOOL completed) {
			[self enableUserInteraction];
		}
	];
}

-(void)cancelEndTurn {
	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	view.nextTurnButton.alpha = 0.0;
	view.nextTurnButton.hidden = YES;
	view.nextTurnButton.enabled = NO;
}

-(void)quitGame {
	NSString *title = @"Quit Game";
	NSString *message = @"Are you sure you want to quit this game? You will not be able to resume again later.";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Quit", nil];
	[alert show];
	[alert release];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *text = [alertView buttonTitleAtIndex:buttonIndex];
	if ([text compare:@"Quit"] == NSOrderedSame || [text compare:@"Quit Game"] == NSOrderedSame) {
		isPlayerInfoViewShowing = NO;
		isToolboxShowing = NO;
		[UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
						 animations:^{
							 float w = self.view.frame.size.width;
							 float h = self.view.frame.size.height;
							 float tbh = self.toolboxView.frame.size.height;
							 float pish = self.playerInfoScrollView.frame.size.height;
							 self.toolboxView.frame = CGRectMake(0, -tbh, w, tbh);
							 self.playerInfoScrollView.frame = CGRectMake(0, h, w, pish);
						 }
						 completion:^(BOOL completed){
						 }
		 ];
		AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
		view.nextTurnButton.enabled = NO;
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 view.nextTurnButton.alpha = 0.0;
						 }
						 completion:^(BOOL completed){
							 view.nextTurnButton.hidden = YES;
						 }
		 ];
		[self resetGame];
	}
}

-(IBAction)nextTurnDownAction:(id)sender {
	[self disableInput];
}

-(IBAction)nextTurnUpInsideAction:(id)sender {
	[self doNextTurn];
}

-(IBAction)nextTurnUpOutsideAction:(id)sender {
	[self enableInput];
}

-(void)exitButtonAction:(id)sender {
	[self quitGame];
}

-(void)optionsButtonAction:(id)sender {
	touchesDown = 0;
	shoudDragTheBoard = YES;
	[OptionsController showView:self onCloseSelector:@selector(optionsDialogDidClose:)];
}

-(IBAction)showPauseMenu:(id)sender {
	beforePauseInputMask = inputMask;
	inputMask = IM_NO_INPUT;
	[self animateToolbox:YES];
	[self animatePlayerInfo:YES];

	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 view.pauseMenuButton.alpha = 0.0;
					 }
					 completion:^(BOOL completed){
						 view.pauseMenuButton.hidden = YES;
					 }
	 ];
}

-(IBAction)resumeUpInsideAction:(id)sender {
	[self animateToolbox:NO];
	[self animatePlayerInfo:NO];

	AletterationSinglePlayerGameView *view = (AletterationSinglePlayerGameView*)self.view;
	view.pauseMenuButton.hidden = NO;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 view.pauseMenuButton.alpha = 1.0;
					 }
					 completion:^(BOOL completed){
						 inputMask = beforePauseInputMask;
					 }
	 ];
}

-(IBAction)showScoringDialog:(id)sender {
    [ScoringController showView:self];
}

-(IBAction)showQuickRulesDialog:(id)sender {
	[QuickRulesController showView:self onCloseSelector:nil onContinueSelector:nil];
}

-(void)optionsDialogDidClose:(NSNumber*)flags {
	[self updateLocalScoreDisplays];
}

-(void)updateScoreDisplaysForPlayerInfo:(AletterationPlayerInfo*)playerInfo {
	AletterationPlayerInfoView *playerInfoView = [playerInfoDic objectForKey:playerInfo.ip];
	playerInfoView.playerInfo = playerInfo;
	
	playerInfoView = [playerInfoDic objectForKey:[NSString stringWithFormat:@"%@_cap", playerInfo.ip]];
	if (playerInfoView != nil) {
		playerInfoView.playerInfo = playerInfo;
	}
}

-(void)updateLocalScoreDisplays {
	[self updateScoreDisplaysForPlayerInfo:gameState.localPlayerInfo];
}

-(void)dealloc {
	self.toolboxView = nil;
	self.playerInfoScrollView = nil;
	self.playerInfoLooper = nil;
	[playerInfoDic release];
	[super dealloc];
}

@end