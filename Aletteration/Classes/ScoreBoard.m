//
//  ScoreBoard.m
//  Aletteration
//
//  Created by David Nesbitt on 2/7/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "ScoreBoard.h"
#import "LetterBlock.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "OpenGLES2Graphics.h"
#import "AnimatedCamera.h"
#import "NezRectangle2D.h"
#import "AletterationGameState.h"
#import "DisplayLine.h"
#import "matrix.h"
#import "NezStrectableRectangle2D.h"

const float POINTS_COUNTER_SCALE = 1.1;
const float POINTS_X_SCALE = 3.0*POINTS_COUNTER_SCALE;
const float POINTS_Y_SCALE = POINTS_COUNTER_SCALE;
const float POINTS_Y_OFFSET = -0.10;
const float POINTS_COUNTER_LETTER_H_RATIO = 0.5;
const float POINTS_LETTER_H_RATIO = 0.5;

@implementation ScoreBoard

@synthesize animationStopDelegate;
@synthesize animationStopSelector;

@synthesize totalScoreCounter;
@synthesize totalScorePoints;

-(id)initWithVertexArray:(NezVertexArray**)vertexArrayArray {
	if ((self = [super init])) {
		isElipseRotationComplete = NO;
		
		gameState = [AletterationGameState instance];
		
		bonusBallsArray = [[NSMutableArray alloc] initWithCapacity:5];

		color4uc c = gameState.letterColor;
		
		mat4 mat = IDENTITY_MATRIX;
		
		vec4 wordsBoxUV         =  {4.0/8.0, 0.0/8.0, 0.0/8.0, 1.0/8.0};
		vec4 extrasBoxUV        =  {4.0/8.0, 1.0/8.0, 0.0/8.0, 2.0/8.0};
		vec4 bonusBoxUV         =  {4.0/8.0, 2.0/8.0, 0.0/8.0, 3.0/8.0};
		vec4 totalScorePointsUV =  {4.0/8.0, 3.0/8.0, 0.0/8.0, 4.0/8.0};
		
		vec4 uv2 = {8.0/8.0, 0.0/8.0, 5.0/8.0, 3.0/8.0};
		vec4 uv3 = [gameState getTextureCoordinatesForNumber:0];
		vec4 uvT = {8.0/8.0, 3.0/8.0, 5.0/8.0, 4.0/8.0};
		
		mat.w.x = -10000;
		
		int n = TOTAL_SCORE_BALLS/2;
		for (int i=0; i<n; i++) {
			scoreBalls[i] = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[3] modelMatrix:mat color:c];
			[scoreBalls[i] setUV:uv2];
			[scoreBalls[i] setMix:0.0];
		}
		for (int i=n; i<TOTAL_SCORE_BALLS; i++) {
			scoreBalls[i] = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[4] modelMatrix:mat color:c];
			[scoreBalls[i] setUV:uv2];
			[scoreBalls[i] setMix:0.0];
		}
		
		mat.x.x = 6.0;
		mat.y.y = 2.0;
		totalScore = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[2] modelMatrix:mat color:c];
		
		mat.x.x = POINTS_COUNTER_SCALE;
		mat.y.y = POINTS_COUNTER_SCALE;
		totalScoreCounter = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[0] modelMatrix:mat color:c];
		
		mat.x.x = POINTS_X_SCALE;
		mat.y.y = POINTS_Y_SCALE;
		totalScorePoints = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[1] modelMatrix:mat color:c];
		
		mat.x.x = 1.5;
		mat.y.y = 1.5;
		wordsScore = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[2] modelMatrix:mat color:c];
		extrasScore = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[2] modelMatrix:mat color:c];
		bonusScore = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[2] modelMatrix:mat color:c];
		
		mat.x.x = 0.75;
		mat.y.y = 0.75;
		wordsScoreCounter = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[0] modelMatrix:mat color:c];
		extrasScoreCounter = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[0] modelMatrix:mat color:c];
		bonusScoreCounter = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[0] modelMatrix:mat color:c];
		
		mat.x.x = 4.0;
		mat.y.y = 1.0;
		wordsBox = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[1] modelMatrix:mat color:c];
		extrasBox = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[1] modelMatrix:mat color:c];
		bonusBox = [[NezRectangle2D alloc] initWithVertexArray:vertexArrayArray[1] modelMatrix:mat color:c];
		
		[wordsScore setUV:uv2];
		[extrasScore setUV:uv2];
		[bonusScore setUV:uv2];
		
		[wordsBox setUV:wordsBoxUV];
		[extrasBox setUV:extrasBoxUV];
		[bonusBox setUV:bonusBoxUV];
		[totalScorePoints setUV:totalScorePointsUV];
		
		[totalScore setUV:uvT];

		[wordsScoreCounter setUV:uv3];
		[extrasScoreCounter setUV:uv3];
		[bonusScoreCounter setUV:uv3];
		[totalScoreCounter setUV:uv3];
		
		[wordsBox setMix:0.0];
		[extrasBox setMix:0.0];
		[bonusBox setMix:0.0];
		[wordsScore setMix:0.0];
		[extrasScore setMix:0.0];
		[bonusScore setMix:0.0];
		[wordsScoreCounter setMix:0.0];
		[extrasScoreCounter setMix:0.0];
		[bonusScoreCounter setMix:0.0];
		[totalScoreCounter setMix:0.0];
		[totalScorePoints setMix:0.0];
		
		usedScoreBalls = 0;
		scoreBallsMoving = 0;
		scoreBallsMovingElipse = 0;
		totalElispeAni = nil;
		
		wordsTotal = 0;
		extrasTotal = 0;
		bonusTotal = 0;

		vec3 offscreenPos = {-10000, 0, 0};
		for (int i=0; i<LONG_WORD_HIGHLIGHT_COUNT; i++) {
			longWordHighLightList[i] = [[NezStrectableRectangle2D alloc] initWithVertexArray:vertexArrayArray[5]];
			[longWordHighLightList[i] setBoxWithMidPoint:&offscreenPos];
			[longWordHighLightList[i] setMix:0.0];
		}
}
	return self;
}

