//
//  AletterationSinglePlayerGameController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-01.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameController.h"

@class AletterationPlayerInfoScrollView;
@class UIScrollViewLoopDelegate;
@class AletterationPlayerInfo;
@class ToolboxView;
@class NezAnimation;

#define IM_PLAYER_TAB  (IM_DRAG_LETTER<<11)
#define IM_TOOLBOX_TAB (IM_DRAG_LETTER<<12)

#define TAB_CLOSED_HEIGHT 60
#define TAB_OPENED_SPACE 40

@interface AletterationSinglePlayerGameController : AletterationGameController {
	int _dragMode;
	
	int letterBlockLineIndex;
	
	NSMutableDictionary *playerInfoDic;
	BOOL isPlayerInfoViewShowing;
	BOOL isToolboxShowing;
	BOOL isAnimatingDragBox;
	
	BOOL shoudDragTheBoard;
	
	unsigned int beforePauseInputMask;

	float nextButtonAlpha;
	BOOL nextButtonNeedsAnimation;
	CGFloat nextButtonR, nextButtonG, nextButtonB;
	NezAnimation *nextBGAnimation;
}

@property (nonatomic, retain) ToolboxView *toolboxView;
@property (nonatomic, retain) AletterationPlayerInfoScrollView *playerInfoScrollView;
@property (nonatomic, retain) UIScrollViewLoopDelegate *playerInfoLooper;

-(IBAction)nextTurnDownAction:(id)sender;
-(IBAction)nextTurnUpInsideAction:(id)sender;
-(IBAction)nextTurnUpOutsideAction:(id)sender;
-(IBAction)showPauseMenu:(id)sender;
-(IBAction)resumeUpInsideAction:(id)sender;
-(IBAction)showScoringDialog:(id)sender;

-(void)letterAddedToLineIndex:(int)lineIndex;

-(void)optionsDialogDidClose:(NSNumber*)flags;

-(void)updateScoreDisplaysForPlayerInfo:(AletterationPlayerInfo*)playerInfo;
-(void)updateLocalScoreDisplays;

//-(void)startMoveTab:(UILongPressGestureRecognizer*)sender;

-(void)animatePlayerInfo:(BOOL)open;
-(void)animateToolboxDidFinish;
-(void)animatePlayerInfoDidFinish;

-(void)doNextTurn;

-(void)quitGame;
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
