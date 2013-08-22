//
//  AletterationGameController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-31.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameController.h"
#import "AletterationGameView.h"
#import "AletterationGameView.h"
#import "NezAletterationSQLiteDictionary.h"
#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "LetterBlock.h"
#import "AnimatedWord.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezOpenAL.h"
#import "AnimatedCamera.h"
#import "AletterationBox.h"
#import "DisplayLine.h"
#import "LetterStack.h"
#import "ScoreBoard.h"
#import "AletterationResultsController.h"
#import "NezStrectableRectangle2D.h"


#define SELECTION_Z 5

static mat4 DEFAULT_SELECTION_MATRIX = {
	1,0,0,0,
	0,1,0,0,
	0,0,1,0,
	0,-1.5,SELECTION_Z,1,
};

static size3 EXTRA = {0.1, 0.1, 0};
static size3 EXTRA_TEMP = {1.1, 1.1, 0};

#define SIGN(x) (x>=0?1:-1)

@interface AletterationGameController (private)

-(void)setUserInteractionEnabled:(BOOL)flag;

-(void)startAnimateInitialPanToBox;
-(void)startAnimateStartingState;
-(void)startAnimateRemoveWord;
-(void)startAnimateGameOver;
-(void)startAnimateGameOver;

-(void)showScoresDialog;

-(void)startNextTurn;

-(CGPoint)locationInView:(UITouch*)touch;
-(CGPoint)pixelLocationInView:(UITouch*)touch;
-(CGPoint)offsetInView:(UITouch*)touch;
-(vec3)worldOffsetInView:(UITouch*)touch WorldZ:(float)worldZ;

-(void)automateFinishLines;
-(void)automateIsDone;

@end

@implementation AletterationGameController

@synthesize automatedWordList;

+(mat4)getDefaultSelectionMatrix {
    return DEFAULT_SELECTION_MATRIX;
}


-(void)setUserInteractionEnabled:(BOOL)flag {
	[self.view setUserInteractionEnabled:flag];
	inputEnabled = flag;
}

-(void)enableUserInteraction {
	[self setUserInteractionEnabled:YES];
}

-(void)disableUserInteraction {
	[self setUserInteractionEnabled:NO];
}

-(void)enableInput {
	inputEnabled = YES;
}

-(void)disableInput {
	inputEnabled = NO;
}

-(BOOL)updateGlowRectPosition {
	if(selectedBlock != nil) {
		gameState.glowRectangle.modelMatrix->w = selectedBlock.modelMatrix->w;
		return YES;
	} else {
		return NO;
	}
}

-(void)updateWithCurrentTime:(CFTimeInterval)now andPreviousTime:(CFTimeInterval)lastTime {
	[super updateWithCurrentTime:now andPreviousTime:lastTime];
	[gameState updateWithCurrentTime:now andPreviousTime:lastTime];
	BOOL glowIsVisible = [self updateGlowRectPosition];
	if(glowIsVisible) {
		if (glowPulseAnimation == nil) {
			glowPulseAnimation = [[NezAnimation alloc] initFloatWithFromData:0.5 ToData:1.0 Duration:1.0 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateGlowPulse:) DidStopSelector:nil];
			glowPulseAnimation->loop = LOOP_PINGPONG;
			[[NezAnimator instance] addAnimation:glowPulseAnimation];
		}
	} else if(glowPulseAnimation != nil) {
		[[NezAnimator instance] removeAnimation:glowPulseAnimation];
		[gameState.glowRectangle setMix:0.0];
		[glowPulseAnimation release];
		glowPulseAnimation = nil;
	}
}

