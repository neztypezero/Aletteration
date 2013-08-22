//
//  DisplayLine.m
//  Aletteration
//
//  Created by David Nesbitt on 2/7/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "DisplayLine.h"
#import "AletterationAppDelegate.h"
#import "OpenGLES2Graphics.h"
#import "AletterationGameState.h"
#import "LetterBlock.h"
#import "EAGLView.h"
#import "Structures.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezOpenAL.h"
#import "NezStrectableRectangle2D.h"

static const color4uc COLOR_LINE_INVISIBLE = {255, 255, 255, 0};
static const color4uc COLOR_LINE = {255, 255, 255, 100};
static const color4uc COLOR_IS_NOTHING = {150, 150, 150, 255};
static const color4uc COLOR_IS_PREFIX = {0, 200, 0, 255};
static const color4uc COLOR_IS_WORD = {255, 0, 0, 255};
static const color4uc COLOR_IS_BOTH = {255, 0, 255, 255};

@interface DisplayLine (private)

-(color4uc)getLetterColor;

-(void)animateLineStretch:(NezAnimation*)ani;
-(void)animateLineStretchDidStop:(NezAnimation*)ani;
-(void)animateLineSlide:(NezAnimation*)ani;
-(void)animateLineSlideDidStop:(NezAnimation*)ani;

-(void)positionHighlight;

@end

@implementation DisplayLine

@synthesize type;
@synthesize inputLength;
@synthesize startMidPoint;
@synthesize lineIndex;
@synthesize letterList;
@synthesize selectedBlock;
@synthesize isHighlighted;
@synthesize highlightedLetterCount;

+(color4uc)COLOR_LINE {
	return COLOR_LINE;
}

-(id)initWithLineIndex:(int)index midPoint:(vec3)pos width:(float)w height:(float)h VertexList:(NezVertexArray*)vertexArray {
	mat4 mat = {
		{w,   0.0, 0.0, 0.0}, // x column
		{0.0, h,   0.0, 0.0}, // y column
		{0.0, 0.0, 1.0, 0.0}, // z column
		{pos.x, pos.y, pos.z, 1.0}, // w column
	};
	if ((self = [super initWithVertexArray:vertexArray modelMatrix:mat color:COLOR_LINE_INVISIBLE])) {
		lineIndex = index;
		inputLength = INPUT_ZERO;
		
		animatingLineStretchDistance = 0;
		animatingLineSlideDistance = 0;
		previoiusLineDistance = 0;
		
		slideAnimation = nil;
		
		startMidPoint = pos;
		
		letterList = [[NSMutableArray arrayWithCapacity:20] retain];
		shiftOffset = 0;

		gameState = [AletterationGameState instance];
		
		animatingSoundSource = -1;
		highlightAnimation = nil;
	}
	return self;
}

-(BOOL)getIsWord {
	return type==NEZ_DIC_INPUT_ISWORD||type==NEZ_DIC_INPUT_ISBOTH;
}

-(void)touchesBegan:(NSSet*)touches withView:(UIView*)view {
	if (animatingSoundSource == -1) {
		previoiusLineDistance = 0;
		lineDragDistance = 0;
//		animatingSoundSource = [gameState.soundPlayer playSound:gameState.sounds->beep gain:1.0 pitch:0.5 loops:YES];
	}
}

-(void)touchesMoved:(NSSet*)touches withView:(UIView*)view {
	if (slideAnimation) {
		[[NezAnimator instance] cancelAnimation:slideAnimation];
		[slideAnimation release];
		slideAnimation = nil;
	}
	if (letterList != nil && [letterList count] > 0) {
		UITouch *touch = [touches anyObject];
		CGPoint nextTouch = [touch locationInView:view];
		CGPoint prevTouch = [touch previousLocationInView:view];
		
		OpenGLES2Graphics *g = [OpenGLES2Graphics instance];
		vec4 nextPoint = [g getWorldPointWithScreenX:nextTouch.x ScreenY:nextTouch.y WorldZ:LINE_Z];
		vec4 prevPoint = [g getWorldPointWithScreenX:prevTouch.x ScreenY:prevTouch.y WorldZ:LINE_Z];
		float dx = nextPoint.x-prevPoint.x;
		[self offsetWithDX:dx DY:0.0f DZ:0.0f];
		[self setBoxPositions];
		lineDragDistance += dx;
	}
}

