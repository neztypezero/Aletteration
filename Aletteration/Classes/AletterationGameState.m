//
//  AletterationGameState.m
//  Aletteration
//
//  Created by David Nesbitt on 2/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AletterationGameState.h"
#import "OpenGLES2Graphics.h"
#import "NezAletterationSQLiteDictionary.h"
#import "ScoreBoard.h"
#import "DisplayLine.h"
#import "AletterationBox.h"
#import "LetterStack.h"
#import "LetterBlock.h"
#import "NezOpenAL.h"
#import "NezCubicBezier.h"
#import "NezVertexArray.h"
#import "NezVertexArrayArray.h"
#import "NezRectangle2D.h"
#import "Math.h"
#import "matrix.h"
#import "NezObjGeometry.h"
#import "NetworkUtilities.h"
#import "AnimatedCamera.h"
#import "NezAnimation.h"
#import "NezAnimator.h"
#import "NezStrectableRectangle2D.h"
#import "FireWorksGlobe.h"

#import "AletterationPreferences.h"

#define LETTER_TEX_SIZE (1.0f/8.0f) 
#define LETTER_DEPTH_FACTOR (1.0f/16.0f) 

#define LOCAL_ADDRESS @"localhost"

#define STATE_GAME_SAVED @"GAME_SAVED"

static float LINE_WIDTH;
static float LINE_HEIGHT;

static float BOX_LENGTH;

static const color4uc COLOR_BLACK = {0, 0, 0, 255};
static const color4uc COLOR_WHITE = {255, 255, 255, 255};
static const color4uc COLOR_TRANSPARENT = {0, 0, 0, 0};
static color4uc COLOR_LETTER = {0, 100, 255, 255};
static color4uc COLOR_SELECTION = {0, 100, 255, 120};
static const color4uc COLOR_SCOREBOX = {10, 200, 200, 255};
static const color4uc COLOR_IS_NOTHING = {150, 150, 150, 255};
static const color4uc COLOR_IS_PREFIX = {0, 255, 0, 255};
static const color4uc COLOR_IS_WORD = {255, 0, 0, 255};
static const color4uc COLOR_IS_BOTH = {255, 0, 255, 255};

static vec4 ZERO_ZERO_ZERO = { 0,0,0,0 };

typedef struct WordState {
	int longestPrefix;
	int longestWord;
} WordState;

typedef enum {
	TEX_UNIT_LETTERS=0,
	TEX_UNIT_NUMBERS,
	TEX_UNIT_SCORES,
	TEX_UNIT_WOOD,
	TEX_UNIT_BOX,
	TEX_UNIT_BACKGROUND_GRADIENT,
	TEX_UNIT_BACKGROUND_RAYS,
	TEX_UNIT_GLOW,
} TEX_UNIT_ENUM;

static const int LETTER_BAG[] = {
	5, 2, 4, 4, 10, 2, 3, 4, 5, 1, 2, 4, 3,
	5, 5, 3, 1, 5,  5, 5, 4, 2, 2, 1, 2, 1,
};

@implementation NezAletterationGameStateRetiredWord

+(NezAletterationGameStateRetiredWord*)retireWord {
	return [[NezAletterationGameStateRetiredWord alloc] init];
}

+(NezAletterationGameStateRetiredWord*)retireWordWithLineIndex:(int32_t)lineIndex andRange:(NSRange)range {
	return [[NezAletterationGameStateRetiredWord alloc] initWithLineIndex:lineIndex andRange:range];
}

-(id)init {
	if ((self = [super init])) {
		self.lineIndex = -1;
		self.range = NSMakeRange(-1, -1);
	}
	return self;
}