-(void)animateGlowPulse:(NezAnimation*)ani {
	float alpha = *ani->newData;
	[gameState.glowRectangle setMix:alpha];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		gameGraphics = [OpenGLES2Graphics instance];
		camera = gameGraphics.camera;
        
		firstLoad = YES;
		blockAddedTemporarily = NO;

		glowPulseAnimation = nil;
		
		removeWordAnimating = NO;
		animatedWord = [[AnimatedWord alloc] init];
		
		dragBoardHorizontal = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBoard:)];
		dragBoardHorizontal.cancelsTouchesInView = NO;
		dragBoardHorizontal.delaysTouchesBegan = NO;
		dragBoardHorizontal.delaysTouchesEnded = NO;
		dragBoardHorizontal.delegate = self;

		selectionModeLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(enterSelectionMode:)];
		selectionModeLongPress.cancelsTouchesInView = NO;
		selectionModeLongPress.delaysTouchesBegan = NO;
		selectionModeLongPress.delaysTouchesEnded = NO;
		selectionModeLongPress.minimumPressDuration = 0.25;
		selectionModeLongPress.allowableMovement = 3.0;
		selectionModeLongPress.delegate = self;
		
		isFinished = NO;
		
		removeLineIndex = -1;
	}
    return self;
}

-(DisplayLine*)selectLine:(CGPoint)point {
	if (fingerBlock || blockAddedTemporarily) {
		return nil;
	}
	vec4 worldPoint = [gameGraphics getWorldPointWithScreenX:point.x ScreenY:point.y WorldZ:LINE_Z];
	DisplayLine **displayLineList = gameState.displayLines;
	for (int i=0; i<LINE_COUNT; i++) {
		if ([displayLineList[i] containsPoint:worldPoint]) {
			return displayLineList[i];
		}
	}
	return nil;
}

-(void)enterSelectionMode:(UILongPressGestureRecognizer*)sender {
	DisplayLine *lineToSelect;
	CGPoint point = [sender locationInView:self.view];
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			lineToSelect = [self selectLine:point];
			if (inputMask&(IM_SELECT_WORD1<<lineToSelect.lineIndex)) {
				[self positionWordOutlineForLine:lineToSelect TapPoint:point];
			}
			break;
		case UIGestureRecognizerStateEnded:
		default:
			break;
	}
}

-(void)positionWordOutlineForLine:(DisplayLine*)line TapPoint:(CGPoint)point TappedBlock:(LetterBlock*)tappedBlock {
	if(line != nil && removeWordAnimating == NO) {
		[line positionHighlightWithTapPoint:point TappedBlock:tappedBlock];
	}
}

-(void)positionWordOutlineForLine:(DisplayLine*)line TapPoint:(CGPoint)point {
	[self positionWordOutlineForLine:line TapPoint:point TappedBlock:nil];
}

-(void)setupView {
	[self.view addGestureRecognizer:dragBoardHorizontal];
	[self.view addGestureRecognizer:selectionModeLongPress];

	if (firstLoad) {
		[self disableUserInteraction];
		firstLoad = NO;

		[self performSelector:@selector(setupStartingState) withObject:nil afterDelay:0.1];
	}
}

-(void)viewDidLoad {
	[super viewDidLoad];
	[self setupView];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
	return YES;
}

-(void)setupStartingState {
	[gameState resetState];
	
	removeLineIndex = -1;
	
	selectedBlock = nil;
	fingerBlock = nil;
	fingerBlockOverLine = nil;
	
	inputMask = IM_ALL_INPUT;
	
	animateStartingState = YES;
	if (gameState.stateObject != nil) {
		animateStartingState = NO;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

			[gameState.letterCarton layoutStacks];
			[gameState setupStateObject];
			[gameState setupAllLines];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[gameState setStackCountersAlpha:1.0];
				[gameState setDisplayLinesAlpha:1.0];
				[gameState updateAllStackCounters];
				
				[gameState setColorsForAllLines];
				
				for (int i=0; i<LINE_COUNT; i++) {
					DisplayLine *line = gameState.displayLines[i];
					if (line.isWord) {
						if (line.needsHighlight) {
							[self highlightLine:line];
						}
					} else if(line.isHighlighted) {
						[line hideHighlight];
					}
				}
				[self updateLocalScoreDisplays];

				[self startAnimateInitialPanToBox];
			});
			
			[pool release];
		});
	} else {
		[gameState setupStateObject];
		[self startAnimateInitialPanToBox];
	}
}

-(void)startAnimateInitialPanToBox {
	camera.animationStopDelegate = self;
	camera.animationStopSelector = @selector(animateInitialPanToBoxDidStop);
	
	currentViewLocation = 0;
	
	vec3 aeye = {-5.0f, -10.0f, 5.0f};
	vec3 atarget = {0.0f, 0.0f, 0.0f};
	vec3 aup = {0.0f, 0.0f, 1.0f};
	
	[camera animateToEye:aeye Target:atarget UpVector:aup Duration:1.0 EasingFunction:&easeInOutCubic];
}