-(vec3)getScoreBoardPoint:(int)index {
	float blockLength = gameState.blockLength;
	NezRectangle2D *r = gameState.displayLines[0];
	vec3 midPoint = {
		r.maxX,
		r.minY+r.size.h/2.0,
		(r.minZ+r.maxZ)/2.0
	};
	midPoint.x += blockLength;
	midPoint.y -= index*(blockLength*1.05);
	
	return midPoint;
}

-(void)setScorePositionsWithZ:(float)z {
	OpenGLES2Graphics *graphics = [OpenGLES2Graphics instance];
	float screenWidth = graphics.screenWidth;
	float screenHeight = graphics.screenHeight;
	
	scoreZ = z;
	
	vec4 w = [graphics getWorldPointWithPixelX:screenWidth*0.785 PixelY:screenHeight*0.12 WorldZ:scoreZ];
	
	NezRectangle2D *boxArray[][3] = {
		{ wordsBox, wordsScore, wordsScoreCounter },
		{ extrasBox, extrasScore, extrasScoreCounter },
		{ bonusBox, bonusScore, bonusScoreCounter },
	};
	
	for (int i=0; i<3; i++) {
		boxArray[i][0].modelMatrix->w = w;
		boxArray[i][1].modelMatrix->w = w;
		boxArray[i][1].modelMatrix->w.x += boxArray[i][0].size.w*0.485;
		boxArray[i][1].modelMatrix->w.y -= boxArray[i][0].size.h*0.76;
		boxArray[i][2].modelMatrix->w = boxArray[i][1].modelMatrix->w;
		
		w.y -= boxArray[i][0].size.h*2.0;
		
		for (int j=0; j<3; j++) {
			[boxArray[i][j] setBoundingPoints];
		}
	}	
	
	[totalScore setBoundingPoints];
	[totalScoreCounter setBoundingPoints];
	[totalScorePoints setBoundingPoints];

	totalScore.modelMatrix->w = [graphics getWorldPointWithPixelX:screenWidth*0.70 PixelY:screenHeight*0.85 WorldZ:scoreZ];
	totalScoreCounter.modelMatrix->w = totalScore.modelMatrix->w;
	totalScoreCounter.modelMatrix->w.x -= ((totalScorePoints.size.w*POINTS_LETTER_H_RATIO)*0.55)+(totalScoreCounter.size.w*POINTS_COUNTER_LETTER_H_RATIO);
	totalScorePoints.modelMatrix->w = totalScore.modelMatrix->w;
	totalScorePoints.modelMatrix->w.x += ((totalScoreCounter.size.w*POINTS_LETTER_H_RATIO)*1.55);
	totalScorePoints.modelMatrix->w.y += (totalScorePoints.size.h*POINTS_Y_OFFSET);
	
	[totalScore setBoundingPoints];
	[totalScoreCounter setBoundingPoints];
	[totalScorePoints setBoundingPoints];
}