-(id)initWithLineIndex:(int32_t)lineIndex andRange:(NSRange)range {
	if ((self = [super init])) {
		self.lineIndex = lineIndex;
		self.range = range;
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		self.lineIndex = [decoder decodeInt32ForKey:@"lineIndex"];
		self.range = [[decoder decodeObjectForKey:@"range"] rangeValue];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeInt32:self.lineIndex forKey:@"lineIndex"];
	[encoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
}

@end

@implementation NezAletterationGameStateTurn

+(NezAletterationGameStateTurn*)turn {
	return [[NezAletterationGameStateTurn alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		self.lineIndex = -1;
		self.retiredWordList = [NSMutableArray array];
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		self.lineIndex = [decoder decodeInt32ForKey:@"lineIndex"];
		self.retiredWordList = [decoder decodeObjectForKey:@"retiredWordList"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeInt32:self.lineIndex forKey:@"lineIndex"];
	[encoder encodeObject:self.retiredWordList forKey:@"retiredWordList"];
}

-(void)retireWordForLineIndex:(int32_t)lineIndex andRange:(NSRange)range {
	NezAletterationGameStateRetiredWord *retiredWord = [NezAletterationGameStateRetiredWord retireWordWithLineIndex:lineIndex andRange:range];
	[self.retiredWordList addObject:retiredWord];
}

@end

@implementation NezAletterationGameStateObject

+(id)stateObject {
	return [[NezAletterationGameStateObject alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		int length = TOTAL_LETTER_COUNT+1;
		char letters[length];
		self.letterData = [NSMutableData dataWithBytesNoCopy:letters length:length freeWhenDone:NO];
		self.turnStack = [NSMutableArray arrayWithCapacity:TOTAL_LETTER_COUNT];
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		self.letterData = [decoder decodeObjectForKey:@"letterData"];
		self.turnStack = [decoder decodeObjectForKey:@"turnStack"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.letterData forKey:@"letterData"];
	[encoder encodeObject:self.turnStack forKey:@"turnStack"];
}

-(char*)getLetterList {
	return (char*)self.letterData.bytes;
}

-(NezAletterationGameStateTurn*)getCurrentTurn {
	return self.turnStack.lastObject;
}

-(void)reset {
 	NSMutableArray *letterList = [NSMutableArray arrayWithCapacity:TOTAL_LETTER_COUNT];
	const int *letterBag = [AletterationGameState getLetterBag];
	for (int i=0; i<26; i++) {
		for (int j=0; j<letterBag[i]; j++) {
			[letterList addObject:[NSNumber numberWithChar:'a'+i]];
		}
	}
	int index = 0;
	char previousLetter = '\0';
	int sameCount = 0;
	char *letterArray = self.letterList;
	
	while (letterList.count > 0) {
		int randomIndex = (int)(randomNumber()*letterList.count);
		NSNumber *letter = [letterList objectAtIndex:randomIndex];
		char currentLetter = [letter charValue];
		if (previousLetter != currentLetter || sameCount > 25) {
			[letterList removeObjectAtIndex:randomIndex];
			letterArray[index++] = [letter charValue];
			previousLetter = currentLetter;
			sameCount = 0;
		} else {
			sameCount++;
		}
	}
	letterArray[index] = '\0';
	[self.turnStack removeAllObjects];
}

-(char)getNextLetter {
	if (self.currentTurn && self.turnStack.count > 0) {
		if (self.currentTurn.lineIndex == -1) {
			return self.letterList[self.turnStack.count-1];
		}
	}
	return self.letterList[self.turnStack.count];
}

-(void)pushNextTurn {
	NezAletterationGameStateTurn *nextTurn = [NezAletterationGameStateTurn turn];
	if (self.currentTurn == nil || (self.currentTurn && self.currentTurn.lineIndex != -1)) {
		[self.turnStack addObject:nextTurn];
	}
}

-(void)retireWordForLineIndex:(int32_t)lineIndex andRange:(NSRange)range {
	[self.currentTurn retireWordForLineIndex:lineIndex andRange:range];
}

-(void)save {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[defaults setObject:data forKey:PREF_PLAYER_GAME_STATE];
	[defaults synchronize];
}

@end

static AletterationGameState *g_GameState;

@interface AletterationGameState (private)

-(void)attachVboToVertexArrays:(NezVertexArrayArray*)vertexArrayArray DrawType:(unsigned int)type;
-(void)drawVertexArrays:(NezVertexArrayArray*)vertexArrayArray;

-(void)loadMusic;
-(void)loadSounds;
-(void)setupAllLines;

-(void)getLetterCounts:(int[LETTER_COUNT])letters Word:(char*)word;

-(void)remoteRemoveWordFromLine:(int)lineIndex wordLength:(int)wordLength;

-(void)setupAllLinesFast;
-(void)setupCurrentWordFastForLine:(int)lineIndex;

@end

@implementation AletterationGameState 

@synthesize soundPlayer;
@synthesize sounds;
@synthesize letterCarton;
@synthesize scoreBoard;
@synthesize gameServer;
@synthesize remoteConnection;
@synthesize currentLetter;
@synthesize currentLetterIndex;
@synthesize currentTurn;
@synthesize playerInfoList;
@synthesize glowRectangle;
@synthesize letterColor;
@synthesize resetGameDelegate;
@synthesize resetGameSelector;
@synthesize musicEnabled;
@synthesize musicVolume;
@synthesize soundEnabled;
@synthesize soundVolume;
@synthesize letterList;

@synthesize letterBlockList;
@synthesize inGameLetterList;

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_GameState = [[AletterationGameState alloc] init];
    }
}

+(const int*)getLetterBag {
	return LETTER_BAG;
}

+(vec3)getDefaultTarget {
	static const vec3 DEFAULT_TARGET = {0.0f, 0.0f, 0.0f};
	return DEFAULT_TARGET;
}

+(vec3)getDefaultEye {
	static const vec3 DEFAULT_EYE = { 0.0f, 0.0f, 10.0f };
	return DEFAULT_EYE;
}

+(vec3)getDefaultUpVector {
	static const vec3 DEFAULT_UP_VECTOR = {0.0f, 1.0f, 0.0f};
	return DEFAULT_UP_VECTOR;
}

+(vec3)getInitialTarget {
	static vec3 v = {0.0f, 50.0f, 40.0f};
	return v;
}

+(vec3)getInitialEye {
	static vec3 v = {0.0f, -15.0f, 40.0f};
	return v;
}

+(vec3)getInitialUpVector {
	static vec3 v = {0.0f, 0.0f, 1.0f};
	return v;
}

-(float)getBrightnessWithColor:(color4uc)c {
	float r = ((float)c.r/255.0f);
	float g = ((float)c.g/255.0f);
	float b = ((float)c.b/255.0f);

	return [self getBrightnessWithRed:r Green:g Blue:b];
}

-(float)getBrightnessWithRed:(float)r Green:(float)g Blue:(float)b {
	return ((r * 299.0) + (g * 587.0) + (b * 114.0)) / 1000.0;
}

-(float)setLetterRed:(float)r Green:(float)g Blue:(float)b {
	COLOR_LETTER.r = (unsigned char)(r*255.0f);
	COLOR_LETTER.g = (unsigned char)(g*255.0f);
	COLOR_LETTER.b = (unsigned char)(b*255.0f);
	
	float brightness = [self getBrightnessWithRed:r Green:g Blue:b];
	
	for(LetterBlock *lb in letterBlockList) {
		color4uc c = lb.color;
		if (c.r != COLOR_IS_NOTHING.r || c.g != COLOR_IS_NOTHING.g || c.b != COLOR_IS_NOTHING.b || c.a != COLOR_IS_NOTHING.a) {
			[lb setColor:COLOR_LETTER];
			vec4 uv = [self getTextureCoordinatesForLetter:lb.letter IsWhite:brightness<0.5];
			[lb setUV:uv];
		}
	}
	[letterCarton setColor:COLOR_LETTER];
	
	COLOR_SELECTION.r = COLOR_LETTER.r;
	COLOR_SELECTION.g = COLOR_LETTER.g;
	COLOR_SELECTION.b = COLOR_LETTER.b;
	COLOR_SELECTION.a = 120;
	
	return brightness;
}

-(color4uc)getLetterColor {
	return COLOR_LETTER;
}

-(color4uc)getSelectionColor {
	return COLOR_SELECTION;
}

+(AletterationGameState*)instance {
	return(g_GameState);
}

-(float)getLineWidth {
	return LINE_WIDTH;
}

-(float)getLineHeight {
	return LINE_HEIGHT;
}

-(float)getBlockLength {
	return BOX_LENGTH;
}

-(float)getBlockDepth {
	return BOX_LENGTH*LETTER_DEPTH_FACTOR;
}

-(float)getScreenWidth {
	return ZERO_ZERO_ZERO.x*2;
}

-(float)getScreenHeight {
	return ZERO_ZERO_ZERO.y*2;
}

-(float)getScreenHalfWidth {
	return ZERO_ZERO_ZERO.x;
}

-(float)getScreenHalfHeight {
	return ZERO_ZERO_ZERO.y;
}

-(id)init {
	if ((self = [super init])) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData *stateData = [defaults objectForKey:PREF_PLAYER_GAME_STATE];
		if (stateData != nil) {
			self.stateObject = [NSKeyedUnarchiver unarchiveObjectWithData:stateData];
		} else {
			self.stateObject = nil;
		}
		backgroundMusicPlayer = nil;
        endMusicPlayer = nil;
		letterBlockList = nil;
		gameServer = nil;
		remoteConnection = nil;
		playerInfoList = nil;
		inGameLetterList = nil;
		letterList = nil;
		completedWordBlockList = nil;
		
		for (char i='a'; i<='z'; i++) {
			letterStack[i-'a'] = nil;
		}
		
		[self resetState];
		[self resetNetwork];
		
		float x = 0.0f, y = 0.0f; 
		for (int i=0; i<UV_CHAR_COUNT; i++) {
			uvTable[i].z = x;
			uvTable[i].y = y;
			x += LETTER_TEX_SIZE;
			uvTable[i].x = x;
			uvTable[i].w = y+LETTER_TEX_SIZE;
			if (x+LETTER_TEX_SIZE > 1.0f) {
				x = 0.0f;
				y += LETTER_TEX_SIZE;
			}
		}
		backgroundArrayArray = [[NezVertexArrayArray alloc] init]; 
		litVertexArrayArray = [[NezVertexArrayArray alloc] init];
		unlitTextureVertexArrayArray = [[NezVertexArrayArray alloc] init];
		glowVertexArrayArray = [[NezVertexArrayArray alloc] init];
		unlitColorVertexArrayArray = [[NezVertexArrayArray alloc] init];
		noZBufferVertexArrayArray = [[NezVertexArrayArray alloc] init];
		colorBurnVertexArrayArray = [[NezVertexArrayArray alloc] init];
		
		fireworksArrayArray = [[NezVertexArrayArray alloc] init];
	}
	return self;
}

-(void)resetLocalPlayerInfo {
	self.localPlayerInfo = [AletterationPlayerInfo blankInfo];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	self.localPlayerInfo.name = [defaults stringForKey:PREF_PLAYER_NAME];
	if (self.localPlayerInfo.name == nil) {
		self.localPlayerInfo.name = @"Anonymous";
	}
	self.localPlayerInfo.ip = LOCAL_ADDRESS;
    
    NSData *portraitData = [defaults dataForKey:PREF_PLAYER_PORTRAIT];
    int orientation = [defaults integerForKey:PREF_PLAYER_PORTRAIT_ORIENTATION];

	if (portraitData != nil) {
        CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)portraitData);
        CGImageRef image = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        self.localPlayerInfo.portrait = [UIImage imageWithCGImage:image scale:1.0 orientation:orientation];
        CGImageRelease(image);
        CGDataProviderRelease(imgDataProvider);
	} else {
		self.localPlayerInfo.portrait = [UIImage imageNamed:@"profile.png"];	
	}
}


-(void)resetPlayerInfoList {
	[playerInfoList removeAllObjects];
	[self resetLocalPlayerInfo];
}

-(void)resetNetwork {
/*	
	[gameServer stop];
	[gameServer release];
	gameServer = nil;
	
	[remoteConnection stop];
	[remoteConnection release];
	remoteConnection = nil;
*/
	[playerInfoList release];
	playerInfoList = [[NSMutableDictionary alloc] init];
	
	[self resetLocalPlayerInfo];
}