-(void)animateInitialPanToBoxDidStop {
	camera.animationStopDelegate = nil;
	camera.animationStopSelector = nil;
	
	vec3 eye = [AletterationGameState getDefaultEye];
	vec3 target = [AletterationGameState getDefaultTarget];
	vec3 up = [AletterationGameState getDefaultUpVector];
	
	if (animateStartingState) {
		[self startAnimateStartingState];
	} else {
		camera.animationStopDelegate = self;
		camera.animationStopSelector = @selector(layoutStacksAnimationDidStop);
	}
	[camera animateToEye:eye Target:target UpVector:up Duration:2.5 EasingFunction:&easeInOutCubic];
}

-(void)startAnimateStartingState {
	[gameState.letterCarton layoutStacksAnimation:self finishedSelector:@selector(layoutStacksAnimationDidStop)];
	[gameState fadeInStackCounters];
	[gameState fadeInDisplayLines];
}

-(void)layoutStacksAnimationDidStop {
	camera.animationStopDelegate = nil;
	camera.animationStopSelector = nil;

	[self enableUserInteraction];
	[self startNextTurn];
}

-(void)startNextTurn {
	[gameState setNextTurn];
	[self waitForNextTurn];
}

-(void)waitForNextTurn {
	selectedBlock = gameState.selectedBlock;
	[self receivedNextBlock];
}

-(void)automateFinishLines {
	self.automatedWordList = [NSMutableArray arrayWithCapacity:6];
	for (int i=0; i<LINE_COUNT; i++) {
		DisplayLine *line = gameState.displayLines[i];
		if (line.isWord) {
  			AnimatedWord *aWord = [[[AnimatedWord alloc] init] autorelease];
			aWord.doesCameraTracking = NO;
			int letterCount = line.highlightedLetterCount;
			if (letterCount >= 4) {
				[line hideHighlight];
				aWord.leterBlockArray = [gameState removeWordFromLine:i Count:letterCount];
			} else {
				int count = line.count - line.inputLength.prefixIndex;
				if (count >= 4) {
					[line hideHighlight];
					aWord.leterBlockArray = [gameState removeWordFromLine:i Count:count];
				}
			}
			if (aWord.leterBlockArray != nil) {
				[self addAutomatedWord:aWord LineIndex:i];
			}
		}
	}
	if ([self.automatedWordList count] == 0) {
		[self automateIsDone];
	} else {
		removeWordAnimating = YES;
		[self disableUserInteraction];
		[self updateLocalScoreDisplays];
		[self startAnimateAutomate];
	}
}

-(void)addAutomatedWord:(AnimatedWord*)word LineIndex:(int)lineIndex {
	[self.automatedWordList addObject:word];
}

-(void)startAnimateAutomate {
	if (self.automatedWordList != nil && [self.automatedWordList count] > 0) {
		AnimatedWord *firstWord = [self.automatedWordList objectAtIndex:0];
		firstWord.doesCameraTracking = YES;
		for (AnimatedWord *aWord in self.automatedWordList) {
			if (aWord == firstWord) {
				[aWord startAnimatingToScoreBoard:self finishedSelector:@selector(automateNextCheck)];
			} else {
				[aWord startAnimatingToScoreBoard:self finishedSelector:nil];
			}
		}
	}
}

-(void)automateNextCheckAni {
	[gameState setColorsForAllLines];
	removeWordAnimating = NO;
	BOOL done = YES;
	for (int i=0; i<LINE_COUNT; i++) {
		DisplayLine *line = gameState.displayLines[i];
		if (line.isWord) {
			[self highlightLine:line];
			done = NO;
		}
	}
	if (done) {
		[self automateIsDone];
	} else {
		[self performSelector:@selector(automateFinishLines) withObject:nil afterDelay:0.5];
	}
}

-(void)automateNextCheck {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[gameState setupAllLines];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self automateNextCheckAni];
		});
		
		[pool release];
	});
}

