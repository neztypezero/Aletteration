//
//  NezOpenAL.h
//  Aletteration
//
//  Created by David Nesbitt on 2/24/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import "Structures.h"

#define MAX_SOUND_SOURCES 32
#define SOUND_BUFFER_LIST_INCREMENT 16

@interface NezOpenAL : NSObject {
	ALCcontext* context; // stores the context
	ALCdevice* device; // stores the device
	BOOL inInterruption;
	
	int nextOpenIndex;
	ALuint soundSourceList[MAX_SOUND_SOURCES];
	
	int loadedBuffersCount;
	int maxBuffers;
	ALuint *soundBufferList;
	BOOL isEnabled;
}

@property(nonatomic, assign) ALCcontext* context;
@property(nonatomic, assign) ALCdevice* device;
@property(nonatomic, assign) BOOL inInterruption;

@property(nonatomic, assign) BOOL isEnabled;

@property(nonatomic, assign, getter=getDistanceModel, setter=setDistanceModel:) ALenum distanceModel;
@property(nonatomic, assign, getter=getDopplerFactor, setter=setDopplerFactor:) ALfloat dopplerFactor;
@property(nonatomic, assign, getter=getSpeedOfSound, setter=setSpeedOfSound:) ALfloat speedOfSound;

@property(nonatomic, assign, getter=getListenerPos, setter=setListenerPos:) vec3 listenerPos;
@property(nonatomic, assign, getter=getListenerGain, setter=setListenerGain:) float listenerGain;
@property(nonatomic, assign, getter=getListenerVelocity, setter=setListenerVelocity:) vec3 listenerVelocity;
@property(nonatomic, assign, getter=getListenerOrientation, setter=setListenerOrientation:) orientation3 listenerOrientation;

-(ALuint)loadSoundEffectWithPathForResource:(NSString*)filename ofType:(NSString*)fileType inDirectory:(NSString*)dir;
-(ALuint)playSound:(ALuint)bufferID gain:(ALfloat)gain pitch:(ALfloat)pitch loops:(BOOL)loops;
-(void)stopSound:(ALuint)sourceID;

-(void)setGain:(float)gain andPitch:(float)pitch forSource:(NSUInteger)sourceID;
-(void)setGain:(float)gain forSource:(ALuint)sourceID;
-(void)setPitch:(float)pitch forSource:(ALuint)sourceID;

@end