-(void)resetState {
	currentTurn = -1;
	currentLetter = -1;
	currentLetterIndex = -1;
	
	for (char i='a'; i<='z'; i++) {
		if (letterStack[i-'a'] != nil) {
			[letterStack[i-'a'] reset];
		}
	}
	
	for (int i=0; i<LINE_COUNT; i++) {
		if (displayLines[i] != nil) {
			[displayLines[i] reset];
		}
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSNumber *red = (NSNumber*)[defaults objectForKey:PREF_PLAYER_LETTER_COLOR_RED];
	NSNumber *green = (NSNumber*)[defaults objectForKey:PREF_PLAYER_LETTER_COLOR_GREEN];
	NSNumber *blue = (NSNumber*)[defaults objectForKey:PREF_PLAYER_LETTER_COLOR_BLUE];
	
	if (red != nil && green != nil && blue != nil) {
		[self setLetterRed:[red floatValue] Green:[green floatValue] Blue:[blue floatValue]];
	}

	NSNumber *value;
	if((value = [defaults objectForKey:PREF_PLAYER_MUSIC_ENABLED]) != nil) {
		musicEnabled = [value boolValue];
	} else {
		musicEnabled = YES;
	}
	if((value = [defaults objectForKey:PREF_PLAYER_MUSIC_VOLUME]) != nil) {
		musicVolume = [value floatValue];
	} else {
		musicVolume = 1.0;
	}
	if((value = [defaults objectForKey:PREF_PLAYER_SOUND_ENABLED]) != nil) {
		soundEnabled = [value boolValue];
	} else {
		soundEnabled = YES;
	}
	if((value = [defaults objectForKey:PREF_PLAYER_SOUND_VOLUME]) != nil) {
		soundVolume = [value floatValue];
	} else {
		soundVolume = 1.0;
	}
		
	[inGameLetterList release];
	inGameLetterList = [[NSMutableArray arrayWithCapacity:TOTAL_LETTER_COUNT] retain];
	
	for (int i=0; i<LINE_COUNT; i++) {
		lines[i].line[0] = '\0';
		lines[i].letterCount = 0;
	}
	[letterList release];
	letterList = [[NSMutableArray alloc] initWithCapacity:90];
	for (int i=0; i<LETTER_COUNT; i++) {
		letterBag[i] = LETTER_BAG[i];
		for (int j=0; j<LETTER_BAG[i]; j++) {
			[letterList addObject:[NSNumber numberWithChar:'a'+i]];
		}
	}
	[completedWordBlockList release];
	completedWordBlockList = [[NSMutableArray arrayWithCapacity:25] retain];
	
	[scoreBoard reset];
	
	self.selectedBlock = nil;
	
	self.resetGameDelegate = nil;
	self.resetGameSelector = nil;
}

-(void)setupStateObject {
	if (self.stateObject == nil) {
		self.stateObject = [NezAletterationGameStateObject stateObject];
		[self.stateObject reset];
	} else {
		if (self.stateObject.turnStack.count == TOTAL_LETTER_COUNT) {
			[self.stateObject.turnStack removeLastObject];
		}
		for (NezAletterationGameStateTurn *turn in self.stateObject.turnStack) {
			if (turn.retiredWordList.count > 0) {
				for (NezAletterationGameStateRetiredWord *retiredWord in turn.retiredWordList) {
					LineState *lineStatePtr = &lines[retiredWord.lineIndex];
					char *wordPtr = &lineStatePtr->line[lineStatePtr->letterCount-retiredWord.range.length];
//					InputType type = [self checkWord:wordPtr];
//					if (type == INPUT_ISWORD || type == INPUT_ISBOTH) {
						DisplayLine *line = displayLines[retiredWord.lineIndex];
						NSArray *removedLetterBlocks = [displayLines[retiredWord.lineIndex] removeRange:retiredWord.range];
						
						[[self getLocalPlayerInfo] completeWord:retiredWord.lineIndex wordLength:retiredWord.range.length];
						
						wordPtr[0] = '\0';
						lineStatePtr->letterCount -= retiredWord.range.length;
						
						if (lineStatePtr->letterCount > 0) {
							line.inputLength = line.prevInput[lineStatePtr->letterCount-1].place;
						} else {
							InputLength length = { 0, lineStatePtr->letterCount };
							line.inputLength = length;
						}
						int count = [removedLetterBlocks count];
						if (count > 0) {
							vec3 midPoint = [self.scoreBoard getScoreBoardPoint:[self.completedWordBlockList count]];
							float blockLength = self.blockLength;
							for (LetterBlock *lb in removedLetterBlocks) {
								[lb setBoxWithMidPoint:&midPoint];
								midPoint.x += blockLength;
							}
							[self.completedWordBlockList addObject:removedLetterBlocks];
						}
//					}
				}
			}
			if (turn.lineIndex != -1) {
				[self setNextTurn];
				currentLetter = self.stateObject.letterList[self.currentTurn];
				self.selectedBlock = [letterStack[currentLetter-'a'] popLetterBlock];
				[inGameLetterList addObject:self.selectedBlock];

				vec3 pos = [displayLines[turn.lineIndex] getNextLetterPos];
				
				mat4 mat = {
					1,0,0,0,
					0,1,0,0,
					0,0,1,0,
					pos.x,pos.y,pos.z,1,
				};
				self.selectedBlock.modelMatrix = &mat;
				[self.selectedBlock setBoundingPoints];

				letterBag[currentLetter-'a']--;
				LineState *lineStatePtr = &lines[turn.lineIndex];
				lineStatePtr->line[lineStatePtr->letterCount] = currentLetter;
				lineStatePtr->letterCount++;
				lineStatePtr->line[lineStatePtr->letterCount] = '\0';
				displayLines[turn.lineIndex].selectedBlock = nil;
				[displayLines[turn.lineIndex].letterList addObject:self.selectedBlock];
				[self setupAllLinesFast];
				[self.localPlayerInfo addLetterToLine:turn.lineIndex forTurn:self.currentTurn];
			}
		}
		self.selectedBlock = nil;
		currentLetter = -1;
	}
}

-(void)setLetterPositionsWithPlayerInfo:(AletterationPlayerInfo*)info {
    int i = 0;
    for (NSMutableArray *line in info.lineList) {
        DisplayLine *displayLine = displayLines[i];
        int j=0;
        for (NSNumber *index in line) {
            int letterIndex = [index intValue];
            vec3 letterPos = [displayLine getNextLetterPosForCharIndex:j++];
            LetterBlock *letter = [inGameLetterList objectAtIndex:letterIndex];
            [letter setBoxWithMidPoint:&letterPos];
        }
        i++;
    }
}

-(BOOL)updatePlayerInfo:(AletterationPlayerInfo*)info {
	AletterationPlayerInfo *currentInfo = [playerInfoList objectForKey:info.ip];
	if (currentInfo == nil) {
		[playerInfoList setObject:info forKey:info.ip];
		return YES;
	} else if ([info.ip compare:self.localPlayerInfo.ip] != NSOrderedSame) {
		if (info.portrait) currentInfo.portrait = info.portrait;
		if (info.name) currentInfo.name = info.name;
	}
	return NO;
}

-(void)setPlayerList:(NSArray*)playerList {
	//update all the player info
	for (AletterationPlayerInfo *info in playerList) {
		[self updatePlayerInfo:info];
	}
}

-(AletterationPlayerInfo*)getPlayerInfoForIP:(NSString*)ip {
	return [playerInfoList objectForKey:ip];
}

-(void)setLocalPlayerInfo:(AletterationPlayerInfo*)info {
	if (info != nil) {
		[playerInfoList setObject:info forKey:LOCAL_ADDRESS];
	}
}

-(AletterationPlayerInfo*)getLocalPlayerInfo {
	return [playerInfoList objectForKey:LOCAL_ADDRESS];
}

-(AletterationPlayerInfo*)getNextPlayerInfo:(AletterationPlayerInfo*)playerInfo {
    if (playerInfo == nil || [playerInfoList count] < 2) {
        return self.localPlayerInfo;
    } else {
        NSArray *valueArray = [playerInfoList allValues];
        for (int i=0,n=[valueArray count]; i<n; i++) {
            if (playerInfo == [valueArray objectAtIndex:i]) {
                return [valueArray objectAtIndex:(i+1)%n];
            }
        }
    }
    return nil;
}

-(void)loadData {
	graphics = [OpenGLES2Graphics instance];

	lettersTexInfo = [graphics loadTexture:@"LettersTexture"];
	numbersTexInfo = [graphics loadTexture:@"NumbersTexture"];
	scoresTexInfo = [graphics loadTexture:@"ScoresTexture"];
	woodTexInfo = [graphics loadTexture:@"WoodTexture"];
	boxTexInfo = [graphics loadTexture:@"BoxTexture"];
	backgroundGradientTexInfo = [graphics loadTexture:@"BackgroundGradientTexture"];
	backgroundRaysTexInfo = [graphics loadTexture:@"BackgroundRaysTexture"];
	glowTexInfo = [graphics loadTexture:@"GlowTexture"];
	
	[graphics setTexture:lettersTexInfo.name Unit:TEX_UNIT_LETTERS];
	[graphics setTexture:numbersTexInfo.name Unit:TEX_UNIT_NUMBERS];
	[graphics setTexture:scoresTexInfo.name Unit:TEX_UNIT_SCORES];
	[graphics setTexture:woodTexInfo.name Unit:TEX_UNIT_WOOD];
	[graphics setTexture:boxTexInfo.name Unit:TEX_UNIT_BOX];
	[graphics setTexture:backgroundGradientTexInfo.name Unit:TEX_UNIT_BACKGROUND_GRADIENT];
	[graphics setTexture:backgroundRaysTexInfo.name Unit:TEX_UNIT_BACKGROUND_RAYS];
	[graphics setTexture:glowTexInfo.name Unit:TEX_UNIT_GLOW];

	float screenScale = graphics.screenScale;
	float screenWidth = graphics.screenWidth;
	
	float borderHeightPixels = 4.0f*screenScale;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		borderHeightPixels = 6.0f*screenScale;
	}
	
	float x1 = borderHeightPixels;
	float x2 = screenWidth-borderHeightPixels;
	
	vec4 minPoint = [graphics getWorldPointWithPixelX:x1 PixelY:0 WorldZ:LINE_Z];
	vec4 maxPoint = [graphics getWorldPointWithPixelX:x2 PixelY:0 WorldZ:LINE_Z];
	vec4 wPoint2 = [graphics getWorldPointWithPixelX:0 PixelY:0 WorldZ:LINE_Z];
	
	ZERO_ZERO_ZERO.x = fabs(wPoint2.x);
	ZERO_ZERO_ZERO.y = fabs(wPoint2.y);

	vec4 aPoint1 = [graphics getWorldPointWithPixelX:1.0f*screenScale PixelY:1.0f*screenScale WorldZ:LINE_Z];
	vec4 aPoint2 = [graphics getWorldPointWithPixelX:0.0f*screenScale PixelY:0.0f*screenScale WorldZ:LINE_Z];
	float letterStackPixelWidth = aPoint2.y-aPoint1.y;
	
	letterBlockList = [[NSMutableArray alloc] initWithCapacity:TOTAL_LETTER_COUNT];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSNumber *red = (NSNumber*)[defaults objectForKey:PREF_PLAYER_LETTER_COLOR_RED];
	NSNumber *green = (NSNumber*)[defaults objectForKey:PREF_PLAYER_LETTER_COLOR_GREEN];
	NSNumber *blue = (NSNumber*)[defaults objectForKey:PREF_PLAYER_LETTER_COLOR_BLUE];
	float brightness = (([red floatValue] * 299.0) + ([green floatValue] * 587.0) + ([blue floatValue] * 114.0)) / 1000.0;

	NezVertexArray *vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:1000 indexIncrement:2000 TextureUnit:TEX_UNIT_LETTERS] autorelease];
	for (char i='a'; i<='z'; i++) {
		int letterCount = [self getCountForLetter:i];
		if (![vertexArray canHoldMorePaletteEntries:letterCount]) {
			[litVertexArrayArray addVertexArray:vertexArray];
			vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:1000 indexIncrement:2000 TextureUnit:TEX_UNIT_LETTERS] autorelease];
		}
		vec4 uv = [self getTextureCoordinatesForLetter:i IsWhite:brightness<0.5];
		for (int j=0; j<letterCount; j++) {
			LetterBlock *lb = [[[LetterBlock alloc] initWithVertexArray:vertexArray letter:i modelMatrix:IDENTITY_MATRIX color:COLOR_LETTER uv:uv] autorelease];
			[letterBlockList addObject:lb];
		}
	}
	[litVertexArrayArray addVertexArray:vertexArray];
	
	LetterBlock *lb = [letterBlockList objectAtIndex:0];
	BOX_LENGTH = lb.size.h;
	LINE_HEIGHT = BOX_LENGTH;
	LINE_WIDTH = maxPoint.x-minPoint.x;
	
	vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:100 indexIncrement:200 TextureUnit:TEX_UNIT_BOX] autorelease];
	vec3 cartonPos = {0,0,LINE_Z};
	letterCarton = [[AletterationBox alloc] initWithVertexArray:vertexArray LetterList:letterBlockList midPoint:cartonPos boxColor:COLOR_WHITE];
	[litVertexArrayArray addVertexArray:vertexArray];

	vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:2000 indexIncrement:4000 TextureUnit:TEX_UNIT_LETTERS] autorelease];
	vec4 topCorner = [graphics getWorldPointWithPixelX:borderHeightPixels PixelY:borderHeightPixels WorldZ:LINE_Z];
	vec3 pos = {0, topCorner.y-LINE_HEIGHT/2.0, LINE_Z};
	
	float lineSpacer = letterStackPixelWidth;//fabsf(topCorner.y-wPoint2.y)/2.0;
	float stackOffset = letterStackPixelWidth*3;
	float stackSpace = letterStackPixelWidth*3.0f;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		pos.y -= letterStackPixelWidth*3;
		lineSpacer *= 3;
		stackOffset = letterStackPixelWidth*8;
		stackSpace = 0;
	}
	
	for (int i=0; i<LINE_COUNT; i++) {
		displayLines[i] = [[DisplayLine alloc] initWithLineIndex:i midPoint:pos width:LINE_WIDTH height:LINE_HEIGHT VertexList:vertexArray];
		pos.y -= LINE_HEIGHT+lineSpacer;
	}
	[unlitColorVertexArrayArray addVertexArray:vertexArray];

	vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:1000 indexIncrement:2000 TextureUnit:TEX_UNIT_NUMBERS] autorelease];
	size3 lbs = letterCarton.letterBlockSize;
	float startX = -(lbs.w+stackSpace)*6.0;
	vec3 lbP1 = {startX,pos.y-stackOffset,LINE_Z};
	for (char i='a'; i<='z'; i++) {
		letterStack[i-'a'] = [[LetterStack alloc] initWithVertexArray:vertexArray letter:i midPoint:lbP1 size:lbs];
		
		lbP1.x += lbs.w+stackSpace;
		if (i=='m') {
			lbP1.x = startX;
			lbP1.y -= lbs.w*1.75;//+letterStackPixelWidth*2.0f;
		}
	}
	[unlitTextureVertexArrayArray addVertexArray:vertexArray];

	vec3 midPoint = {0.0, 1000.0, 400.0};
	vec3 scale = {2000.0, 2000.0, 1.0};
	MatrixGetScale(&scale, &initialBackgroundScaleMatrix);
	mat4f_LoadXRotation(RADIANS_90_DEGREES, &initialBackgroundRotationMatrix.x.x);

	vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:20 indexIncrement:20 TextureUnit:TEX_UNIT_BACKGROUND_GRADIENT] autorelease];
	backgroundGradientRectangle = [[NezRectangle2D alloc] initWithVertexArray:vertexArray modelMatrix:IDENTITY_MATRIX color:COLOR_LETTER];
	[backgroundGradientRectangle setMix:1.0f];
	MatrixMultiply(&initialBackgroundRotationMatrix, &initialBackgroundScaleMatrix, backgroundGradientRectangle.modelMatrix);
	[backgroundGradientRectangle setBoxWithMidPoint:&midPoint];
	[backgroundGradientRectangle setUVwithU1:0.0 V1:0.0 U2:1.0 V2:1.0];
	[backgroundArrayArray addVertexArray:vertexArray];
	
	vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:20 indexIncrement:20 TextureUnit:TEX_UNIT_BACKGROUND_RAYS] autorelease];
	for (int i=0; i<RAYS_COUNT; i++) {
		backgroundRaysRectangle[i] = [[NezRectangle2D alloc] initWithVertexArray:vertexArray modelMatrix:IDENTITY_MATRIX color:COLOR_LETTER];
		[backgroundRaysRectangle[i] setMix:1.0f];
		MatrixMultiply(&initialBackgroundRotationMatrix, &initialBackgroundScaleMatrix, backgroundRaysRectangle[i].modelMatrix);
		[backgroundRaysRectangle[i] setBoxWithMidPoint:&midPoint];
		[backgroundRaysRectangle[i] setUVwithU1:0.0 V1:0.0 U2:1.0 V2:1.0];
		
		NezAnimation *ani = [[[NezAnimation alloc] initMat4WithFromData:*backgroundRaysRectangle[i].modelMatrix
																  ToData:*backgroundRaysRectangle[i].modelMatrix
																Duration:0.5 
														  EasingFunction:&easeInOutCubic 
														  CallbackObject:self 
														  UpdateSelector:@selector(animateRayMove:) 
														 DidStopSelector:@selector(animateRayMoveDidFinish:)] autorelease];
		ani->updateObject = backgroundRaysRectangle[i];
		[[NezAnimator instance] addAnimation:ani];

	}
	[backgroundArrayArray addVertexArray:vertexArray];
	
	NezVertexArray *scoreBoardVA[] = {
		[[[NezVertexArray alloc] initWithVertexIncrement:128 indexIncrement:128 TextureUnit:TEX_UNIT_NUMBERS] autorelease],
		[[[NezVertexArray alloc] initWithVertexIncrement:128 indexIncrement:128 TextureUnit:TEX_UNIT_SCORES] autorelease],
		[[[NezVertexArray alloc] initWithVertexIncrement:128 indexIncrement:128 TextureUnit:TEX_UNIT_SCORES] autorelease],
		[[[NezVertexArray alloc] initWithVertexIncrement:128 indexIncrement:128 TextureUnit:TEX_UNIT_SCORES] autorelease],
		[[[NezVertexArray alloc] initWithVertexIncrement:128 indexIncrement:128 TextureUnit:TEX_UNIT_SCORES] autorelease],
		[[[NezVertexArray alloc] initWithVertexIncrement:128 indexIncrement:128 TextureUnit:TEX_UNIT_GLOW] autorelease],
	};
	
	scoreBoard = [[ScoreBoard alloc] initWithVertexArray:scoreBoardVA];

	[unlitTextureVertexArrayArray addVertexArray:scoreBoardVA[0]];
	[unlitTextureVertexArrayArray addVertexArray:scoreBoardVA[1]];
	[colorBurnVertexArrayArray addVertexArray:scoreBoardVA[2]];
	[glowVertexArrayArray addVertexArray:scoreBoardVA[3]];
	[glowVertexArrayArray addVertexArray:scoreBoardVA[4]];
	[glowVertexArrayArray addVertexArray:scoreBoardVA[5]];
	
	float xScale = fabs(aPoint2.x)*2.0*8.0;
	float yScale = fabs(aPoint2.y)*2.0*5.0;
	
	vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:20 indexIncrement:20 TextureUnit:TEX_UNIT_WOOD] autorelease];
	woodRectangle = [[NezRectangle2D alloc] initWithVertexArray:vertexArray modelMatrix:IDENTITY_MATRIX color:COLOR_LETTER];
	woodRectangle.modelMatrix->w.x = fabs(aPoint2.x)*2.0;
	[woodRectangle setXScale:xScale YScale:yScale ZScale:1.0];
	[woodRectangle setUVwithU1:0.0 V1:0.0 U2:3.0 V2:1.0];
	[noZBufferVertexArrayArray addVertexArray:vertexArray];
	
	vertexArray = scoreBoardVA[5];
	glowRectangle = [[NezRectangle2D alloc] initWithVertexArray:vertexArray modelMatrix:IDENTITY_MATRIX color:COLOR_LETTER];
	[glowRectangle setMix:0.0f];
	[glowRectangle setXScale:1.35 YScale:1.35 ZScale:1.0];
	[glowRectangle setUVwithU1:0.0 V1:0.0 U2:1.0 V2:1.0];

	vec3 b = {-10000, -10000, 0};
	for (int i=0; i<LINE_COUNT; i++) {
		selectionRectangle[i] = [[NezStrectableRectangle2D alloc] initWithVertexArray:vertexArray];
		[selectionRectangle[i] setMix:0.0];
		[selectionRectangle[i] setBoxWithMidPoint:&b];
	}
	
	for (int i=0; i<FIRE_WORKS_COUNT; i++) {
		vertexArray = [[[NezVertexArray alloc] initWithVertexIncrement:2000 indexIncrement:2000 TextureUnit:TEX_UNIT_SCORES] autorelease];
		FireWorksGlobe *f = [[FireWorksGlobe alloc] initWithVertexArray:vertexArray];
		[fireworksArrayArray addVertexArray:vertexArray];
		fireworksList[i] = f;
	}
	[self attachVboToVertexArrays:backgroundArrayArray DrawType:UNLIT_BLENDED_TEXTURED_TRIANGLES];
	[self attachVboToVertexArrays:litVertexArrayArray DrawType:LIT_TRIANGLES];
	[self attachVboToVertexArrays:unlitTextureVertexArrayArray DrawType:UNLIT_BLENDED_TEXTURED_TRIANGLES];
	[self attachVboToVertexArrays:glowVertexArrayArray DrawType:UNLIT_BLENDED_TEXTURED_TRIANGLES];
	[self attachVboToVertexArrays:unlitColorVertexArrayArray DrawType:UNLIT_BLENDED_COLORED_TRIANGLES];
	[self attachVboToVertexArrays:noZBufferVertexArrayArray DrawType:UNLIT_TEXTURED_TRIANGLES];
	[self attachVboToVertexArrays:colorBurnVertexArrayArray DrawType:UNLIT_BLENDED_COLOR_BURNED_TRIANGLES];
	
	[self attachVboToVertexArrays:fireworksArrayArray DrawType:FIREWORKS_POINT_SPRITES];
	
	for (int i=0; i<LINE_COUNT; i++) {
		[displayLines[i] setColor:[DisplayLine COLOR_LINE]];
		[displayLines[i] setMix:0.0];
	}
}