-(void)touchesEnded:(NSSet*)touches withView:(UIView*)view {
	if (slideAnimation) {
		[[NezAnimator instance] cancelAnimation:slideAnimation];
		[slideAnimation release];
		slideAnimation = nil;
	}
	animatingLineSlideDistance = 0.0f;
	float d = pow(fabs(lineDragDistance), 0.25);
	float duration = d;
	slideAnimation = [[NezAnimation alloc] initFloatWithFromData:0 ToData:-lineDragDistance Duration:duration EasingFunction:&easeOutElastic CallbackObject:self UpdateSelector:@selector(animateLineSlide:) DidStopSelector:@selector(animateLineSlideDidStop:)];
	[[NezAnimator instance] addAnimation:slideAnimation];

}

-(void)updatePitch:(float)timeElapsed {
	if (animatingSoundSource != -1) {
		float dx = lineDragDistance-previoiusLineDistance;
		float velocity = dx/timeElapsed;
		previoiusLineDistance = lineDragDistance;
		
		[gameState.soundPlayer setGain:fabs(velocity/150.0) andPitch:fabs(lineDragDistance/(self.size.w*2.0)) forSource:animatingSoundSource];
	}
}

-(void)animateLineSlide:(NezAnimation*)ani {
	float x = ani->newData[0];
	float dx = x-animatingLineSlideDistance;
	lineDragDistance += dx;
	animatingLineSlideDistance = x;
	[self offsetWithDX:dx DY:0.0f DZ:0.0f];
	[self setBoxPositions];
	[gameState.soundPlayer setGain:fabs((dx/ani->timeSinceLastUpdate)/150.0) andPitch:fabs(lineDragDistance/(self.size.w*2.0)) forSource:animatingSoundSource];
}

-(void)animateLineSlideDidStop:(NezAnimation*)ani {
	lineDragDistance = 0.0f;
	animatingLineSlideDistance = 0.0f;
	[self setBoxWithMidPoint:&startMidPoint];
	[self setBoxPositions];
	[slideAnimation release];
	slideAnimation = nil;
	[gameState.soundPlayer stopSound:animatingSoundSource];
	animatingSoundSource = -1;
}

-(color4uc)getLetterColor {
	if (inputLength.prefixLength > 0) {
		return gameState.letterColor;
	} else {
		return COLOR_IS_NOTHING;
	}
}

-(void)setLetterColors {
	int count = [letterList count];
	if (count > 0) {
		int currentLetterCount = inputLength.prefixLength;
		int junkCount = [letterList count] - currentLetterCount;
		for (int i=0; i<junkCount; i++) {
			LetterBlock *lb = (LetterBlock*)[letterList objectAtIndex:i];
			[lb setColor:COLOR_IS_NOTHING andMix:0.0f];
		}
		color4uc letterColor = [self getLetterColor];
		for (int i=junkCount; i<junkCount+currentLetterCount; i++) {
			LetterBlock *lb = (LetterBlock*)[letterList objectAtIndex:i];
			[lb setColor:letterColor andMix:0.0f];
		}
		if (currentLetterCount == 0 && junkCount > 0) {
			junkCount--;
		}
		int shift = junkCount-shiftOffset;
		if (shift > 3 || shift < 0) {
			if (shiftOffset != junkCount) {
				//Auto Scroll line to the left or if negative back to the right
				animatingLineStretchDistance = 0.0f;
				NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:-shiftOffset ToData:(-(shiftOffset+shift)) Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateLineStretch:) DidStopSelector:@selector(animateLineStretchDidStop:)];
				shiftOffset += shift;
				[[NezAnimator instance] addAnimation:ani];
			}
		}
		NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0 ToData:1 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateLetterColor:) DidStopSelector:@selector(animateLetterColorDidStop:)];
		[[NezAnimator instance] addAnimation:ani];
	}
}


-(NSArray*)removeRange:(NSRange)range {
	NSArray *removedLetterBlocks = [letterList subarrayWithRange:range];
	[letterList removeObjectsInRange:range];
	return removedLetterBlocks;
}

