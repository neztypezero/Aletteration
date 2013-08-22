//
//  AletterationGameController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-31.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGKSessionController.h"
#import "Structures.h"
#import <AVFoundation/AVFoundation.h>

#define IM_ALL_INPUT 0xFFFFFFFF
#define IM_NO_INPUT 0
#define IM_DRAG_LETTER 1
#define IM_DROP_LINE_1 (IM_DRAG_LETTER<<1)
#define IM_DROP_LINE_2 (IM_DRAG_LETTER<<2)
#define IM_DROP_LINE_3 (IM_DRAG_LETTER<<3)
#define IM_DROP_LINE_4 (IM_DRAG_LETTER<<4)
#define IM_DROP_LINE_5 (IM_DRAG_LETTER<<5)
#define IM_DROP_LINE_6 (IM_DRAG_LETTER<<6)

#define IM_DROP_LINE_ALL (IM_DROP_LINE_1|IM_DROP_LINE_2|IM_DROP_LINE_3|IM_DROP_LINE_4|IM_DROP_LINE_5|IM_DROP_LINE_6)

#define IM_SWIPE_LEFT  (IM_DRAG_LETTER<<7)
#define IM_SWIPE_RIGHT (IM_DRAG_LETTER<<8)

#define IM_DBLTAP_WORD1 (IM_DRAG_LETTER<<9)
#define IM_DBLTAP_WORD2 (IM_DBLTAP_WORD1<<1)
#define IM_DBLTAP_WORD3 (IM_DBLTAP_WORD1<<2)
#define IM_DBLTAP_WORD4 (IM_DBLTAP_WORD1<<3)
#define IM_DBLTAP_WORD5 (IM_DBLTAP_WORD1<<4)
#define IM_DBLTAP_WORD6 (IM_DBLTAP_WORD1<<5)

#define IM_DBLTAP_WORD_ALL (IM_DBLTAP_WORD1|IM_DBLTAP_WORD2|IM_DBLTAP_WORD3|IM_DBLTAP_WORD4|IM_DBLTAP_WORD5|IM_DBLTAP_WORD6)

#define IM_SELECT_WORD1 (IM_DBLTAP_WORD6<<1)
#define IM_SELECT_WORD2 (IM_DBLTAP_WORD6<<2)
#define IM_SELECT_WORD3 (IM_DBLTAP_WORD6<<3)
#define IM_SELECT_WORD4 (IM_DBLTAP_WORD6<<4)
#define IM_SELECT_WORD5 (IM_DBLTAP_WORD6<<5)
#define IM_SELECT_WORD6 (IM_DBLTAP_WORD6<<6)

#define IM_SELECT_WORD_ALL (IM_SELECT_WORD1|IM_SELECT_WORD2|IM_SELECT_WORD3|IM_SELECT_WORD4|IM_SELECT_WORD5|IM_SELECT_WORD6)

@class AletterationGameState, OpenGLES2Graphics, LetterBlock, DisplayLine, AnimatedWord, NezAnimation, AnimatedCamera, NezStrectableRectangle2D;

@interface AletterationGameController : AletterationGKSessionController<AVAudioPlayerDelegate,UIGestureRecognizerDelegate> {
	OpenGLES2Graphics *gameGraphics;
	AnimatedCamera *camera;
	
	BOOL animateStartingState;
	
	BOOL firstLoad;
	
	BOOL blockAddedTemporarily;
	NezAnimation *glowPulseAnimation;

	int removeLineIndex;
	BOOL removeWordAnimating;
	AnimatedWord *animatedWord;
	
	BOOL isFinished;
	int animatedWordCount;
	
	int touchesDown;
	LetterBlock *selectedBlock;
	LetterBlock *fingerBlock;
	DisplayLine *fingerBlockOverLine;

	UILongPressGestureRecognizer *selectionModeLongPress;

	UIPanGestureRecognizer *dragBoardHorizontal;
	int currentViewLocation;
	vec3 cameraEyeOnDrag;
	vec4 dragDownPoint;
	BOOL draggingBoard;
	
	BOOL inputEnabled;
	unsigned int inputMask;
}

@property (nonatomic, retain) NSMutableArray *automatedWordList;

+(mat4)getDefaultSelectionMatrix;

-(void)enableUserInteraction;
-(void)disableUserInteraction;
-(void)enableInput;
-(void)disableInput;

-(void)waitForNextTurn;
-(void)endTurn:(int)lineIndex;
-(void)cancelEndTurn;
-(void)waitForEndTurn;
-(void)receivedNextBlock;
-(void)updateLocalScoreDisplays;
-(void)doGameOver;
-(void)doLocalGameOver;

-(void)layoutStacksAnimationDidStop;

-(void)resetGame;

-(void)dragBoard:(UIPanGestureRecognizer*)sender;

-(BOOL)removeWordFromLine:(int)lineIndex Count:(int)wordCount;

-(void)enterSelectionMode:(UILongPressGestureRecognizer*)sender;
-(void)positionWordOutlineForLine:(DisplayLine*)line TapPoint:(CGPoint)point TappedBlock:(LetterBlock*)tappedBlock;
-(void)positionWordOutlineForLine:(DisplayLine*)line TapPoint:(CGPoint)point;

-(void)animateSelectedBlockToDefaultPositionWithSoundEffect:(NSUInteger)sound andDuration:(float)duration;
-(void)animateSelectedBlockWithMatrix:(mat4*)mat Duration:(float)duration soundEffect:(NSUInteger)sound;
-(void)animateSelectedBlockWithMatrix:(mat4*)mat Duration:(float)duration didStopDelegate:(id)delegate didStopSelector:(SEL)selector soundEffect:(NSUInteger)sound;

-(void)topEndTurn:(int)lineIndex withNoCheck:(BOOL)noCheck;
-(void)swipeAnimationDidStop;

-(void)addAutomatedWord:(AnimatedWord*)word LineIndex:(int)lineIndex;
-(void)startAnimateAutomate;

-(void)highlightLine:(DisplayLine*)line;
-(void)startRemoveWordAnimation:(DisplayLine*)line;
-(void)animateRemoveWordDidStopSetup;
	
-(void)slideCameraWordList;
-(void)slideCameraDefault;
-(void)slideCameraJunk;

-(void)slideCamera:(float)distance Duration:(float)duration;
-(float)swipeDistance;

@end