-(NezStrectableRectangle2D*)getSelectionRectangleForLine:(int)lineIndex {
	return selectionRectangle[lineIndex];
}

-(void)animateRayMove:(NezAnimation*)ani {
	NezRectangle2D *rec = ani->updateObject;
	rec.modelMatrix = (mat4*)ani->newData;
}

-(void)animateRayMoveDidFinish:(NezAnimation*)ani {
	NezRectangle2D *rec = ani->updateObject;
	
	mat4 rotation, mat;
	mat4f_LoadZRotation((randomNumber()-0.5)*(RADIANS_PER_DEGREE*0.005), &rotation.x.x);
	
	MatrixMultiply(backgroundGradientRectangle.modelMatrix, &rotation, &mat);
	
	ani = [[[NezAnimation alloc] initMat4WithFromData:*rec.modelMatrix
											   ToData:mat
											 Duration:1.0 
									   EasingFunction:&easeInOutCubic
									   CallbackObject:self 
									   UpdateSelector:@selector(animateRayMove:)
									  DidStopSelector:@selector(animateRayMoveDidFinish:)] autorelease];
	ani->updateObject = rec;
	[[NezAnimator instance] addAnimation:ani];
}

-(void)attachVboToVertexArrays:(NezVertexArrayArray*)vertexArrayArray DrawType:(unsigned int)type {
	int vCount = vertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[vertexArrayArray->vertexArrayList[i] attachVboWithDrawType:type];
	}
}