-(void)startFadeInAnimationWithDuration:(float)duration {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:0.0 ToData:1.0 Duration:duration EasingFunction:&easeInCubic CallbackObject:self UpdateSelector:@selector(animateLineFade:) DidStopSelector:@selector(animateLineFadeDidStop:)];
	[[NezAnimator instance] addAnimation:ani];
}

-(void)startFadeOutAnimationWithDuration:(float)duration {
	NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:[self getMix] ToData:0.0 Duration:duration EasingFunction:&easeInCubic CallbackObject:self UpdateSelector:@selector(animateLineFade:) DidStopSelector:@selector(animateLineFadeDidStop:)];
	[[NezAnimator instance] addAnimation:ani];
}

-(void)setBoxPositions {
	int count = [letterList count];
	if (count > 0) {
		float size = gameState.blockLength;
		float depth = gameState.blockDepth;

		vec3 b = {
			min.x+size/2.0f,
			(max.y+min.y)/2.0f,
			((max.z+min.z)/2.0f)+depth/2.0,
		};
		for (LetterBlock *lb in letterList) {
			[lb setBoxWithMidPoint:&b];
			b.x += size;
		}
		if(selectedBlock != nil) {
			[selectedBlock setBoxWithMidPoint:&b];
		}
	}
}

-(vec3)getNextLetterPosForCharIndex:(int)index {
	vec3 b = {
		min.x,
		attributes->matrix.w.y,
		attributes->matrix.w.z,
	};
	float size = gameState.blockLength;
	float depth = gameState.blockDepth;
	b.x += size/2.0f+(index*size);
	b.z += depth/2.0f;
	return b;
}

-(vec3)getNextLetterPos {
	return [self getNextLetterPosForCharIndex:[letterList count]];
}

-(void)animateLineStretch:(NezAnimation*)ani {
	float shift = ani->newData[0];
	float dLen = (shift*gameState.blockLength);
	float newLength = (originalScale.x)-dLen;

	attributes->matrix.w.x = dLen/2.0;
	attributes->matrix.x.x = newLength;
	[self setBoundingPoints];
	[self setBoxPositions];
	if (self.isHighlighted) {
		[self positionHighlight];
	}
}

-(void)animateLineStretchDidStop:(NezAnimation*)ani {
	startMidPoint = [self getMidPoint];
	[ani release];
}

-(void)animateLetterColor:(NezAnimation*)ani {
	float colorMix = ani->newData[0];
	for (LetterBlock *lb in letterList) {
		[lb setMix:colorMix];
	}
}

-(void)animateLetterColorDidStop:(NezAnimation*)ani {
	[ani release];
}

-(void)animateLineFade:(NezAnimation*)ani {
	[self setMix:ani->newData[0]];
}

-(void)animateLineFadeDidStop:(NezAnimation*)ani {
	[ani release];
}

-(void)hideHighlight {
	if (isHighlighted) {
		isHighlighted = NO;
		[self startHighlightAnimationFrom:1.0 To:0.0 FinishSelector:@selector(animateHighlightDidStop:)];
	}
	highlightedLetterCount = 0;
}

-(void)positionHighlight {
	if (highlightedLetterCount > 0) {
		NezStrectableRectangle2D *outline = [gameState getSelectionRectangleForLine:lineIndex];
		float size = gameState.blockLength;
		float wordWidth = highlightedLetterCount*size;
		LetterBlock *lb = [letterList objectAtIndex:[letterList count]-highlightedLetterCount];
		[outline setRectWidth:wordWidth+size*0.10 andHeight:size*1.15];
		outline.modelMatrix->w.x = lb.modelMatrix->w.x+wordWidth/2.0-size/2.0;
		outline.modelMatrix->w.y = lb.modelMatrix->w.y;
		outline.modelMatrix->w.z = lb.modelMatrix->w.z;
	}
}

