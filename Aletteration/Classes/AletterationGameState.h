//
//  AletterationGameState.h
//  Aletteration
//
//  Created by David Nesbitt on 2/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Structures.h"
#import "NezAletterationSQLiteDictionary.h"
#import "GLSLProgram.h"
#import "AletterationGameServer.h"
#import "AletterationRemoteConnection.h"

#define LETTER_COUNT 26
#define LINE_COUNT 6
#define TOTAL_LETTER_COUNT 90

#define UV_CHAR_COUNT 64

#define RAYS_COUNT 1

#define FIRE_WORKS_COUNT 5

@class ScoreBoard, DisplayLine, AletterationBox, NezRectangle2D, NezStrectableRectangle2D;
@class LetterStack, LetterBlock, NezOpenAL, OpenGLES2Graphics, FireWorksGlobe;
@class NezCubicBezier, NezVertexArray, NezVertexArrayArray;

@interface NezAletterationGameStateRetiredWord : NSObject<NSCoding>

@property(nonatomic) int32_t lineIndex;
@property(nonatomic) NSRange range;

@end

@interface NezAletterationGameStateTurn : NSObject<NSCoding>

@property(nonatomic) int32_t lineIndex;
@property(nonatomic, strong) NSMutableArray *retiredWordList;

@end

@interface NezAletterationGameStateObject : NSObject<NSCoding> {
}

@property(nonatomic, strong) NSMutableData *letterData;
@property(nonatomic, strong) NSMutableArray *turnStack;
@property(nonatomic, readonly, getter = getLetterList) char *letterList;
@property(nonatomic, readonly, getter = getCurrentTurn) NezAletterationGameStateTurn *currentTurn;

@end


typedef struct LineState {
	char line[1024];
	int letterCount;
} LineState;

typedef struct SoundFiles {
	unsigned int intro;
	unsigned int tileDrop;
	unsigned int dblTapWord;
	unsigned int letterUp;
	unsigned int letterDown;
	unsigned int touchLetter;
	unsigned int lockLetter;
	unsigned int wordMove;
	unsigned int fireworks;
	unsigned int scoreCounter;
	unsigned int scoreFadeIn;
} SoundFiles;

@interface AletterationGameState : NSObject<AVAudioPlayerDelegate> {
	LineState lines[LINE_COUNT];
	int currentLetterIndex;
	char currentLetter;
	int letterBag[26];
	NSMutableArray *letterList;
	NSMutableArray *inGameLetterList;
	
	vec4 uvTable[UV_CHAR_COUNT];
	
	ScoreBoard *scoreBoard;
	DisplayLine *displayLines[LINE_COUNT];
	AletterationBox *letterCarton;
	LetterStack *letterStack[LETTER_COUNT];
	NezRectangle2D *woodRectangle;
	NezRectangle2D *glowRectangle;
	NezStrectableRectangle2D *selectionRectangle[LINE_COUNT];
	NezRectangle2D *backgroundGradientRectangle;
	NezRectangle2D *backgroundRaysRectangle[RAYS_COUNT];
	
	int resetBlockCount;
	NSMutableArray *letterBlockList;
	
	BOOL backgroundMusicPlaying;
	UInt32 otherMusicIsPlaying;
	BOOL musicInterupted;

	BOOL musicEnabled;
	float musicVolume;
	BOOL soundEnabled;
	float soundVolume;

	AVAudioPlayer *backgroundMusicPlayer;
	AVAudioPlayer *endMusicPlayer;

	NezOpenAL *soundPlayer;
	SoundFiles loadedSounds;

	NezVertexArrayArray *backgroundArrayArray;
	NezVertexArrayArray *litVertexArrayArray;
	NezVertexArrayArray *unlitTextureVertexArrayArray;
	NezVertexArrayArray *glowVertexArrayArray;
	NezVertexArrayArray *unlitColorVertexArrayArray;
	NezVertexArrayArray *noZBufferVertexArrayArray;
	NezVertexArrayArray *colorBurnVertexArrayArray;

	FireWorksGlobe *fireworksList[FIRE_WORKS_COUNT];
	NezVertexArrayArray *fireworksArrayArray;
	