-(SoundFiles*)getLoadedSounds {
	return &loadedSounds;
}

-(void)loadMusic {
	if (backgroundMusicPlayer == nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSNumber *value;
		if((value = [defaults objectForKey:PREF_PLAYER_MUSIC_ENABLED]) != nil) {
			musicEnabled = [value boolValue];
		} else {
			musicEnabled = YES;
		}
		if((value = [defaults objectForKey:PREF_PLAYER_MUSIC_VOLUME]) != nil) {
			musicVolume = [value floatValue];
		} else {
			musicVolume = 1.0;
		}
		
		musicInterupted = NO;
		
		// Set up the audio session
		// See handy chart on pg. 55 of the Audio Session Programming Guide for what the categories mean
		// Not absolutely required in this example, but good to get into the habit of doing
		// See pg. 11 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
		NSError *setCategoryError = nil;
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
		
		// Create audio player with background music
		NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"bgMusic" ofType:@"m4a" inDirectory:@"Music"];
		NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
		NSError *error;
		backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
		[backgroundMusicPlayer setDelegate:self];  // We need this so we can restart after interruptions
		[backgroundMusicPlayer setNumberOfLoops:-1];	// Negative number means loop forever
        
		NSString *endMusicPath = [[NSBundle mainBundle] pathForResource:@"endMusic" ofType:@"m4a" inDirectory:@"Music"];
		NSURL *endMusicURL = [NSURL fileURLWithPath:endMusicPath];
        endMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:endMusicURL error:&error];
		[endMusicPlayer setNumberOfLoops:0];
		
		[self performSelectorOnMainThread:@selector(tryPlayMusic) withObject:nil waitUntilDone:NO];
	}
}

-(void)setMusicVolume:(float)volume {
	musicVolume = volume;
	if (backgroundMusicPlaying) {
		[backgroundMusicPlayer setVolume:musicVolume];
        [endMusicPlayer setVolume:musicVolume];
	}
}

-(void)setMusicEnabled:(BOOL)isEnabled {
	if (musicEnabled != isEnabled) {
		musicEnabled = isEnabled;
		if (musicEnabled) {
			[self tryPlayMusic];
		} else if (backgroundMusicPlaying) {
			[self stopMusic];
		}
	}
}

-(void)stopMusic {
	if (backgroundMusicPlaying) {
		[backgroundMusicPlayer stop];
		[backgroundMusicPlayer setCurrentTime:0];
		backgroundMusicPlaying = NO;
	}
}

-(void)playMusic:(AVAudioPlayer*)player {
    [player setVolume:musicVolume];
    [player prepareToPlay];
    [player play];
}

-(void)tryPlayMusic {
	// Check to see if iPod music is already playing
	UInt32 propertySize = sizeof(otherMusicIsPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherMusicIsPlaying);
	
	// Play the music if no other music is playing and we aren't playing already
	if (otherMusicIsPlaying != 1 && !backgroundMusicPlaying && musicEnabled) {
        [self playMusic:backgroundMusicPlayer];
		backgroundMusicPlaying = YES;
	}
}

-(void)tryPlayEndMusic {
    if (backgroundMusicPlaying) {
        float s = musicVolume;
        NezAnimation *ani = [[NezAnimation alloc] initFloatWithFromData:s ToData:0 Duration:s EasingFunction:&easeOutCubic CallbackObject:self UpdateSelector:@selector(fadeMusic:) DidStopSelector:@selector(fadeMusicEnd:)];
        [[NezAnimator instance] addAnimation:ani];
    }
}

-(void)fadeMusic:(NezAnimation*)ani {
    [backgroundMusicPlayer setVolume:*ani->data];
}

-(void)fadeMusicEnd:(NezAnimation*)ani {
    [self stopMusic];
    [self playMusic:endMusicPlayer];
    [ani release];
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer*)player {
	musicInterupted = YES;
	backgroundMusicPlaying = YES;
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer*)player {
	if (musicInterupted) {
		[self tryPlayMusic];
		musicInterupted = NO;
	}
}

-(void)setSoundVolume:(float)volume {
	soundVolume = volume;
	soundPlayer.listenerGain = soundVolume;
}

-(void)setSoundEnabled:(BOOL)isEnabled {
	if (soundEnabled != isEnabled) {
		soundEnabled = isEnabled;
		soundPlayer.isEnabled = soundEnabled;
	}
}

