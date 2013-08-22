//
//  LetterBlock.h
//  Aletteration
//
//  Created by David Nesbitt on 1/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"
#import "NezGeometry.h"
#import "NezVertexArray.h"

#define LETTER_SQUARE_VERTEX_COUNT 4

@class AletterationGameState;

@interface LetterBlock : NezGeometry {
	char letter;
	
	id animationStopDelegate;
	SEL animationStopSelector;
	
	Vertex letterSquareVertexList[LETTER_SQUARE_VERTEX_COUNT];
	
	AletterationGameState *gameState;
}
-(id)initWithVertexArray:(NezVertexArray*)vertexArray letter:(char)blockLetter modelMatrix:(mat4)mat color:(color4uc)c uv:(vec4)uv;

-(void)startFromBoxAnimation:(float)delay;

-(void)animateMatrix:(mat4*)mat withDuration:(float)duration;
-(void)animateMatrix:(mat4*)mat withDuration:(float)duration afterDelay:(float)delay;

-(void)animateColorMix:(float)mix withDuration:(float)duration;

-(void)setUV:(vec4)uv;

@property (nonatomic, retain) id animationStopDelegate;
@property (nonatomic, assign) SEL animationStopSelector;

@property (nonatomic, assign, readonly) char letter;
@property (nonatomic, assign) int lineIndex;
@property (nonatomic, assign) mat4 lineMat;

@end