	TextureInfo lettersTexInfo;
	TextureInfo numbersTexInfo;
	TextureInfo boxTexInfo;
	TextureInfo woodTexInfo;
	TextureInfo backgroundGradientTexInfo;
	TextureInfo backgroundRaysTexInfo;
	TextureInfo glowTexInfo;
	TextureInfo scoresTexInfo;
	TextureInfo starsTexInfo;
	
	OpenGLES2Graphics *graphics;
	
	vec3 initialTarget;
	vec3 initialEye;
	vec3 initialUpVector;
	
	mat4 initialBackgroundScaleMatrix;
	mat4 initialBackgroundRotationMatrix;

	//Network classes:
	AletterationGameServer *gameServer;
	AletterationRemoteConnection *remoteConnection;

	NSMutableDictionary *playerInfoList;
	int currentTurn;

	NSMutableArray *completedWordBlockList;

	id resetGameDelegate;
	SEL resetGameSelector;
}

+(AletterationGameState*)instance;

+(const int*)getLetterBag;

+(vec3)getDefaultTarget;
+(vec3)getDefaultEye;
+(vec3)getDefaultUpVector;

+(vec3)getInitialTarget;
+(vec3)getInitialEye;
+(vec3)getInitialUpVector;

-(float)getBrightnessWithColor:(color4uc)c;
-(float)getBrightnessWithRed:(float)r Green:(float)g Blue:(float)b;
-(float)setLetterRed:(float)r Green:(float)g Blue:(float)b;

-(vec4)getTextureCoordinatesForLetter:(char)letter IsWhite:(BOOL)isWhite;
-(vec4)getTextureCoordinatesForNumber:(int)number;

-(vec3)getPositionForLetter:(char)letter;
-(void)pushLetterBlock:(LetterBlock*)lb forLetter:(char)letter;
-(BOOL)isStackFull:(char)letter;
-(int)getStackCount:(char)letter;
-(LetterStack*)getStackForLetter:(char)letter;
-(void)fadeInStackCounters;
-(void)fadeOutStackCounters;
-(void)fadeInDisplayLines;
-(void)fadeOutDisplayLines;

-(void)resetNetwork;
-(void)resetGame;
-(void)resetState;
-(void)resetLocalPlayerInfo;
-(void)resetPlayerInfoList;

-(void)completeWordForPlayerIP:(NSString*)ip lineIndex:(int)row wordLength:(int)wordLength;
-(void)setGameOverForPlayerIP:(NSString*)ip;
-(void)dropPlayerForIP:(NSString*)ip;

-(void)setCharAtLine:(int)lineIndex toPlayer:(AletterationPlayerInfo*)playerInfo;
-(void)setCharAtLine:(int)lineIndex toPlayer:(AletterationPlayerInfo*)info forTurn:(int)turn;

-(BOOL)updateGlowRectPosition;

-(void)setNextLetterWithIndex:(int)index;
-(void)setSelectedBlockWithIndex:(int)index;
-(char)getNextLetter;
-(int)getNumberForLetter:(char)letter;
-(int)getCountForLetter:(char)letter;
-(int)getCountForLetterIndex:(int)letterIndex;
-(char)getCurrentLetter;
-(int)getLetterCountForLine:(int)lineIndex;

-(void)setColorsForAllLines;

-(char*)getLettersForLine:(int)lineIndex;

-(NezAletterationDictionaryInputType)checkWord:(char*)word;
-(NSArray*)removeWordFromLine:(int)lineIndex Count:(int)wordCount;

-(void)setSelectedBlock:(LetterBlock*)sb ToLine:(int)lineIndex;
-(void)addCurrentLetterToLine:(int)lineIndex withNoCheck:(BOOL)noCheck;

-(void)setupCurrentWordForLine:(int)lineIndex;
-(void)setupAllLines;

-(NSString*)getStringForLine:(int)i;
-(NSString*)getStringForLine:(int)i wordLength:(int)length;

-(int)getLongestWordBonus;
-(int)getLongestWordLength;
-(BOOL)isGameOver;
-(BOOL)isGameCompletelyOver;

-(void)loadMusic;
-(void)tryPlayMusic;
-(void)tryPlayEndMusic;
-(void)stopMusic;
-(void)loadSounds;
-(void)loadData;

-(void)playSound:(unsigned int)sound;
-(void)playSound:(unsigned int)sound AfterDelay:(float)delay;

-(void)startFireWorksWithIndex:(int)index CurrentTime:(CFTimeInterval)now Center:(vec4)centerPos;
-(void)updateWithCurrentTime:(CFTimeInterval)now andPreviousTime:(CFTimeInterval)lastTime;
-(void)draw;