-(void)loadSounds {
	soundPlayer = [[NezOpenAL alloc] init];

	loadedSounds.intro = [soundPlayer loadSoundEffectWithPathForResource:@"introSound" ofType:@"caf" inDirectory:@"Sounds"]; //Sound of score scounter
	loadedSounds.tileDrop = [soundPlayer loadSoundEffectWithPathForResource:@"tileDrop" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.dblTapWord = [soundPlayer loadSoundEffectWithPathForResource:@"dblTapWord" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.letterUp = [soundPlayer loadSoundEffectWithPathForResource:@"letterUp" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.letterDown = [soundPlayer loadSoundEffectWithPathForResource:@"letterDown" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.touchLetter = [soundPlayer loadSoundEffectWithPathForResource:@"touchLetter" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.lockLetter = [soundPlayer loadSoundEffectWithPathForResource:@"lockLetter" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.wordMove = [soundPlayer loadSoundEffectWithPathForResource:@"wordMove" ofType:@"caf" inDirectory:@"Sounds"]; //Sound fron box to table
	loadedSounds.fireworks = [soundPlayer loadSoundEffectWithPathForResource:@"fireworks" ofType:@"caf" inDirectory:@"Sounds"]; //Sound of fireworks
	loadedSounds.scoreCounter = [soundPlayer loadSoundEffectWithPathForResource:@"scoreCounter" ofType:@"caf" inDirectory:@"Sounds"]; //Sound of score scounter
	loadedSounds.scoreFadeIn = [soundPlayer loadSoundEffectWithPathForResource:@"scoreFadeIn" ofType:@"caf" inDirectory:@"Sounds"]; //Sound of score scounter

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *value;
	if((value = [defaults objectForKey:PREF_PLAYER_SOUND_ENABLED]) != nil) {
		soundEnabled = [value boolValue];
	} else {
		soundEnabled = YES;
	}
	if((value = [defaults objectForKey:PREF_PLAYER_SOUND_VOLUME]) != nil) {
		soundVolume = [value floatValue];
	} else {
		soundVolume = 1.0;
	}
	soundPlayer.isEnabled = soundEnabled;
	soundPlayer.listenerGain = soundVolume;
}

-(void)playSound:(unsigned int)sound AfterDelay:(float)delay {
	[self performSelector:@selector(playNumberSound:) withObject:[NSNumber numberWithUnsignedInt:sound] afterDelay:delay];
}

-(void)playNumberSound:(NSNumber*)sound {
	[soundPlayer playSound:[sound unsignedIntValue] gain:1.0 pitch:1.0 loops:NO];
}

-(void)playSound:(unsigned int)sound {
	[soundPlayer playSound:sound gain:1.0 pitch:1.0 loops:NO];
}

-(vec4)getTextureCoordinatesForLetter:(char)letter IsWhite:(BOOL)isWhite {
	if (letter >= 'a' && letter <= 'z') {
		int index = letter-'a';
		if (isWhite == NO) {
			index += 32;
		}
		return uvTable[index];
	}
	return ZERO4;
}

-(vec4)getTextureCoordinatesForNumber:(int)number {
	if (number >= 0 && number <= 63) {
		return uvTable[number];
	}
	return ZERO4;
}

-(vec3)getPositionForLetter:(char)letter {
	return [letterStack[letter-'a'] getNextLetterBlockPosition];
}

-(void)pushLetterBlock:(LetterBlock*)lb forLetter:(char)letter {
	[letterStack[letter-'a'] pushLetterBlock:lb];
}

-(BOOL)isStackFull:(char)letter {
	return [letterStack[letter-'a'] isFull];
}

-(int)getStackCount:(char)letter {
	return [letterStack[letter-'a'] getCount];
}

-(LetterStack*)getStackForLetter:(char)letter {
	return letterStack[letter-'a'];
}

-(BOOL)updateGlowRectPosition {
	if(self.selectedBlock != nil) {
		glowRectangle.modelMatrix->w = self.selectedBlock.modelMatrix->w;
		return YES;
	} else {
		return NO;
	}
}

-(void)resetGame {
	[self resetNetwork];
	
	self.stateObject = nil;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:PREF_PLAYER_GAME_STATE];
	[defaults synchronize];
	
	[self fadeOutDisplayLines];
	[self fadeOutStackCounters];
	[scoreBoard animateReset];
	
	for (int i=0; i<LINE_COUNT; i++) {
		if (displayLines[i] != nil) {
			[displayLines[i] reset];
		}
	}

	if(self.selectedBlock != nil) {
		[self.selectedBlock startFromBoxAnimation:0.0];
		self.selectedBlock = nil;
	}
	float delayList[LETTER_COUNT];
	for (int i=0; i<LETTER_COUNT; i++) {
		delayList[i] = 0;
	}
	
	resetBlockCount = 0;
	NSEnumerator *enumerator = [inGameLetterList reverseObjectEnumerator];
	for (LetterBlock *block in enumerator) {
		[block setColor:COLOR_LETTER andMix:0.0f];
		[block animateColorMix:1.0 withDuration:0.5];

		int charIndex = block.letter-'a';
		[block startFromBoxAnimation:delayList[charIndex]];
		block.animationStopDelegate = self;
		block.animationStopSelector = @selector(resetBlockToStack);
		delayList[charIndex] += 0.1;
		
		LetterStack *stack = [self getStackForLetter:block.letter];
		[stack pushLetterBlock:block];
		
		resetBlockCount++;
	}
	[letterCarton resetAnimation:nil finishedSelector:nil];
}

-(void)resetBlockToStack {
	resetBlockCount--;
	if (resetBlockCount == 0) {
		[letterCarton startMoveStacksToBoxAnimation:1.0];

		vec3 eye = [AletterationGameState getInitialEye];
		
		eye.x *= 0.25;
		eye.y *= 0.25;
		eye.z = 9.0;
		
		vec3 target = [graphics.camera getTarget];
		vec3 upTarget = [AletterationGameState getInitialUpVector];
		
		graphics.camera.animationStopDelegate = self;
		graphics.camera.animationStopSelector = @selector(resetCameraMidPointDidStop);
		
		[graphics.camera animateToEye:eye Target:target UpVector:upTarget Duration:3.0];
		
		for (int i=0; i<LINE_COUNT; i++) {
			if (displayLines[i] != nil) {
				[displayLines[i] reset];
			}
		}
	}
}

-(void)resetCameraMidPointDidStop {
	graphics.camera.animationStopDelegate = nil;
	graphics.camera.animationStopSelector = nil;

	vec3 eye = [AletterationGameState getInitialEye];
	vec3 target = [AletterationGameState getInitialTarget];
	vec3 upTarget = [AletterationGameState getInitialUpVector];
	
	[graphics.camera animateToEye:eye Target:target UpVector:upTarget Duration:3.0];
	
	if (resetGameDelegate != nil && resetGameSelector != nil) {
		[resetGameDelegate performSelector:resetGameSelector withObject:nil afterDelay:1.5];
	}
}

-(void)setSelectedBlock:(LetterBlock*)sb ToLine:(int)lineIndex {
	for (int i=0; i<LINE_COUNT; i++) {
		displayLines[i].selectedBlock = nil;
	}
	if (currentLetter != -1 && sb && lineIndex > 0 && lineIndex < LINE_COUNT) {
		displayLines[lineIndex].selectedBlock = sb;
	}
}

-(void)addCurrentLetterToLine:(int)lineIndex withNoCheck:(BOOL)noCheck {
	if (currentLetter != -1 && _selectedBlock) {
		if (lineIndex >= 0 && lineIndex < LINE_COUNT) {
			letterBag[currentLetter-'a']--;
			LineState *lineStatePtr = &lines[lineIndex];
			lineStatePtr->line[lineStatePtr->letterCount] = currentLetter;
			lineStatePtr->letterCount++;
			lineStatePtr->line[lineStatePtr->letterCount] = '\0';
			displayLines[lineIndex].selectedBlock = nil;
			[displayLines[lineIndex].letterList addObject:self.selectedBlock];
			self.selectedBlock = nil;
			if (noCheck) {
				[self setupAllLinesFast];
			} else {
                [displayLines[lineIndex] setBoxPositions];
				[self setupAllLines];
			}
			[self setCharAtLine:lineIndex toPlayer:self.localPlayerInfo];
		}
	}
}

-(void)completeWordForPlayerIP:(NSString*)ip lineIndex:(int)row wordLength:(int)wordLength {
	AletterationPlayerInfo *playerInfo = [self getPlayerInfoForIP:ip];
	[playerInfo completeWord:row wordLength:wordLength];
}

-(void)setGameOverForPlayerIP:(NSString*)ip {
	AletterationPlayerInfo *playerInfo = [self getPlayerInfoForIP:ip];
	playerInfo.gameOver = YES;
}

-(void)dropPlayerForIP:(NSString*)ip {
	[playerInfoList removeObjectForKey:ip];
}

-(void)setDisplayLinesAlpha:(float)alpha {
	for (int i=0; i<LINE_COUNT; i++) {
		[displayLines[i] setMix:alpha];
	}
}

-(void)fadeInDisplayLines {
	for (int i=0; i<LINE_COUNT; i++) {
		[displayLines[i] startFadeInAnimationWithDuration:1.0];
	}
}

-(void)fadeOutDisplayLines {
	for (int i=0; i<LINE_COUNT; i++) {
		[displayLines[i] startFadeOutAnimationWithDuration:1.0];
		[displayLines[i] hideHighlight];
	}
}

-(void)setStackCountersAlpha:(float)alpha {
	for (int i=0; i<LETTER_COUNT; i++) {
		[letterStack[i].numberBox setMix:alpha];
	}
}

-(void)fadeInStackCounters {
	for (int i=0; i<LETTER_COUNT; i++) {
		[letterStack[i] startFadeInAnimationWithDuration:1.0];
	}
}

-(void)fadeOutStackCounters {
	for (int i=0; i<LETTER_COUNT; i++) {
		[letterStack[i] startFadeOutAnimationWithDuration:1.0];
	}
}

-(void)setupAllLinesFast {
	for (int i=0; i<LINE_COUNT; i++) {
		[self setupCurrentWordFastForLine:i];
	}
}

-(void)setupCurrentWordFastForLine:(int)lineIndex {
	LineState *lineStatePtr = &lines[lineIndex];

	InputLength lineLength = INPUT_ZERO;
	lineLength.prefixIndex = displayLines[lineIndex].inputLength.prefixIndex;
	lineLength.prefixLength = lineStatePtr->letterCount-lineLength.prefixIndex;
	displayLines[lineIndex].inputLength = lineLength;

	displayLines[lineIndex].inputLength = lineLength;
	displayLines[lineIndex].type = NEZ_DIC_INPUT_ISPREFIX;
}

-(void)updateAllStackCounters {
	for (int i=0;i<26;i++) {
		[letterStack[i] updateCounter];
	}
}

-(void)setupAllLines {
	for (int i=0; i<LINE_COUNT; i++) {
		[self setupCurrentWordForLine:i];
	}
}

-(void)setupCurrentWordForLine:(int)lineIndex {
	LineState *lineStatePtr = &lines[lineIndex];
	if (lineStatePtr->letterCount > 0) {
		InputLength prevInputL = displayLines[lineIndex].inputLength;
		InputLength lineLength = INPUT_ZERO;
		char *prevWordPtr = &lineStatePtr->line[prevInputL.prefixIndex];
		
		NezAletterationDictionaryInputType type = [self checkWord:prevWordPtr];
		if (type == NEZ_DIC_INPUT_ISNOTHING) {
			char *wordPtr = &lineStatePtr->line[lineStatePtr->letterCount];
			int count = 0;
			while (wordPtr != prevWordPtr) {
				wordPtr--;
				count++;
				if (displayLines[lineIndex].prevInput[lineStatePtr->letterCount-count].type == NEZ_DIC_INPUT_IS_NO_MORE) {
					break;
				}
				NezAletterationDictionaryInputType type = [self checkWord:wordPtr];
				if (type != NEZ_DIC_INPUT_ISNOTHING) {
					if (count > lineLength.prefixLength) {
						lineLength.prefixIndex = lineStatePtr->letterCount-count;
						lineLength.prefixLength = count;
						displayLines[lineIndex].type = type;
					}
				}
			}
			displayLines[lineIndex].inputLength = lineLength;
			if (lineLength.prefixLength == 0) {
				displayLines[lineIndex].type = NEZ_DIC_INPUT_IS_NO_MORE;
			}
		} else if (type != NEZ_DIC_INPUT_IS_NO_MORE) {
			lineLength.prefixIndex = ((int)prevWordPtr-(int)lineStatePtr->line);
			lineLength.prefixLength = lineStatePtr->letterCount-lineLength.prefixIndex;
			displayLines[lineIndex].inputLength = lineLength;
			displayLines[lineIndex].type = type;
		}
	} else {
		displayLines[lineIndex].inputLength = INPUT_ZERO;
		displayLines[lineIndex].type = NEZ_DIC_INPUT_ISNOTHING;
	}
}

-(void)setColorsForAllLines {
	for (int i=0; i<LINE_COUNT; i++) {
		[displayLines[i] setLetterColors];
	}
}

-(NSArray*)removeWordFromLine:(int)lineIndex Count:(int)count {
	if (count >= 4) {
		LineState *lineStatePtr = &lines[lineIndex];
		char *wordPtr = &lineStatePtr->line[lineStatePtr->letterCount-count];
		NezAletterationDictionaryInputType type = [self checkWord:wordPtr];
		if (type == NEZ_DIC_INPUT_ISWORD || type == NEZ_DIC_INPUT_ISBOTH) {
			DisplayLine *line = displayLines[lineIndex];
			NSRange range = {line.count - count, count};
			NSArray *removedLetterBlocks = [displayLines[lineIndex] removeRange:range];
			
			[[self getLocalPlayerInfo] completeWord:lineIndex wordLength:count];
			
			wordPtr[0] = '\0';
			lineStatePtr->letterCount -= count;
			
			if (lineStatePtr->letterCount > 0) {
				line.inputLength = line.prevInput[lineStatePtr->letterCount-1].place;
			} else {
				InputLength length = { 0, lineStatePtr->letterCount };
				line.inputLength = length;
			}
			[self.stateObject retireWordForLineIndex:lineIndex andRange:range];

			return removedLetterBlocks;
		}
	}
	return nil;
}

-(void)setCharAtLine:(int)lineIndex toPlayer:(AletterationPlayerInfo*)info {
	[self setCharAtLine:lineIndex toPlayer:info forTurn:currentTurn];
}

-(void)setCharAtLine:(int)lineIndex toPlayer:(AletterationPlayerInfo*)info forTurn:(int)turn {
	self.stateObject.currentTurn.lineIndex = lineIndex;
	if (info != nil) {
		if (currentLetter != -1) {
			[info addLetterToLine:lineIndex forTurn:turn];
		}
	}
}

-(int)getLetterCountForLine:(int)lineIndex {
	if (lineIndex >= 0 && lineIndex < LINE_COUNT) {
		return lines[lineIndex].letterCount;
	}
	return 0;
}

-(BOOL)isGameOverForAllPlayers {
	BOOL ret = YES;
	for (AletterationPlayerInfo *info in [playerInfoList allValues]) {
		if (info.gameOver == NO) {
			ret &= NO;
		}
	}
	return ret;
}

-(BOOL)isTurnOverForAllPlayers {
	BOOL ret = YES;
	for (AletterationPlayerInfo *info in [playerInfoList allValues]) {
		if (info.turnIndex != currentTurn) {
			ret &= NO;
		}
	}
	return ret;
}

-(BOOL)isNextTurnOverForAllPlayers {
	BOOL ret = YES;
	for (AletterationPlayerInfo *info in [playerInfoList allValues]) {
		if (info.turnIndex != currentTurn+1) {
			ret &= NO;
		}
	}
	return ret;
}

-(BOOL)isPlayerDoneTurn:(AletterationPlayerInfo*)info {
	return (info.turnIndex == currentTurn);
}

-(BOOL)isPlayerDoneNextTurn:(AletterationPlayerInfo*)info {
	return (info.turnIndex == currentTurn+1);
}

-(void)setNextTurn {
	currentTurn++;
}

-(NezAletterationDictionaryInputType)checkWord:(char*)word {
	if (word[0] != '\0') {
		static NezAletterationLetterCounter letterCounter;
		[self getLetterCounts:letterCounter.count Word:word];
		return [NezAletterationSQLiteDictionary getTypeWithInput:word LetterCounts:letterCounter];
	}
	return NEZ_DIC_INPUT_ISNOTHING;
}

-(int)getCountForLetterIndex:(int)letterIndex {
	return letterBag[letterIndex];
}

-(int)getCountForLetter:(char)letter {
	return letterBag[letter-'a'];
}

-(int)getNumberForLetter:(char)letter {
	return letterBag[letter-'a']+'0';
}

-(char)getCurrentLetter {
	return currentLetter;
}

-(char*)getLettersForLine:(int)lineIndex {
	return lines[lineIndex].line;
}

-(void)getLetterCounts:(int[LETTER_COUNT])letters Word:(char*)word {
	memcpy(letters, letterBag, LETTER_COUNT*sizeof(int));
	while (*word) {
		letters[*word-'a']++;
		word++;
	}
}

-(NSString*)getStringForLine:(int)i wordLength:(int)length {
	return [NSString stringWithFormat:@"%s", &lines[i].line[lines[i].letterCount-length]];
}

-(NSString*)getStringForLine:(int)i {
	if (displayLines[i].inputLength.prefixIndex >= 0) {
		return [NSString stringWithFormat:@"%s", &lines[i].line[displayLines[i].inputLength.prefixIndex]];
	} else {
		return @"";
	}
}

-(int)getLongestWordBonus {
	int longestWordLength = 0;
	int pCount = 0;
	AletterationPlayerInfo *playerWithLongestWord = nil;
	for (AletterationPlayerInfo *info in [playerInfoList allValues]) {
		int playerLongestWordLength = [info getLongestWordLength];
		if (longestWordLength < playerLongestWordLength) {
			longestWordLength = playerLongestWordLength;
			pCount = 1;
			playerWithLongestWord = info;
		} else if (longestWordLength == playerLongestWordLength) {
			if (playerWithLongestWord != info) {
				pCount++;
			}
		}
	}
	if (longestWordLength < 8) {
		return 0;
	}
	if (pCount == 1) {
		return 2;
	} else {
		return 1;
	}
}

-(int)getLongestWordLength {
	int longestWordLength = 0;
	for (AletterationPlayerInfo *info in [playerInfoList allValues]) {
		int playerLongestWordLength = [info getLongestWordLength];
		if (longestWordLength < playerLongestWordLength) {
			longestWordLength = playerLongestWordLength;
		}
	}
	return longestWordLength;
}

-(BOOL)isGameOver {
	return ([letterList count] <= 0 && currentLetter == -1);
}

-(BOOL)isGameCompletelyOver {
	if ([self isGameOver]) {
		return YES;
	}
	return NO;
}

-(int)getRemainingLetterCount {
	int count = 0;
	for (int i=0;i<LETTER_COUNT;i++) {
		if (letterBag[i] > 0) {
			count++;
		}
	}
	return count;
}

-(int)getRandomIndex:(int)count {
	return arc4random() % count;
}

-(char)getNextLetter {
	int count = [letterList count];
	if (count > 0) {
		if ([self getRemainingLetterCount] > 0) {
			currentLetter = [self.stateObject getNextLetter];
			[self.stateObject pushNextTurn];
		} else {
			currentLetterIndex = -1;
			currentLetter = -1;
		}
	} else {
		currentLetterIndex = -1;
		currentLetter = -1;
	}
	return currentLetter;
}

-(void)setNextLetterWithIndex:(int)index {
	currentLetterIndex = index;
	if (index > -1 && index <= [letterList count]-1) {
		NSNumber *letterValue = [letterList objectAtIndex:index];
		char letter = [letterValue charValue];
		[letterList removeObjectAtIndex:index];
		currentLetter = letter;
	} else {
		currentLetter = -1;
	}
}

-(void)setSelectedBlockAA {
	self.selectedBlock = [letterStack[currentLetter-'a'] popLetterBlock];
	[inGameLetterList addObject:self.selectedBlock];
}

-(void)setSelectedBlockWithIndex:(int)index {
	[self setNextLetterWithIndex:index];
	if (currentLetter != -1) {
		[self setSelectedBlockAA];
	} else {
		self.selectedBlock = nil;
	}
}

-(LetterBlock*)getSelectedBlock {
	if (_selectedBlock == nil) {
		[self getNextLetter];
		if (currentLetter != -1) {
			[self setSelectedBlockAA];
		} else {
			_selectedBlock = nil;
		}
	}
	return _selectedBlock;
}

-(DisplayLine**)getDisplayLines {
	return displayLines;
}

-(void)startFireWorksWithIndex:(int)index CurrentTime:(CFTimeInterval)now Center:(vec4)centerPos {
	vec2 uv = {0,0.5};
	int star = (int)(randomNumber()*4.0);
	switch (star) {
		case 0:
		case 1:
		case 2:
		case 3:
			uv.x = ((float)star)*0.25;
			break;
		case 4:
		case 5:
		case 6:
		case 7:
			uv.x = ((float)(star-4))*0.25;
			uv.y += 0.25;
			break;
		default:
			break;
	}
	[fireworksList[index] setUV:uv];

	fireworksArrayArray->vertexArrayList[index]->paletteArray[0].matrix.w.x = centerPos.x;
	fireworksArrayArray->vertexArrayList[index]->paletteArray[0].matrix.w.y = centerPos.y;
	fireworksArrayArray->vertexArrayList[index]->paletteArray[0].matrix.w.z = centerPos.z;

	fireworksArrayArray->vertexArrayList[index]->animating = YES;
	fireworksArrayArray->vertexArrayList[index]->startTime = now;
	fireworksArrayArray->vertexArrayList[index]->now = now;

	[self playSound:self.sounds->fireworks];
};

-(void)stopFireWorksWithIndex:(int)index {
	fireworksArrayArray->vertexArrayList[index]->animating = NO;
}

-(void)updateWithCurrentTime:(CFTimeInterval)now andPreviousTime:(CFTimeInterval)lastTime {
	for (int i=0; i<fireworksArrayArray->vertexArrayCount; i++) {
		if (fireworksArrayArray->vertexArrayList[i]->animating) {
			fireworksArrayArray->vertexArrayList[i]->now = now;
			if (now - fireworksArrayArray->vertexArrayList[i]->startTime > 5.0) {
				[self stopFireWorksWithIndex:i];
			}
		}
	}
}

-(void)draw {
	int vCount;
	
	[graphics clearBuffer];
	
	[graphics glDisable:GLES2_DEPTH_TEST];

	[graphics setGLBlendSrc:GLES2_GL_SRC_ALPHA Dst:GLES2_GL_ONE_MINUS_SRC_ALPHA];

	vCount = backgroundArrayArray->vertexArrayCount;
	[graphics drawUnlitBlendedTexturedTrianglesVBO:backgroundArrayArray->vertexArrayList[0]];
	[graphics setGLBlendSrc:GLES2_GL_SRC_ALPHA Dst:GLES2_GL_ONE];
	
	for (int i=1; i<vCount; i++) {
		[graphics drawUnlitBlendedTexturedTrianglesVBO:backgroundArrayArray->vertexArrayList[i]];
	}
	
	vCount = noZBufferVertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawUnlitTexturedTrianglesVBO:noZBufferVertexArrayArray->vertexArrayList[i]];
	}
	
	[graphics setGLBlendSrc:GLES2_GL_SRC_ALPHA Dst:GLES2_GL_ONE_MINUS_SRC_ALPHA];

	vCount = unlitColorVertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawUnlitBlendedColoredTrianglesVBO:unlitColorVertexArrayArray->vertexArrayList[i]];
	}
	
	[graphics glEnable:GLES2_DEPTH_TEST];

	vCount = litVertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawLitTrianglesVBO:litVertexArrayArray->vertexArrayList[i]];
	}
	
	vCount = colorBurnVertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawUnlitBlendedColorBurnedTrianglesVBO:colorBurnVertexArrayArray->vertexArrayList[i]];
	}

	vCount = unlitTextureVertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawUnlitBlendedTexturedTrianglesVBO:unlitTextureVertexArrayArray->vertexArrayList[i]];
	}
	
	[graphics glDisable:GLES2_DEPTH_TEST];
	[graphics setGLBlendSrc:GLES2_GL_SRC_ALPHA Dst:GLES2_GL_ONE];
	vCount = glowVertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawUnlitBlendedTexturedTrianglesVBO:glowVertexArrayArray->vertexArrayList[i]];
	}
	vCount = fireworksArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		if (fireworksArrayArray->vertexArrayList[i]->animating) {
			[graphics drawFireWorksPointSpritesVBO:fireworksArrayArray->vertexArrayList[i]];
		}
	}
	
	[graphics glEnable:GLES2_DEPTH_TEST];
}

