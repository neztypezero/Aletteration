//
//  NezAletterationPrefs.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <GLKit/GLKit.h>

@class NezAletterationLetterBlock;

@interface NezAletterationGameStateRetiredWord : NSObject<NSCoding>

@property(nonatomic) int32_t lineIndex;
@property(nonatomic) NSRange range;

@end

@interface NezAletterationGameStateTurn : NSObject<NSCoding>

@property(nonatomic) int32_t temporaryLineIndex;
@property(nonatomic) int32_t lineIndex;
@property(nonatomic, strong) NSMutableArray *retiredWordList;

@end

@interface NezAletterationGameStateObject : NSObject<NSCoding>

@property(nonatomic, strong) NSMutableData *letterData;
@property(nonatomic, strong) NSMutableArray *turnStack;
@property(nonatomic, readonly, getter = getTurn) int turn;
@property(nonatomic, readonly, getter = getLetterList) char *letterList;
@property(nonatomic, strong) UIImage *snapshot;
@property(nonatomic, readonly, getter = getCurrentTurn) NezAletterationGameStateTurn *currentTurn;

+(id)stateObject;

-(void)reset;
-(void)pushNextTurn;
-(void)endTurn:(int)lineIndex;

@end

@interface NezAletterationPrefsObject : NSObject<NSCoding>

@property(nonatomic) BOOL firstTime;
@property(nonatomic, strong) NSString *playerName;
@property(nonatomic, strong) UIImage *playerPortrait;
@property(nonatomic) GLKVector4 blockColor;
@property(nonatomic) BOOL musicEnabled;
@property(nonatomic) float musicVolume;
@property(nonatomic) BOOL soundEnabled;
@property(nonatomic) float soundVolume;
@property(nonatomic, strong) NezAletterationGameStateObject *stateObject;

+(id)preferencesName:(NSString*)name Portrait:(UIImage*)potrait Color:(GLKVector4)color MusicEnabled:(BOOL)musicEnabled MusicVolume:(float)musicVolume SoundEnabled:(BOOL)soundEnabled SoundVolume:(float)soundVolume;
-(id)initName:(NSString*)name Portrait:(UIImage*)potrait Color:(GLKVector4)color MusicEnabled:(BOOL)musicEnabled MusicVolume:(float)musicVolume SoundEnabled:(BOOL)soundEnabled SoundVolume:(float)soundVolume;

@end

@interface NezAletterationPrefs : NSObject

+(NezAletterationPrefsObject*)getPreferences;
+(void)setPreferences:(NezAletterationPrefsObject*)prefs;

@end