-(void)automateIsDone {
	[self doLocalGameOver];
}

-(void)receivedNextBlock {
	if (selectedBlock) {
		[self animateSelectedBlockToDefaultPositionWithSoundEffect:gameState.sounds->letterUp andDuration:0.25];
		[[gameState getStackForLetter:selectedBlock.letter] startCountChangeAnimation];
	} else {
		if (!isFinished) {
			isFinished = YES;
			[self performSelector:@selector(automateFinishLines) withObject:nil afterDelay:0.5];
		}
	}
}

-(void)highlightLine:(DisplayLine*)line {
	CGPoint point = {-5000,-5000};
	LetterBlock *tappedBlock = [line.letterList objectAtIndex:line.inputLength.prefixIndex];
	[self positionWordOutlineForLine:line TapPoint:point TappedBlock:tappedBlock];
}

-(void)topEndTurn:(int)lineIndex withNoCheck:(BOOL)noCheck {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[gameState addCurrentLetterToLine:lineIndex withNoCheck:noCheck];

		dispatch_async(dispatch_get_main_queue(), ^{
			[gameState setColorsForAllLines];
			
			for (int i=0; i<LINE_COUNT; i++) {
				DisplayLine *line = gameState.displayLines[i];
				if (line.isWord) {
					if (line.needsHighlight) {
						[self highlightLine:line];
					}
				} else if(line.isHighlighted) {
					[line hideHighlight];
				}
			}
			blockAddedTemporarily = NO;
			selectedBlock = nil;
			fingerBlock = nil;
			fingerBlockOverLine = nil;
			[self waitForEndTurn];
		});
		
		[pool release];
	});
}

-(void)endTurn:(int)lineIndex {
	[self topEndTurn:lineIndex withNoCheck:NO];
}

-(void)waitForEndTurn {
	[self startNextTurn]; 
}

-(void)cancelEndTurn {}

-(void)doLocalGameOver {
	gameState.localPlayerInfo.gameOver = YES;
	camera.animationStopDelegate = self;
	camera.animationStopSelector = @selector(doGameOver);
	[self slideCameraWordList];
}

-(void)doGameOver {
	[self startAnimateGameOver];
}

-(void)startAnimateGameOver {
	camera.animationStopDelegate = nil;
	camera.animationStopSelector = nil;
	
	gameState.scoreBoard.animationStopDelegate = self;
	gameState.scoreBoard.animationStopSelector = @selector(showScoresDialog);
	[gameState.scoreBoard showScoreAnimation];
    
    [gameState stopMusic];
}

-(void)showScoresDialog {
	gameState.scoreBoard.animationStopDelegate = nil;
	gameState.scoreBoard.animationStopSelector = nil;
	[AletterationResultsController showModal:self withCloseDelegate:self andCloseSelector:@selector(resetGame)];
}

-(void)resetGame {
	[self disableUserInteraction];
	
	if (currentViewLocation != 0) {
		float duration = abs(currentViewLocation)*0.5;
		[self slideCamera:0 Duration:duration];
		currentViewLocation = 0;
	}
	selectedBlock = nil;
	
	gameState.resetGameDelegate = self;
	gameState.resetGameSelector = @selector(resetGameComplete);
	[gameState resetGame];
}

-(void)resetGameComplete {
	[self popToRootViewControllerAnimated:NO];
}

-(void)animateSelectedBlockToDefaultPositionWithSoundEffect:(NSUInteger)sound andDuration:(float)duration {
	blockAddedTemporarily = NO;
	[self animateSelectedBlockWithMatrix:&DEFAULT_SELECTION_MATRIX Duration:duration soundEffect:sound];
}

-(void)animateSelectedBlockWithMatrix:(mat4*)mat Duration:(float)duration soundEffect:(NSUInteger)sound {
	[self animateSelectedBlockWithMatrix:mat Duration:duration didStopDelegate:self didStopSelector:@selector(enableUserInteraction) soundEffect:sound];
}