-(vec3)getCameraEyePositionWithWordCount:(int)count DefaultZ:(float)defaultZ {
	vec3 eye = {
		gameState.screenWidthAtZero, 0.0, defaultZ, 
	};
	if (count > 0) {
		count--;
	}
	float halfBlockLength = gameState.blockLength/2.0;
	vec3 bottomPoint = [self getScoreBoardPoint:count];
	float minY = bottomPoint.y-halfBlockLength;
	vec3 topPoint = [self getScoreBoardPoint:0];
	float maxY = topPoint.y+halfBlockLength;
	float hh = gameState.screenHalfHeightAtZero;
	float yOffset = (hh-maxY);
	float y = minY-yOffset;
	if (y < -hh) {
		float extraSpaceModifier = 1.15;
		float dy = ((y + hh)/2.0);
		float dx = fabsf(dy)*(3.0/2.0)*extraSpaceModifier;
		
		eye.x += dx;
		eye.y += dy;
		eye.z += sqrtf((dx*dx)+(dy*dy));
	}
	return eye;
}

-(float)addScoreBallAnimations:(mat4*)mat Duration:(float)duration ScoreBall:(NezRectangle2D*)scoreBall Delay:(float)delay DidFinishSelector:(SEL)didFinish Fade:(BOOL)needToFadeIn {
	NezAnimation *ani;
	
	float extraWait = 0.0;
	if (needToFadeIn) {
		ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:duration EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
		ani->updateObject = scoreBall;
		ani->delay = delay;
		[[NezAnimator instance] addAnimation:ani];
		extraWait = duration;
	}
	
	ani = [[NezAnimation alloc] initFloatWithFromData:1.0 ToData:0.15 Duration:duration EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
	ani->updateObject = scoreBall;
	ani->delay = delay+extraWait;
	[[NezAnimator instance] addAnimation:ani];
	
	ani = [[NezAnimation alloc] initMat4WithFromData:*scoreBall.modelMatrix ToData:*mat Duration:duration EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateObjectMatrix:) DidStopSelector:didFinish];
	ani->updateObject = scoreBall;
	ani->delay = delay+extraWait;
	[[NezAnimator instance] addAnimation:ani];
	
	return delay+0.15;
}

-(float)addScoreBallAnimations:(mat4*)mat Index:(int)i Delay:(float)delay DidFinishSelector:(SEL)didFinish {
	NezRectangle2D *scoreBall = scoreBalls[i];
	return [self addScoreBallAnimations:mat Duration:0.5 ScoreBall:scoreBall Delay:delay DidFinishSelector:didFinish Fade:YES];
}

-(void)fadeInScoreBox:(NezRectangle2D*)box Text:(NezRectangle2D*)text {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
	ani->updateObject = box;
	[[NezAnimator instance] addAnimation:ani];
	
	ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:1.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
	ani->updateObject = text;
	[[NezAnimator instance] addAnimation:ani];

	[gameState playSound:gameState.sounds->scoreFadeIn AfterDelay:0.15];
}

-(void)showScoreAnimation {
	AnimatedCamera *cam = [OpenGLES2Graphics instance].camera;
	[self setScorePositionsWithZ:[cam getEye].z-8.0];

	color4uc c = gameState.letterColor;
	[totalScore setColor:c andMix:0.0];
	[wordsScore setColor:c andMix:0.0];
	[extrasScore setColor:c andMix:0.0];
	[bonusScore setColor:c andMix:0.0];

	[self fadeInScoreBox:wordsBox Text:wordsScore];
	
	float delay = 0;
	
	mat4 *mat = wordsScore.modelMatrix;
	
	usedScoreBalls = [gameState.completedWordBlockList count];
	for (int i=0; i<usedScoreBalls; i++) {
		vec3 point = [self getScoreBoardPoint:i];
		scoreBalls[i].modelMatrix->w.x = point.x;
		scoreBalls[i].modelMatrix->w.y = point.y;
		scoreBalls[i].modelMatrix->w.z = point.z;
		
		delay = [self addScoreBallAnimations:mat Index:i Delay:delay DidFinishSelector:@selector(animateScoreBallMatrix1DidStop:)];
	}
	scoreBallsMoving = usedScoreBalls;
	wordsTotal = usedScoreBalls;
	
	if (usedScoreBalls > 0) {
		if (totalElispeAni != nil) {
			[[NezAnimator instance] removeAnimation:totalElispeAni];
			[totalElispeAni release];
			totalElispeAni = nil;
		}
		totalElispeAni = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:2.0*NEZ_MATH_PI Duration:10.0 EasingFunction:&easeLinear CallbackObject:self UpdateSelector:@selector(animateElipse:) DidStopSelector:@selector(animateRelease:)];
		totalElispeAni->loop = LOOP_FORWARD;
		totalElispeAni->updateObject = totalScore;
		[[NezAnimator instance] addAnimation:totalElispeAni];
	} else {
		[self animateScoreBallMatrix1DidStop:nil];
	}
}

