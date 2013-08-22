//
//  ScoreBoard.h
//  Aletteration
//
//  Created by David Nesbitt on 2/7/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"

@class NezVertexArray;
@class NezRectangle2D;
@class AletterationGameState;
@class NezAnimation;
@class NezStrectableRectangle2D;

#define TOTAL_SCORE_BALLS 60
#define LONG_WORD_HIGHLIGHT_COUNT 12

@interface ScoreBoard : NSObject {
	AletterationGameState *gameState;
	
	float scoreDistanceMoved;
	
	float scoreZ;
	
	NezRectangle2D *wordsBox;
	NezRectangle2D *wordsScore;
	NezRectangle2D *wordsScoreCounter;
	NezRectangle2D *extrasBox;
	NezRectangle2D *extrasScore;
	NezRectangle2D *extrasScoreCounter;
	NezRectangle2D *bonusBox;
	NezRectangle2D *bonusScore;
	NezRectangle2D *bonusScoreCounter;

	NezRectangle2D *totalScore;
	NezRectangle2D *totalScoreCounter;
	NezRectangle2D *totalScorePoints;

	NezRectangle2D *scoreBalls[TOTAL_SCORE_BALLS];
	NezStrectableRectangle2D *longWordHighLightList[LONG_WORD_HIGHLIGHT_COUNT];
	
	int usedScoreBalls;
	int scoreBallsMoving;
	int scoreBallsMovingElipse;
	
	int wordsTotal;
	int extrasTotal;
	int bonusTotal;
	
	NSMutableArray *bonusBallsArray;

	int scoreBallsWordsCircleFrom;
	int scoreBallsWordsCircleTo;
	NezAnimation *wordsCircleAni;

	NezAnimation *totalElispeAni;
	
	BOOL isElipseRotationComplete;
}

@property (nonatomic, retain) id animationStopDelegate;
@property (nonatomic, assign) SEL animationStopSelector;

@property (nonatomic, readonly) NezRectangle2D *totalScoreCounter;
@property (nonatomic, readonly) NezRectangle2D *totalScorePoints;

-(id)initWithVertexArray:(NezVertexArray**)vertexArray;

-(void)showScoreAnimation;

-(void)setScorePositionsWithZ:(float)scoreZ;
-(vec3)getScoreBoardPoint:(int)index;

-(vec3)getCameraEyePositionWithWordCount:(int)count DefaultZ:(float)defaultZ;

-(void)animateReset;
-(void)reset;


-(void)animateScoreBallMatrix1DidStop:(NezAnimation*)ani;
-(void)animateScoreBallMatrix2DidStop:(NezAnimation*)ani;
-(void)animateScoreBallMatrix3DidStop:(NezAnimation*)ani;
-(void)animateScoreBallMatrix4DidStop:(NezAnimation*)ani;

-(void)startAnimatingScoreBallsToTotalElipse;
-(void)startChangeScoreAnimation:(int)newScore;
-(void)addSpecialBonusAnimation;

@end