-(void)animateSelectedBlockWithMatrix:(mat4*)mat Duration:(float)duration didStopDelegate:(id)delegate didStopSelector:(SEL)selector soundEffect:(NSUInteger)sound {
	[self disableUserInteraction];
	float maxPitchOffset = 0.1;
	float pitchOffset = randomNumber()*(maxPitchOffset*2.0)-maxPitchOffset;
	[gameState.soundPlayer playSound:sound gain:1.0 pitch:1.0+pitchOffset loops:NO];
	selectedBlock.animationStopDelegate = delegate;
	selectedBlock.animationStopSelector = selector;
	[selectedBlock animateMatrix:mat withDuration:duration];
}

-(void)animateLetterBlockToLineDidStop:(LetterBlock*)lb {
	selectedBlock.animationStopDelegate = nil;
	selectedBlock.animationStopSelector = nil;
	
	[gameState setSelectedBlock:selectedBlock ToLine:fingerBlockOverLine.lineIndex];
	blockAddedTemporarily = YES;
	
	[self enableUserInteraction];
	
	[self endTurn:fingerBlockOverLine.lineIndex];
}

-(BOOL)removeWordFromLine:(int)lineIndex Count:(int)wordCount {
	[gameState playSound:gameState.sounds->dblTapWord];
	[gameState.displayLines[lineIndex] hideHighlight];

	animatedWord.leterBlockArray = [gameState removeWordFromLine:lineIndex Count:wordCount];
	if (animatedWord.leterBlockArray && [animatedWord.leterBlockArray count] > 0) {
		removeWordAnimating = YES;
		removeLineIndex = lineIndex;
		[self disableUserInteraction];
		[self updateLocalScoreDisplays];
		[self startAnimateRemoveWord];
		return YES;
	}
	return NO;
}

-(void)startAnimateRemoveWord {
//	animatedWord.doesCameraTracking = NO;
	[animatedWord startAnimatingToScoreBoard:self finishedSelector:@selector(animateRemoveWordDidStop)];
}

-(void)animateRemoveWordDidStopSetup {
	[gameState setColorsForAllLines];
	removeWordAnimating = NO;
	DisplayLine *line = gameState.displayLines[removeLineIndex];
	if (line.isWord) {
		[self highlightLine:line];
	}
	[self enableUserInteraction];
}

-(void)animateRemoveWordDidStop {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[gameState setupCurrentWordForLine:removeLineIndex];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self animateRemoveWordDidStopSetup];
		});
		
		[pool release];
	});
}

-(void)updateLocalScoreDisplays {}

-(CGPoint)locationInView:(UITouch*)touch {
	return [touch locationInView:self.view];
}

-(CGPoint)pixelLocationInView:(UITouch*)touch {
	CGPoint p = [touch locationInView:self.view];
	p.x *= gameGraphics.screenScale;
	p.y *= gameGraphics.screenScale;
	return p;
}

-(CGPoint)offsetInView:(UITouch*)touch {
	CGPoint previousLocation = [touch previousLocationInView:self.view];
	CGPoint currentLocation = [touch locationInView:self.view];
	CGPoint offset = {currentLocation.x-previousLocation.x, currentLocation.y-previousLocation.y};
	return offset;
}