-(void)updateCounter:(NezRectangle2D*)counter UV:(vec4)uv {
	[counter setUV:uv];
	[counter setMix:1.0];
	[gameState playSound:gameState.sounds->scoreCounter];
}

-(void)animateElipse:(NezAnimation*)ani {
	NezRectangle2D *elipse = ani->updateObject;
	
	float t = ani->newData[0];
	float cx = elipse.modelMatrix->w.x;
	float cy = elipse.modelMatrix->w.y;
	
	float dt = ani->toData[0]/scoreBallsMovingElipse;
	
	float radiusW = elipse.size.w*0.45;
	float radiusH = elipse.size.h*0.42;
	float z = elipse.modelMatrix->w.z;
	float scale = elipse.modelMatrix->x.x/6.0;
	float ballScale = 0.25*scale;
	
	BOOL someFar = NO;
	
	for (int i=0; i<scoreBallsMovingElipse; i++) {
		float angle = t-i*dt;
		float x = cx + radiusW*cosf(angle);
		float y = cy + radiusH*sinf(angle);
		
		float dx = x-scoreBalls[i].modelMatrix->w.x;
		float dy = y-scoreBalls[i].modelMatrix->w.y;
		if (isElipseRotationComplete == NO) {
			float distance = sqrtf(dx*dx+dy*dy);
			if (distance > 0.25) {
				float ratio = 0.25/distance;
				dx *= ratio;
				dy *= ratio;
				someFar = YES;
			}
		}
		scoreBalls[i].modelMatrix->x.x = ballScale;
		scoreBalls[i].modelMatrix->y.y = ballScale;
		scoreBalls[i].modelMatrix->w.x += dx;
		scoreBalls[i].modelMatrix->w.y += dy;
		scoreBalls[i].modelMatrix->w.z = z;
	}
	
	if (someFar == NO && usedScoreBalls == scoreBallsMovingElipse) {
		isElipseRotationComplete = YES;
	}
}

-(void)animateRelease:(NezAnimation*)ani {
	[ani release];
}

-(void)animateBoxFade:(NezAnimation*)ani {
	[ani->updateObject setMix:ani->newData[0]];
}

-(void)animateObjectMatrix:(NezAnimation*)ani {
	NezRectangle2D *object = ani->updateObject;
	mat4 *mat = (mat4*)ani->newData;
	object.modelMatrix = mat;
	[object setBoundingPoints];
}

-(void)animateTotalScoreMatrix:(NezAnimation*)ani {
	mat4 *mat = (mat4*)ani->newData;
	totalScore.modelMatrix = mat;
	[totalScore setBoundingPoints];
	
	if (totalElispeAni != nil) {
		[self animateElipse:totalElispeAni];
	}
	
	float scale = totalScore.modelMatrix->x.x/6.0;

	totalScoreCounter.modelMatrix->x.x = POINTS_COUNTER_SCALE*scale;
	totalScoreCounter.modelMatrix->y.y = POINTS_COUNTER_SCALE*scale;
	[totalScoreCounter setBoundingPoints];
	
	totalScorePoints.modelMatrix->x.x = POINTS_X_SCALE*scale;
	totalScorePoints.modelMatrix->y.y = POINTS_Y_SCALE*scale;
	[totalScorePoints setBoundingPoints];
	
	totalScoreCounter.modelMatrix->w = totalScore.modelMatrix->w;
	totalScoreCounter.modelMatrix->w.x -= ((totalScorePoints.size.w*POINTS_LETTER_H_RATIO)*0.55)+(totalScoreCounter.size.w*POINTS_COUNTER_LETTER_H_RATIO);
	totalScorePoints.modelMatrix->w = totalScore.modelMatrix->w;
	totalScorePoints.modelMatrix->w.x += ((totalScoreCounter.size.w*POINTS_LETTER_H_RATIO)*1.55);
	totalScorePoints.modelMatrix->w.y += (totalScorePoints.size.h*POINTS_Y_OFFSET);
}