-(void)drawVertexArrays:(NezVertexArrayArray*)vertexArrayArray {
	int vCount = vertexArrayArray->vertexArrayCount;
	for (int i=0; i<vCount; i++) {
		[graphics drawLitTrianglesVBO:vertexArrayArray->vertexArrayList[i]];
	}
}


-(BOOL)startServer:(NSString*)serviceName {
	[self stopServer];
	gameServer = [[AletterationGameServer alloc] init];
	return [gameServer start:serviceName];
}

-(BOOL)joinServer:(NSNetService*)server withDelegate:(id<GameConnectionDelegate>)del {
	[self detachServer];
	remoteConnection = [[AletterationRemoteConnection alloc] initWithNetService:server];
	remoteConnection.delegate = del;
	return [remoteConnection start];
}

-(void)detachServer {
	if(remoteConnection != nil) {
		[remoteConnection stop];
		[remoteConnection release];
		remoteConnection = nil;
	}
}

-(void)stopServer {
	if(gameServer != nil) {
		[gameServer stop];
		[gameServer release];
		gameServer = nil;
	}
}

-(NSMutableArray*)getCompletedWordBlockList {
	return completedWordBlockList;
}

-(void)saveState {
	[self.stateObject save];
}

-(void)loadState {
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
}

-(void)dealloc {
	[letterBlockList removeAllObjects];
	[letterBlockList release];
	
	[completedWordBlockList removeAllObjects];
	[completedWordBlockList release];
	
	[backgroundArrayArray release];
	[litVertexArrayArray release];
	[unlitTextureVertexArrayArray release];
	[glowVertexArrayArray release];
	[unlitColorVertexArrayArray release];
	[noZBufferVertexArrayArray release];
	[colorBurnVertexArrayArray release];
	
	[fireworksArrayArray release];
	
	[soundPlayer release];
	[backgroundMusicPlayer release];
    [endMusicPlayer release];
    
	[scoreBoard release];
	[playerInfoList removeAllObjects];
	[playerInfoList release];
	[inGameLetterList removeAllObjects];
	[inGameLetterList release];
	for (int i=0; i<LINE_COUNT; i++) {
		[displayLines[i] release];
	}
	for (int i=0; i<LETTER_COUNT; i++) {
		[letterStack[i] release];
	}
	[letterCarton release];
	[backgroundGradientRectangle release];
	[woodRectangle release];
	[glowRectangle release];
	for (int i=0; i<LINE_COUNT; i++) {
		[selectionRectangle[i] release];
	}
	for (int i=0; i<FIRE_WORKS_COUNT; i++) {
		[fireworksList[i] release];
	}
	
	self.resetGameDelegate = nil;
	self.resetGameSelector = nil;

	if(gameServer != nil) {
		[gameServer release];
		gameServer = nil;
	}
	if(remoteConnection != nil) {
		[remoteConnection release];
	}
	[super dealloc];
}

@end
