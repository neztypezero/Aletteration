//
//  NezAletterationPrefs.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#define NEZ_ALETTERATION_PREFS @"NEZ_ALETTERATION_PREFERENCES"

#import "NezAletterationPrefs.h"
#import "NezAletterationGameState.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationLetterStack.h"

@implementation NezAletterationGameStateRetiredWord

+(NezAletterationGameStateRetiredWord*)retireWord {
	return [[NezAletterationGameStateRetiredWord alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		self.lineIndex = -1;
		self.range = NSMakeRange(-1, -1);
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
		self.temporaryLineIndex = -1;
		self.retiredWordList = [NSMutableArray array];
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		self.lineIndex = [decoder decodeInt32ForKey:@"lineIndex"];
		self.temporaryLineIndex = [decoder decodeInt32ForKey:@"temporaryLineIndex"];
		self.retiredWordList = [decoder decodeObjectForKey:@"retiredWordList"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeInt32:self.lineIndex forKey:@"lineIndex"];
	[encoder encodeInt32:self.temporaryLineIndex forKey:@"temporaryLineIndex"];
	[encoder encodeObject:self.retiredWordList forKey:@"retiredWordList"];
}

-(NSString*)description {
	NSString *description = [NSString stringWithFormat:@"lineIndex:%d wordList:{}", self.lineIndex];
	return description;
}

@end

@implementation NezAletterationGameStateObject

+(id)stateObject {
	return [[NezAletterationGameStateObject alloc] init];
}

-(id)init {
	if ((self = [super init])) {
		int length = [NezAletterationGameState getTotalLetterCount]+1;
		char letters[length];
		self.letterData = [NSMutableData dataWithBytesNoCopy:letters length:length freeWhenDone:NO];
		self.turnStack = [NSMutableArray arrayWithCapacity:[NezAletterationGameState getTotalLetterCount]];
	}
	return self;
}

-(id)initWithCoder:(NSCoder*)decoder {
	if ((self = [super init])) {
		self.letterData = [decoder decodeObjectForKey:@"letterData"];
		self.turnStack = [decoder decodeObjectForKey:@"turnStack"];
		self.snapshot = [decoder decodeObjectForKey:@"snapshot"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.letterData forKey:@"letterData"];
	[encoder encodeObject:self.turnStack forKey:@"turnStack"];
	[encoder encodeObject:self.snapshot forKey:@"snapshot"];
}

-(int)getTurn {
	return self.turnStack.count;
}

-(char*)getLetterList {
	return (char*)self.letterData.bytes;
}

-(void)reset {
	NSMutableArray *letterList = [NSMutableArray arrayWithCapacity:[NezAletterationGameState getTotalLetterCount]];
	const int *letterBag = [NezAletterationGameState getLetterBag];
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

-(void)endTurn:(int)lineIndex {
	if (self.turnStack.count > 0) {
		NezAletterationGameStateTurn *currentTurn = self.turnStack.lastObject;
		currentTurn.lineIndex = lineIndex;
	}
}

-(void)pushNextTurn {
	int turnIndex = self.turnStack.count;
	if (turnIndex < [NezAletterationGameState getTotalLetterCount]) {
		[self.turnStack addObject:[NezAletterationGameStateTurn turn]];
	}
}

-(NezAletterationGameStateTurn*)getCurrentTurn {
	return self.turnStack.lastObject;
}

-(NSString*)description {
	NSString *description = [NSString stringWithFormat:@"%s", self.letterList];
	for (NezAletterationGameStateTurn *turn in self.turnStack) {
		description = [NSString stringWithFormat:@"%@\n%@", description, turn];
	}
	return description;
}

@end

@implementation NezAletterationPrefsObject

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:_firstTime forKey: @"firstTime"];
	[aCoder encodeObject:_playerName forKey: @"playerName"];
	[aCoder encodeObject:_playerPortrait forKey: @"playerPortrait"];
	
	[aCoder encodeFloat:_blockColor.r forKey: @"blockColor.r"];
	[aCoder encodeFloat:_blockColor.g forKey: @"blockColor.g"];
	[aCoder encodeFloat:_blockColor.b forKey: @"blockColor.b"];
	[aCoder encodeFloat:_blockColor.a forKey: @"blockColor.a"];
	
	[aCoder encodeBool:_musicEnabled forKey: @"musicEnabled"];
	[aCoder encodeFloat:_musicVolume forKey: @"musicVolume"];
	[aCoder encodeBool:_soundEnabled forKey: @"soundEnabled"];
	[aCoder encodeFloat:_soundVolume forKey: @"soundVolume"];
	
	[aCoder encodeObject:_stateObject forKey: @"stateObject"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if ((self=[super init])) {
		_firstTime = [aDecoder decodeBoolForKey:@"firstTime"];
		_playerName = [aDecoder decodeObjectForKey:@"playerName"];
		_playerPortrait = [aDecoder decodeObjectForKey:@"playerPortrait"];
		
		_blockColor = GLKVector4Make(
			 [aDecoder decodeFloatForKey: @"blockColor.r"],
			 [aDecoder decodeFloatForKey: @"blockColor.g"],
			 [aDecoder decodeFloatForKey: @"blockColor.b"],
			 [aDecoder decodeFloatForKey: @"blockColor.a"]
		);
		
		_musicEnabled = [aDecoder decodeBoolForKey:@"musicEnabled"];
		_musicVolume = [aDecoder decodeFloatForKey:@"musicVolume"];
		_soundEnabled = [aDecoder decodeBoolForKey:@"soundEnabled"];
		_soundVolume = [aDecoder decodeFloatForKey:@"soundVolume"];

		_stateObject = [aDecoder decodeObjectForKey:@"stateObject"];
	}
	return self;
}

+(id)preferencesName:(NSString*)name Portrait:(UIImage*)potrait Color:(GLKVector4)color MusicEnabled:(BOOL)musicEnabled MusicVolume:(float)musicVolume SoundEnabled:(BOOL)soundEnabled SoundVolume:(float)soundVolume {
	return [[NezAletterationPrefsObject alloc] initName:name Portrait:potrait Color:color MusicEnabled:musicEnabled MusicVolume:musicVolume SoundEnabled:soundEnabled SoundVolume:soundVolume];
}

-(id)initName:(NSString*)name Portrait:(UIImage*)potrait Color:(GLKVector4)color MusicEnabled:(BOOL)musicEnabled MusicVolume:(float)musicVolume SoundEnabled:(BOOL)soundEnabled SoundVolume:(float)soundVolume {
	if ((self=[super init])) {
		_playerName = name;
		_playerPortrait = potrait;
		_blockColor = color;
		_musicEnabled = musicEnabled;
		_musicVolume = musicVolume;
		_soundEnabled = soundEnabled;
		_soundVolume = soundVolume;
	}
	return self;
}

@end

@implementation NezAletterationPrefs

+(NezAletterationPrefsObject*)getPreferences {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *prefsData = [defaults objectForKey:NEZ_ALETTERATION_PREFS];
	if (prefsData != nil) {
		NezAletterationPrefsObject *prefs = [NSKeyedUnarchiver unarchiveObjectWithData:prefsData];
		return prefs;
	} else {
		// default values
		return [NezAletterationPrefsObject preferencesName:@"Anonymous" Portrait:[UIImage imageNamed:@"anonymous"] Color:GLKVector4Make(0.2, 0.15, 0.9, 1.0) MusicEnabled:YES MusicVolume:0.5 SoundEnabled:YES SoundVolume:0.5];
	}
}

+(void)setPreferences:(NezAletterationPrefsObject*)prefs {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *prefsData = [NSKeyedArchiver archivedDataWithRootObject:prefs];
	[defaults setObject:prefsData forKey:NEZ_ALETTERATION_PREFS];
	[defaults synchronize];
}

@end