-(void)animateScoreBallMatrix1DidStop:(NezAnimation*)ani {
	if (scoreBallsMoving > 0) {
		scoreBallsMoving--;
	}
	if (ani != nil) {
		NezRectangle2D *scoreBall = ani->updateObject;
		[scoreBall setMix:0.0];
		[ani release];
	}
	
	vec4 uv3 = [gameState getTextureCoordinatesForNumber:wordsTotal-scoreBallsMoving];
	[self updateCounter:wordsScoreCounter UV:uv3];
	
	if (scoreBallsMoving == 0) {
		[self fadeInScoreBox:extrasBox Text:extrasScore];
		
		mat4 *mat = extrasScore.modelMatrix;
		
		float delay = 0.5;
		int i = usedScoreBalls;
		for (NSArray *wordArray in gameState.completedWordBlockList) {
			if ([wordArray count] > 4) {
				NSRange r = { 4, [wordArray count]-4 };
				for (LetterBlock *lb in [wordArray subarrayWithRange:r]) {
					scoreBalls[i].modelMatrix->w = lb.modelMatrix->w;
					delay = [self addScoreBallAnimations:mat Index:i Delay:delay DidFinishSelector:@selector(animateScoreBallMatrix2DidStop:)];
					i++;
					scoreBallsMoving++;
				}
			}
		}
		extrasTotal = scoreBallsMoving;
		
		usedScoreBalls = i;
		
		if (extrasTotal == 0) {
			[self animateScoreBallMatrix2DidStop:nil];
		}
	}
}

-(void)animateScoreBallMatrix2DidStop:(NezAnimation*)ani {
	if (scoreBallsMoving > 0) {
		scoreBallsMoving--;
	}
	if (ani != nil) {
		NezRectangle2D *scoreBall = ani->updateObject;
		[scoreBall setMix:0.0];
		[ani release];
	}
	
	vec4 uv3 = [gameState getTextureCoordinatesForNumber:extrasTotal-scoreBallsMoving];
	[self updateCounter:extrasScoreCounter UV:uv3];
	
	if (scoreBallsMoving == 0) {
		[self fadeInScoreBox:bonusBox Text:bonusScore];

		mat4 *mat = bonusScore.modelMatrix;
		
		[bonusBallsArray removeAllObjects];
		
		float delay = 0.5;
		int i = usedScoreBalls;
		for (NSArray *wordArray in gameState.completedWordBlockList) {
			for (LetterBlock *lb in wordArray) {
				char letter = lb.letter;
				if (letter == 'j' || letter == 'q' || letter == 'x' || letter == 'z') {
					[bonusBallsArray addObject:scoreBalls[i]];
					scoreBalls[i].modelMatrix->w = lb.modelMatrix->w;
					i++;
				}
			}
		}
		if ([bonusBallsArray count] == 4) {
			[bonusBallsArray addObject:scoreBalls[i++]];
			[self addSpecialBonusAnimation];
			bonusTotal = 5;
		} else {
			for (NezRectangle2D *rect in bonusBallsArray) {
				delay = [self addScoreBallAnimations:mat Duration:0.5 ScoreBall:rect Delay:delay DidFinishSelector:@selector(animateScoreBallMatrix3DidStop:) Fade:YES];
				scoreBallsMoving++;
			}
			bonusTotal = scoreBallsMoving;
		}
		usedScoreBalls = i;
		
		if (bonusTotal == 0) {
			[self animateScoreBallMatrix3DidStop:nil];
		}
	}
}

-(void)addSpecialBonusAnimation {
	NezAnimation *ani;
	
	float delay = 0.5;
	
	NezRectangle2D *sb = [bonusBallsArray objectAtIndex:0];

	AnimatedCamera *cam = [OpenGLES2Graphics instance].camera;
	mat4 mat = *sb.modelMatrix;
	vec3 target = [cam getTarget];
	mat.w.x = target.x;
	mat.w.y = target.y;
	mat.w.z *= 2.0;
	
	NezRectangle2D *bonusScoreBall = [bonusBallsArray objectAtIndex:4];
	bonusScoreBall.modelMatrix = &mat;
	
	NSRange firstFour = {0, 4};
	for (NezRectangle2D *scoreBall in [bonusBallsArray subarrayWithRange:firstFour]) {
		ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.25 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
		ani->updateObject = scoreBall;
		ani->delay = delay;
		[[NezAnimator instance] addAnimation:ani];
		
		ani = [[NezAnimation alloc] initMat4WithFromData:*scoreBall.modelMatrix ToData:mat Duration:0.25 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateObjectMatrix:) DidStopSelector:@selector(animateSpecialBonusAnimationDidStop:)];
		ani->updateObject = scoreBall;
		ani->delay = delay+0.25;
		[[NezAnimator instance] addAnimation:ani];
	}
	scoreBallsMoving = 4;
}

