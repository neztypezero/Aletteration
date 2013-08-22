//
//  DisplayLine.h
//  Aletteration
//
//  Created by David Nesbitt on 2/7/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezRectangle2D.h"
#import "NezAletterationSQLiteDictionary.h"
#import "NezVertexArray.h"
#import "AletterationGameState.h"

@class NezAnimation;
@class LetterBlock;
@class NezVertexArray;
@class NezStrectableRectangle2D;

typedef struct PrevInput {
	NezAletterationDictionaryInputType type;
	InputLength place;
} PrevInput;

@interface DisplayLine : NezRectangle2D {
	NezAletterationDictionaryInputType type;
	InputLength inputLength;
	NSMutableArray *letterList;
	LetterBlock *selectedBlock;
	int shiftOffset;
	float lineDragDistance;
	float previoiusLineDistance;
	float animatingLineStretchDistance;
	float animatingLineSlideDistance;
	int lineIndex;
	
	BOOL isHighlighted;
	int highlightedLetterCount;
	NezAnimation *highlightAnimation;
	
	vec3 startMidPoint;
	
	NezAnimation *slideAnimation;
	unsigned int animatingSoundSource;
	
	AletterationGameState *gameState;
	
	PrevInput prevInputArray[TOTAL_LETTER_COUNT];
}

@property(nonatomic, assign, setter=setInputType:) NezAletterationDictionaryInputType type;
@property(nonatomic, assign, setter=setInputLength:) InputLength inputLength;
@property(nonatomic, readonly, getter=getCount) int count;
@property(nonatomic, assign) vec3 startMidPoint;
@property(nonatomic, readonly) NSMutableArray *letterList;
@property(nonatomic, readonly) int lineIndex;
@property(nonatomic, retain) LetterBlock *selectedBlock;
@property(nonatomic, readonly, getter=getIsWord) BOOL isWord;
@property(nonatomic, readonly) BOOL isHighlighted;
@property(nonatomic, readonly, getter=getNeedsHighlight) BOOL needsHighlight;
@property(nonatomic, readonly) int highlightedLetterCount;
@property(nonatomic, readonly, getter=getPrevInput) PrevInput *prevInput;

+(color4uc)COLOR_LINE;
	
-(id)initWithLineIndex:(int)index midPoint:(vec3)pos width:(float)w height:(float)h VertexList:(NezVertexArray*)vertexArray;

-(void)setBoxPositions;

-(void)setLetterColors;
-(void)startFadeInAnimationWithDuration:(float)duration;
-(void)startFadeOutAnimationWithDuration:(float)duration;

-(vec3)getNextLetterPos;
-(vec3)getNextLetterPosForCharIndex:(int)index;

-(void)touchesBegan:(NSSet*)touches withView:(UIView*)view;
-(void)touchesMoved:(NSSet*)touches withView:(UIView*)view;
-(void)touchesEnded:(NSSet*)touches withView:(UIView*)view;

-(void)updatePitch:(float)timeElapsed;

-(NSArray*)removeRange:(NSRange)range;

-(void)positionHighlightWithTapPoint:(CGPoint)point TappedBlock:(LetterBlock*)tappedBlock;
-(void)startHighlightAnimationFrom:(float)from To:(float)to FinishSelector:(SEL)didFinish;
-(void)hideHighlight;

-(void)reset;

@end