-(vec3)worldOffsetInView:(UITouch*)touch WorldZ:(float)worldZ {
	CGPoint offset = [self offsetInView:touch];
	vec4 worldPoint1 = [gameGraphics getWorldPointWithScreenX:0 ScreenY:0 WorldZ:worldZ];
	vec4 worldPoint2 = [gameGraphics getWorldPointWithScreenX:offset.x ScreenY:offset.y WorldZ:worldZ];
	vec3 worldOffset = {worldPoint2.x-worldPoint1.x, worldPoint2.y-worldPoint1.y, worldPoint2.z-worldPoint1.z};
	return worldOffset;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	if (inputEnabled == NO) {
		return;
	}
	touchesDown += [touches count];
	if (touchesDown == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint nextTouch = [self locationInView:touch];
		if ([touch tapCount] == 1) {
			if (selectedBlock && (inputMask&IM_DRAG_LETTER)) {
				float zLevel;
				size3 extra;
				if (blockAddedTemporarily) {
					zLevel = LINE_Z+selectedBlock.size.d/2.0;
					extra = EXTRA_TEMP;
				} else {
					zLevel = SELECTION_Z;
					extra = EXTRA;
				}
				vec4 worldPoint = [gameGraphics getWorldPointWithScreenX:nextTouch.x ScreenY:nextTouch.y WorldZ:zLevel];
				if ([selectedBlock containsPoint:worldPoint withExtraSize:extra]) {
					[gameState playSound:gameState.sounds->touchLetter];
					fingerBlock = selectedBlock;
					if (blockAddedTemporarily) {
						
						[self cancelEndTurn];

						blockAddedTemporarily = NO;
						[gameState setSelectedBlock:nil ToLine:-1];
						
						worldPoint = [gameGraphics getWorldPointWithScreenX:nextTouch.x ScreenY:nextTouch.y WorldZ:SELECTION_Z];
						vec3 midPoint = { worldPoint.x, worldPoint.y, worldPoint.z };
						[fingerBlock setBoxWithMidPoint:&midPoint];
						[fingerBlockOverLine setColor:gameState.selectionColor andMix:1.0];
					}
				}
			}
		}
	}
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	if (inputEnabled == NO) {
		return;
	}
	if (touchesDown == 1) {
		UITouch *touch = [touches anyObject];
		if ([touch tapCount] == 1) {
			if((inputMask&IM_DRAG_LETTER)) {
				if (fingerBlock) {
					vec3 offset = [self worldOffsetInView:touch WorldZ:SELECTION_Z];
					[fingerBlock offsetWithDX:offset.x DY:offset.y DZ:offset.z];
					
					vec3 midPoint = [fingerBlock getMidPoint];
					vec2 sp = [gameGraphics getScreenPointWithX:midPoint.x Y:midPoint.y Z:midPoint.z];
					vec4 wp = [gameGraphics getWorldPointWithPixelX:sp.x PixelY:sp.y WorldZ:LINE_Z];
					DisplayLine **displayLineList = gameState.displayLines;
					
					DisplayLine *overLine = nil;
					unsigned int lineMask = IM_DROP_LINE_1;
					for (int i=0; i<LINE_COUNT; i++) {
						if (inputMask&(lineMask<<i)) {
							if ([displayLineList[i] containsPoint:wp withExtraSize:EXTRA]) {
								overLine = displayLineList[i];
								break;
							}
						}
					}
					if (overLine != fingerBlockOverLine) {
						if (fingerBlockOverLine) {
							[fingerBlockOverLine setColor:[DisplayLine COLOR_LINE] andMix:1.0];
						}
						if (overLine) {
							[overLine setColor:gameState.selectionColor andMix:1.0];
						}
					}
					fingerBlockOverLine = overLine;
				} else if (selectedBlock && !blockAddedTemporarily && !draggingBoard) {
					CGPoint nextTouch = [self locationInView:touch];
					vec4 worldPoint = [gameGraphics getWorldPointWithScreenX:nextTouch.x ScreenY:nextTouch.y WorldZ:SELECTION_Z];
					size3 zero = {0,0,0};
					if ([selectedBlock containsPoint:worldPoint withExtraSize:zero]) {
						[gameState playSound:gameState.sounds->touchLetter];
						fingerBlock = selectedBlock;
						[self slideCamera:0.0 Duration:0.0];
					}
				}
			}
		}
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	touchesDown -= [touches count];
	if (touchesDown < 0) {
		touchesDown = 0;
	}
	if (inputEnabled == NO) {
		return;
	}
	if (touchesDown == 0) {
		UITouch *touch = [touches anyObject];
		if ([touch tapCount] <= 1) {
			if (fingerBlock) {
				if (fingerBlockOverLine) {
					vec3 pos = [fingerBlockOverLine getNextLetterPos];
					
					mat4 mat = {
						1,0,0,0,
						0,1,0,0,
						0,0,1,0,
						pos.x,pos.y,pos.z,1,
					};
					[fingerBlockOverLine setColor:[DisplayLine COLOR_LINE] andMix:1.0];
					[self animateSelectedBlockWithMatrix:&mat Duration:0.5 didStopDelegate:self didStopSelector:@selector(animateLetterBlockToLineDidStop:) soundEffect:gameState.sounds->letterDown];
				} else {
					[self animateSelectedBlockToDefaultPositionWithSoundEffect:gameState.sounds->letterUp andDuration:0.25];
				}
				fingerBlock = nil;
			}
		} else if ([touch tapCount] == 2) {
			CGPoint touchPoint = [self locationInView:touch];
			vec4 worldPoint = [gameGraphics getWorldPointWithScreenX:touchPoint.x ScreenY:touchPoint.y WorldZ:LINE_Z];
			DisplayLine **displayLineList = gameState.displayLines;
			
			unsigned int lineMask = IM_DBLTAP_WORD1;
			for (int i=0; i<LINE_COUNT; i++) {
				if (inputMask&lineMask) {
					DisplayLine *line = displayLineList[i];
					if ([line containsPoint:worldPoint withExtraSize:SIZE3ZERO]) {
						int fireCount = line.highlightedLetterCount-3;
						if ([self removeWordFromLine:i Count:line.highlightedLetterCount]) {
							[gameState startFireWorksWithIndex:0 CurrentTime:currentTimeInterval Center:worldPoint];
							if (fireCount > FIRE_WORKS_COUNT) {
								fireCount = FIRE_WORKS_COUNT;
							}
							float delay = 0.0;
							for (i=1; i<fireCount; i++) {
								delay += 0.15+0.15*randomNumber();
								[self performSelector:@selector(startFireWorks:) withObject:[NSNumber numberWithInt:i] afterDelay:delay];
							}
						}
						break;
					}
				}
				lineMask <<= 1;
			}
		} 
	}
}

-(void)startRemoveWordAnimation:(DisplayLine*)line {
	int fireCount = line.highlightedLetterCount-3;
	if ([self removeWordFromLine:line.lineIndex Count:line.highlightedLetterCount]) {
		vec4 worldPoint = {line.minX+gameState.blockLength*[line.letterList count], line.minY+(line.maxY-line.minY)/2.0, LINE_Z, 0.0 };
		[gameState startFireWorksWithIndex:0 CurrentTime:currentTimeInterval Center:worldPoint];
		if (fireCount > FIRE_WORKS_COUNT) {
			fireCount = FIRE_WORKS_COUNT;
		}
		float delay = 0.0;
		for (int i=1; i<fireCount; i++) {
			delay += 0.15+0.15*randomNumber();
			[self performSelector:@selector(startFireWorks:) withObject:[NSNumber numberWithInt:i] afterDelay:delay];
		}
	}
}

-(void)startFireWorks:(NSNumber*)index {
	vec3 point = [gameGraphics.camera getTarget];
	vec4 worldPoint = {point.x, point.y, point.z, 0.0 };
	[gameState startFireWorksWithIndex:[index intValue] CurrentTime:currentTimeInterval Center:worldPoint];
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	touchesDown -= [touches count];
	if (touchesDown < 0) {
		touchesDown = 0;
	}
	if (touchesDown == 0) {
		fingerBlock = nil;
		if (fingerBlockOverLine) {
			[fingerBlockOverLine setColor:[DisplayLine COLOR_LINE] andMix:1.0];
			fingerBlockOverLine = nil;
		}
	}
}

-(void)slideCameraWordList {
	currentViewLocation = 1;
	vec3 defaultEye = [AletterationGameState getDefaultEye];
	vec3 eye = [gameState.scoreBoard getCameraEyePositionWithWordCount:[gameState.completedWordBlockList count] DefaultZ:defaultEye.z];
	vec3 target = {eye.x, eye.y, 0.0};
	vec3 defaultUp = [AletterationGameState getDefaultUpVector];
	[camera animateToEye:eye Target:target UpVector:defaultUp Duration:0.5 EasingFunction:&easeOutCubic];
}

-(void)slideCameraDefault {
	currentViewLocation = 0;
	vec3 eye = [AletterationGameState getDefaultEye];
	vec3 target = {eye.x, eye.y, 0.0};
	vec3 defaultUp = [AletterationGameState getDefaultUpVector];
	[camera animateToEye:eye Target:target UpVector:defaultUp Duration:0.5 EasingFunction:&easeOutCubic];
}

-(void)slideCameraJunk {
	currentViewLocation = -1;
	vec3 defaultEye = [AletterationGameState getDefaultEye];
	vec3 eye = {-[self swipeDistance]/2.0, 0.0, defaultEye.z};
	vec3 target = {eye.x, eye.y, 0.0};
	vec3 defaultUp = [AletterationGameState getDefaultUpVector];
	[camera animateToEye:eye Target:target UpVector:defaultUp Duration:0.5 EasingFunction:&easeOutCubic];
}

-(void)slideCamera:(float)distance Duration:(float)duration {
	vec3 defaultEye = [AletterationGameState getDefaultEye];
	vec3 eye = {distance, 0.0, defaultEye.z};
	vec3 target = {distance, 0.0, 0.0};
	vec3 defaultUp = [AletterationGameState getDefaultUpVector];
	
	[camera animateToEye:eye Target:target UpVector:defaultUp Duration:duration EasingFunction:&easeOutCubic];
}

-(void)dragBoard:(UIPanGestureRecognizer*)sender {
	if ((!fingerBlock && !blockAddedTemporarily) || currentViewLocation != 0) {
		if (!(inputMask&(IM_SWIPE_LEFT|IM_SWIPE_RIGHT))) {
			return;
		}
		CGPoint point = [sender translationInView:self.view];
		if (sender.state == UIGestureRecognizerStateBegan) {
			if (selectedBlock && currentViewLocation == 0) {
				CGPoint nextTouch = [sender locationInView:self.view];
				vec4 touchWorldPoint = [gameGraphics getWorldPointWithScreenX:nextTouch.x ScreenY:nextTouch.y WorldZ:SELECTION_Z];
				if ([selectedBlock containsPoint:touchWorldPoint withExtraLeft:1.0 Top:0.1 Right:1.0 Bottom:1.0 Down:0.0 Up:0.0]) {
					draggingBoard = NO;
					return;
				}
			}
			cameraEyeOnDrag = [camera getEye];
			dragDownPoint = [gameGraphics getWorldPointWithScreenX:point.x ScreenY:point.y WorldZ:LINE_Z];
			draggingBoard = YES;
		}
		if (draggingBoard) {
			vec4 worldPoint = [gameGraphics getWorldPointWithScreenX:point.x ScreenY:point.y WorldZ:LINE_Z];
			float xOffset = worldPoint.x-dragDownPoint.x;
			float swipeDistance = [self swipeDistance];
			vec3 eye = { cameraEyeOnDrag.x-xOffset, cameraEyeOnDrag.y, cameraEyeOnDrag.z };
			vec3 target = { eye.x, eye.y, LINE_Z };
			[camera setEye:eye andTarget:target];
			[gameGraphics setupMatricesQuick];
			
			if (sender.state == UIGestureRecognizerStateEnded) {
				float duration;
				CGPoint velocity = [sender velocityInView:self.view];
				duration = 0.5;
				if (velocity.x < 0 && xOffset < 0) {
					if (velocity.x < -500 || xOffset < -swipeDistance/2.0) {
						if (currentViewLocation <= 0 && (inputMask&IM_SWIPE_LEFT)) {
							currentViewLocation++;
							duration = 1.0/3.0;
						}
					}
				} else if (velocity.x > 0 && xOffset > 0) {
					if (velocity.x > 500 || xOffset > swipeDistance/2.0) {
						if (currentViewLocation >= 0 && (inputMask&IM_SWIPE_RIGHT)) {
							currentViewLocation--;
							duration = 1.0/3.0;
						}
					}
				}
				[self disableUserInteraction];
				camera.animationStopDelegate = self;
				camera.animationStopSelector = @selector(swipeAnimationDidStop);
				if (currentViewLocation == 1) {
					[self slideCameraWordList];
				} else {
					[self slideCamera:currentViewLocation*swipeDistance Duration:duration];
				}
				draggingBoard = NO;
			}
		}
	}
}

-(void)swipeAnimationDidStop {
	[self enableUserInteraction];
	camera.animationStopDelegate = nil;
	camera.animationStopSelector = nil;
}

-(float)swipeDistance {
	NezRectangle2D *r = gameState.displayLines[0];
	return r.maxX*2.0;
}

-(void)dealloc {
	self.automatedWordList = nil;
	[animatedWord release];
	[dragBoardHorizontal release];
	[selectionModeLongPress release];
	[super dealloc];
}

@end