-(void)animateSpecialBonusAnimationDidStop:(NezAnimation*)ani {
	[ani release];

	if (scoreBallsMoving > 0) {
		scoreBallsMoving--;
	}

	if (scoreBallsMoving == 0) {
		NezRectangle2D *bonusScoreBall = [bonusBallsArray objectAtIndex:4];

		ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
		ani->updateObject = bonusScoreBall;
		[[NezAnimator instance] addAnimation:ani];
		
		float s = bonusScoreBall.size.w*0.6;
		
		NSRange firstFour = {0, 4};
		vec2 offsetArray[4] = {
			{-s, -s},
			{ s, -s},
			{ s,  s},
			{-s,  s},
		};
		int index = 0;
		for (NezRectangle2D *scoreBall in [bonusBallsArray subarrayWithRange:firstFour]) {
			mat4 mat = *bonusScoreBall.modelMatrix;
			mat.w.x += offsetArray[index].x;
			mat.w.y += offsetArray[index++].y;
			ani = [[NezAnimation alloc] initMat4WithFromData:*scoreBall.modelMatrix ToData:mat Duration:0.25 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateObjectMatrix:) DidStopSelector:@selector(animateRelease:)];
			ani->updateObject = scoreBall;
			[[NezAnimator instance] addAnimation:ani];
		}
		
		mat4 *mat = bonusScore.modelMatrix;
		float delay = 0.5;
		for (NezRectangle2D *scoreBall in bonusBallsArray) {
			delay = [self addScoreBallAnimations:mat Duration:0.25 ScoreBall:scoreBall Delay:delay DidFinishSelector:@selector(animateScoreBallMatrix3DidStop:) Fade:NO];
		}
		scoreBallsMoving = 5;
	}
}

-(void)animateScoreBallMatrix3DidStop:(NezAnimation*)ani {
	if (scoreBallsMoving > 0) {
		scoreBallsMoving--;
	}
	if (ani != nil) {
		NezRectangle2D *scoreBall = ani->updateObject;
		[scoreBall setMix:0.0];
		[ani release];
	}	

	vec4 uv3 = [gameState getTextureCoordinatesForNumber:bonusTotal-scoreBallsMoving];
	[self updateCounter:bonusScoreCounter UV:uv3];
	
	if (scoreBallsMoving == 0) {
		int wordIndex = 0;
		int points = [gameState getLongestWordBonus];
		if (points > 0) {
			int longestWord = [gameState getLongestWordLength];
			mat4 *mat = bonusScore.modelMatrix;
			for (NSArray *wordArray in gameState.completedWordBlockList) {
				if ([wordArray count] == longestWord && [wordArray count] >= 8) {
					LetterBlock *lb = [wordArray objectAtIndex:longestWord-1];
					float w = gameState.getBlockLength*longestWord;
					[longWordHighLightList[wordIndex] setRectWidth:w andHeight:gameState.getBlockLength];
					[longWordHighLightList[wordIndex] setMix:0.0];
					longWordHighLightList[wordIndex].modelMatrix->w.x = lb.modelMatrix->w.x-w/2.0+gameState.getBlockLength/2.0;
					longWordHighLightList[wordIndex].modelMatrix->w.y = lb.modelMatrix->w.y;
					longWordHighLightList[wordIndex].modelMatrix->w.z = lb.modelMatrix->w.z;
					
					ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
					ani->updateObject = longWordHighLightList[wordIndex];
					[[NezAnimator instance] addAnimation:ani];
					
					float delay = 0.5;
					for (int i=usedScoreBalls; i<usedScoreBalls+points; i++) {
						scoreBalls[i].modelMatrix->w = lb.modelMatrix->w;
						delay = [self addScoreBallAnimations:mat Index:i Delay:delay DidFinishSelector:@selector(animateScoreBallMatrixLongWordBonusDidStop:)];
					}
					scoreBallsMoving += points;
					usedScoreBalls += points;
					bonusTotal += points;
					
					ani = [[NezAnimation alloc] initFloatWithFromData:1.0 ToData:0.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
					ani->updateObject = longWordHighLightList[wordIndex];
					ani->delay = 1.5;
					[[NezAnimator instance] addAnimation:ani];
					
					wordIndex++;
				}
			}
		}
		//NSLog(@"wordIndex:%d", wordIndex);
		if (wordIndex == 0) {
			[self startAnimatingScoreBallsToTotalElipse];
		}
	}
}

-(void)animateScoreBallMatrixLongWordBonusDidStop:(NezAnimation*)ani {
	if (scoreBallsMoving > 0) {
		scoreBallsMoving--;
	}
	if (ani != nil) {
		NezRectangle2D *scoreBall = ani->updateObject;
		[scoreBall setMix:0.0];
		[ani release];
	}	
	
	vec4 uv3 = [gameState getTextureCoordinatesForNumber:bonusTotal-scoreBallsMoving];
	[self updateCounter:bonusScoreCounter UV:uv3];

	if (scoreBallsMoving == 0) {
		[self startAnimatingScoreBallsToTotalElipse];
	}
}

-(void)startAnimatingScoreBallsToTotalElipse {
	//NSLog(@"startAnimatingScoreBallsToTotalElipse");
	mat4 mat = IDENTITY_MATRIX;
	mat.w = totalScore.modelMatrix->w;
	mat.x.x = 0.25;
	mat.y.y = 0.25;
	
	for (int i=0; i<usedScoreBalls; i++) {
		[scoreBalls[i] setMix:0.75];
		
		NezAnimation *ani = [[NezAnimation alloc] initMat4WithFromData:*scoreBalls[i].modelMatrix ToData:mat Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateObjectMatrix:) DidStopSelector:@selector(animateScoreBallMatrix4DidStop:)];
		ani->updateObject = scoreBalls[i];
		[[NezAnimator instance] addAnimation:ani];
	}
	scoreBallsMoving = usedScoreBalls;
	
	if (scoreBallsMoving == 0) {
		[self animateScoreBallMatrix4DidStop:nil];
	}
}