-(void)positionHighlightWithTapPoint:(CGPoint)point TappedBlock:(LetterBlock*)tappedBlock {
	highlightedLetterCount = 0;
	int count = [letterList count];
	if(count > 0) {
		float zIndex = LINE_Z+gameState.blockDepth/2.0;
		OpenGLES2Graphics *g = [OpenGLES2Graphics instance];
		vec4 worldPoint = [g getWorldPointWithScreenX:point.x ScreenY:point.y WorldZ:zIndex];
		
		LetterBlock *lb = nil;
		int index = 0;
		int wordCount = -1;
		for (LetterBlock *checkBlock in letterList) {
			if (checkBlock == tappedBlock || [checkBlock containsPoint:worldPoint]) {
				lb = checkBlock;
				wordCount = count - index;
				break;
			}
			index++;
		}
		if (lb != nil && wordCount > 3) {
			highlightedLetterCount = wordCount;
			if (isHighlighted) {
				[self startHighlightAnimationFrom:1.0 To:0.0 FinishSelector:@selector(animateDeHighlightDidStop:)];
			} else {
				[self positionHighlight];
				isHighlighted = YES;
				[self startHighlightAnimationFrom:0.0 To:1.0 FinishSelector:@selector(animateHighlightDidStop:)];
			}
		}
	}
	
}

-(void)animateHighlight:(NezAnimation*)ani {
	float alpha = *ani->newData;
	[[gameState getSelectionRectangleForLine:lineIndex] setMix:alpha];
}

-(void)animateHighlightDidStop:(NezAnimation*)ani {
	[highlightAnimation release];
	highlightAnimation = nil;
}

-(void)animateDeHighlightDidStop:(NezAnimation*)ani {
	[highlightAnimation release];
	highlightAnimation = nil;
	if (highlightedLetterCount > 0) {
		[self positionHighlight];
		[self startHighlightAnimationFrom:0.0 To:1.0 FinishSelector:@selector(animateHighlightDidStop:)];
	}
}

-(void)startHighlightAnimationFrom:(float)from To:(float)to FinishSelector:(SEL)didFinish {
	if (highlightAnimation != nil) {
		[[NezAnimator instance] removeAnimation:highlightAnimation];
		[highlightAnimation release];
	}
	highlightAnimation = [[NezAnimation alloc] initFloatWithFromData:from ToData:to Duration:0.25 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateHighlight:) DidStopSelector:didFinish];
	[[NezAnimator instance] addAnimation:highlightAnimation];
}

-(BOOL)getNeedsHighlight {
	if (self.highlightedLetterCount < self.inputLength.prefixLength && self.isWord) {
		return YES;
	}	
	return NO;
}

-(PrevInput*)getPrevInput {
	return prevInputArray;
}

-(int)getCount {
	return [letterList count];
}

-(void)setInputType:(NezAletterationDictionaryInputType)t {
	type = t;
	int charCount = self.count;
	if (charCount > 0) {
		prevInputArray[charCount-1].type = t;
	}
}

-(void)setInputLength:(InputLength)iLen {
	inputLength = iLen;
	int charCount = self.count;
	if (charCount > 0) {
		prevInputArray[charCount-1].place = iLen;
	}
}

-(void)reset {
	[letterList removeAllObjects];
	selectedBlock = nil;
	
	for (int i=0; i<TOTAL_LETTER_COUNT; i++) {
		prevInputArray[i].place.prefixIndex = 0;
		prevInputArray[i].place.prefixLength = 0;
		prevInputArray[i].type = NEZ_DIC_INPUT_ISNOT_SET;
	}
	inputLength.prefixIndex = 0;
	inputLength.prefixLength = 0;
	type = NEZ_DIC_INPUT_ISNOT_SET;
	
	if (highlightAnimation) {
  		[highlightAnimation release];
		highlightAnimation = nil;
	}
	//Auto Scroll line back to the right
	if (shiftOffset != 0) {
		animatingLineStretchDistance = 0.0f;
		NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:-shiftOffset ToData:0 Duration:0.5 EasingFunction:&easeInOutCubic CallbackObject:self UpdateSelector:@selector(animateLineStretch:) DidStopSelector:@selector(animateLineStretchDidStop:)];
		shiftOffset = 0;
		[[NezAnimator instance] addAnimation:ani];
	}
}

-(void)dealloc {
	//NSLog(@"dealloc:DisplayLine");
	if (highlightAnimation) {
  		[highlightAnimation release];
		highlightAnimation = nil;
	}
	[letterList removeAllObjects];
	[letterList release];
	[super dealloc];
}

@end