//Network Server:
-(BOOL)startServer:(NSString*)serviceName;
-(void)stopServer;
//Network Client:
-(BOOL)joinServer:(NSNetService*)server withDelegate:(id<GameConnectionDelegate>)del;
-(void)detachServer;

-(BOOL)isGameOverForAllPlayers;
-(BOOL)isTurnOverForAllPlayers;
-(BOOL)isNextTurnOverForAllPlayers;
-(BOOL)isPlayerDoneTurn:(AletterationPlayerInfo*)info;
-(BOOL)isPlayerDoneNextTurn:(AletterationPlayerInfo*)info;

-(void)setNextTurn;

-(AletterationPlayerInfo*)getPlayerInfoForIP:(NSString*)ip;
-(AletterationPlayerInfo*)getNextPlayerInfo:(AletterationPlayerInfo*)playerInfo;

-(BOOL)updatePlayerInfo:(AletterationPlayerInfo*)info;
-(void)setPlayerList:(NSArray*)playerList;

-(NezStrectableRectangle2D*)getSelectionRectangleForLine:(int)lineIndex;

-(void)saveState;
-(void)loadState;

-(void)setupStateObject;

-(void)setDisplayLinesAlpha:(float)alpha;
-(void)setStackCountersAlpha:(float)alpha;
-(void)updateAllStackCounters;

@property(nonatomic, retain) NezAletterationGameStateObject *stateObject;
@property(nonatomic, retain, getter=getSelectedBlock) LetterBlock *selectedBlock;

@property(nonatomic, readonly) int currentTurn;
@property(nonatomic, readonly) char currentLetter;
@property(nonatomic, readonly) int currentLetterIndex;

@property(nonatomic, readonly) NezOpenAL *soundPlayer;
@property(nonatomic, readonly, getter=getLoadedSounds) SoundFiles *sounds;

@property(nonatomic, readonly) AletterationBox *letterCarton;
@property(nonatomic, readonly) ScoreBoard *scoreBoard;
@property(nonatomic, readonly, getter=getDisplayLines) DisplayLine **displayLines;
@property(nonatomic, readonly) NezRectangle2D *glowRectangle;

@property(nonatomic, readonly, getter=getLineWidth) float lineWidth;
@property(nonatomic, readonly, getter=getLineHeight) float lineHeight;
@property(nonatomic, readonly, getter=getBlockLength) float blockLength;
@property(nonatomic, readonly, getter=getBlockDepth) float blockDepth;

@property(nonatomic, readonly, getter=getScreenWidth) float screenWidthAtZero;
@property(nonatomic, readonly, getter=getScreenHeight) float screenHeightAtZero;
@property(nonatomic, readonly, getter=getScreenHalfWidth) float screenHalfWidthAtZero;
@property(nonatomic, readonly, getter=getScreenHalfHeight) float screenHalfHeightAtZero;

@property(nonatomic, readonly) NSMutableDictionary *playerInfoList;
@property(nonatomic, assign, setter=setLocalPlayerInfo:, getter=getLocalPlayerInfo) AletterationPlayerInfo *localPlayerInfo;

@property(nonatomic, readonly) AletterationGameServer *gameServer;
@property(nonatomic, readonly) AletterationRemoteConnection *remoteConnection;

@property(nonatomic, readonly, getter = getLetterColor) color4uc letterColor;
@property(nonatomic, readonly, getter = getSelectionColor) color4uc selectionColor;

@property(nonatomic, readonly, getter = getCompletedWordBlockList) NSMutableArray *completedWordBlockList;

@property(nonatomic, retain) id resetGameDelegate;
@property(nonatomic, assign) SEL resetGameSelector;

@property(nonatomic, assign, setter=setMusicEnabled:) BOOL musicEnabled;
@property(nonatomic, assign, setter=setMusicVolume:) float musicVolume;
@property(nonatomic, assign, setter=setSoundEnabled:) BOOL soundEnabled;
@property(nonatomic, assign, setter=setSoundVolume:) float soundVolume;

@property(nonatomic, readonly) NSArray *letterBlockList;
@property(nonatomic, readonly) NSMutableArray *inGameLetterList;
@property(nonatomic, readonly) NSMutableArray *letterList;

@end