-(void)animateScoreBallMatrix4DidStop:(NezAnimation*)ani {
	if (ani != nil) {
		[ani release];
	}
	if (scoreBallsMoving > 0) {
		scoreBallsMoving--;
	}
	if (scoreBallsMoving == 0) {
		scoreBallsMovingElipse = usedScoreBalls;
		
		ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
		ani->updateObject = totalScore;
		[[NezAnimator instance] addAnimation:ani];
		
		[totalScoreCounter setUV:[gameState getTextureCoordinatesForNumber:usedScoreBalls]];
		[self fadeInScoreBox:totalScoreCounter Text:totalScorePoints];
		
		OpenGLES2Graphics *graphics = [OpenGLES2Graphics instance];
		
		float screenWidth = graphics.screenWidth;
		float screenHeight = graphics.screenHeight;
		
		mat4 mat = *totalScore.modelMatrix;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			mat.x.x *= 0.4;
			mat.y.y *= 0.4;
			mat.w = [graphics getWorldPointWithPixelX:screenWidth*0.5 PixelY:screenHeight*0.075 WorldZ:scoreZ];
		} else {
			mat.x.x *= 0.5;
			mat.y.y *= 0.5;
			mat.w = [graphics getWorldPointWithPixelX:screenWidth*0.5 PixelY:screenHeight*0.064 WorldZ:scoreZ];
		}
		ani = [[NezAnimation alloc] initMat4WithFromData:*totalScore.modelMatrix ToData:mat Duration:1.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateTotalScoreMatrix:) DidStopSelector:@selector(animateTotalDidFinish:)];
		ani->delay = 0.75;
		ani->updateObject = totalScore;
		[[NezAnimator instance] addAnimation:ani];
	}
}

-(void)animateTotalDidFinish:(NezAnimation*)ani {
	[ani release];
	if (self.animationStopDelegate != nil && self.animationStopSelector != nil) {
		[self.animationStopDelegate performSelector:self.animationStopSelector];
	}
}

-(void)startChangeScoreAnimation:(int)newScore {
	NezAnimation *ani;
	for (int i=0; i<usedScoreBalls; i++) {
		ani = [[NezAnimation alloc] initFloatWithFromData:1.0 ToData:0.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
		ani->updateObject = scoreBalls[i];
		[[NezAnimator instance] addAnimation:ani];
	}
	usedScoreBalls = newScore;
	for (int i=0; i<usedScoreBalls; i++) {
		ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateBoxFade:) DidStopSelector:@selector(animateRelease:)];
		ani->updateObject = scoreBalls[i];
		ani->delay = 0.50;
		[[NezAnimator instance] addAnimation:ani];
	}
	ani = [[NezAnimation alloc] initFloatWithFromData:1.0 ToData:0.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(changeScoreCounter:) DidStopSelector:@selector(changeScoreCounterFadeOutDidStop:)];
	[[NezAnimator instance] addAnimation:ani];

	ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(changeScoreCounter:) DidStopSelector:@selector(animateRelease:)];
	ani->delay = 0.50;
	[[NezAnimator instance] addAnimation:ani];
}

-(void)changeScoreCounter:(NezAnimation*)ani {
	[totalScoreCounter setMix:ani->newData[0]];
	[totalScorePoints setMix:ani->newData[0]];
}

-(void)changeScoreCounterFadeOutDidStop:(NezAnimation*)ani {
	[ani release];
	[totalScoreCounter setUV:[gameState getTextureCoordinatesForNumber:usedScoreBalls]];
	scoreBallsMovingElipse = usedScoreBalls;
}

-(void)reset {
	isElipseRotationComplete = NO;
	
	usedScoreBalls = 0;
	scoreBallsMoving = 0;
	scoreBallsMovingElipse = 0;
	wordsTotal = 0;
	extrasTotal = 0;
	bonusTotal = 0;
	
	totalScore.modelMatrix->x.x = 6.0;
	totalScore.modelMatrix->y.y = 2.0;
	
	totalScoreCounter.modelMatrix->x.x = POINTS_COUNTER_SCALE;
	totalScoreCounter.modelMatrix->y.y = POINTS_COUNTER_SCALE;
	
	totalScorePoints.modelMatrix->x.x = POINTS_X_SCALE;
	totalScorePoints.modelMatrix->y.y = POINTS_Y_SCALE;
	
	NezRectangle2D *boxArray[] = {
		totalScore, totalScoreCounter, totalScorePoints,
		wordsBox, wordsScore, wordsScoreCounter,
		extrasBox, extrasScore, extrasScoreCounter,
		bonusBox, bonusScore, bonusScoreCounter,
	};
	for (int i=0; i<sizeof(boxArray)/sizeof(NezRectangle2D*); i++) {
		[boxArray[i] setMix:0.0];
		boxArray[i].modelMatrix->w.x = -10000;
		[boxArray[i] setBoundingPoints];
	}
	
	for (int i=0; i<TOTAL_SCORE_BALLS; i++) {
		[scoreBalls[i] setMix:0.0];
		scoreBalls[i].modelMatrix->w.x = -10000;
		scoreBalls[i].modelMatrix->x.x = 1.0;
		scoreBalls[i].modelMatrix->y.y = 1.0;
		[scoreBalls[i] setBoundingPoints];
	}

	if (totalElispeAni != nil) {
		[[NezAnimator instance] removeAnimation:totalElispeAni];
		[totalElispeAni release];
		totalElispeAni = nil;
	}

	[bonusBallsArray removeAllObjects];
}

-(void)animateReset {
	NSMutableArray *fadeoutObjects = [[NSMutableArray alloc] initWithCapacity:256];
	
	[fadeoutObjects addObject:totalScore];
	[fadeoutObjects addObject:totalScoreCounter];
	[fadeoutObjects addObject:totalScorePoints];
	
	[fadeoutObjects addObject:wordsBox];
	[fadeoutObjects addObject:wordsScore];
	[fadeoutObjects addObject:wordsScoreCounter];
	
	[fadeoutObjects addObject:extrasBox];
	[fadeoutObjects addObject:extrasScore];
	[fadeoutObjects addObject:extrasScoreCounter];
	
	[fadeoutObjects addObject:bonusBox];
	[fadeoutObjects addObject:bonusScore];
	[fadeoutObjects addObject:bonusScoreCounter];
	
	for (int i=0; i<TOTAL_SCORE_BALLS; i++) {
		[fadeoutObjects addObject:scoreBalls[i]];
	}

	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:1.0 ToData:0.0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateArrayFade:) DidStopSelector:@selector(animateArrayRelease:)];
	ani->updateObject = fadeoutObjects;
	[[NezAnimator instance] addAnimation:ani];
}

-(void)animateArrayFade:(NezAnimation*)ani {
	NSArray *array = (NSArray*)ani->updateObject;
	for (NezRectangle2D *object in array) {
		[object setMix:ani->newData[0]];
	}
}

-(void)animateArrayRelease:(NezAnimation*)ani {
	[ani->updateObject release];
	[ani release];
}

-(void)dealloc {
	//NSLog(@"dealloc:ScoreBoard");
	
	[totalScore release];
	[totalScoreCounter release];
	[totalScorePoints release];
	
	[wordsBox release];
	[wordsScore release];
	[wordsScoreCounter release];
	
	[extrasBox release];
	[extrasScore release];
	[extrasScoreCounter release];
	
	[bonusBox release];
	[bonusScore release];
	[bonusScoreCounter release];
	
	[bonusBallsArray removeAllObjects];
	[bonusBallsArray release];
	
	for (int i=0; i<TOTAL_SCORE_BALLS; i++) {
		[scoreBalls[i] release];
	}
	for (int i=0; i<LONG_WORD_HIGHLIGHT_COUNT; i++) {
		[longWordHighLightList[i] release];
	}
	
	if (totalElispeAni != nil) {
		[[NezAnimator instance] removeAnimation:totalElispeAni];
		[totalElispeAni release];
		totalElispeAni = nil;
	}
	self.animationStopDelegate = nil;
	self.animationStopSelector = nil;
	
	[super dealloc];
}

@end

