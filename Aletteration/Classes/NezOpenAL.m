//
//  NezOpenAL.m
//  Aletteration
//
//  Created by David Nesbitt on 2/24/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezOpenAL.h"
#include <AudioToolbox/AudioFormat.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AudioToolbox/ExtendedAudioFile.h>
#include "AudioSessionSupport.h"
#include "OpenALSupport.h"

#define PREFERRED_SAMPLE_OUTPUT_RATE 22050.0

static void NezOpenALInterruptionCallback(void* soundController, UInt32 interruptionState) {
	NezOpenAL* openalSoundController = (NezOpenAL*)soundController;
	if(interruptionState == kAudioSessionBeginInterruption) {
		openalSoundController.inInterruption = YES;
		alcSuspendContext(openalSoundController.context);
		alcMakeContextCurrent(NULL);
	} else if(interruptionState == kAudioSessionEndInterruption) {
		OSStatus theError = AudioSessionSetActive(true);
		if(theError != noErr) {
			printf("Error setting audio session active! %d\n", (int)theError);
		}
		alcMakeContextCurrent(openalSoundController.context);
		alcProcessContext(openalSoundController.context);
		openalSoundController.inInterruption = NO;
	}
}

@interface NezOpenAL(private) 

-(NSString*)getALErrorString:(ALenum)err;
-(AudioFileID)openAudioFile:(NSString*)filePath;
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor;
-(ALuint)getNextAvailableSource;
-(void)cleanUpOpenAL;

@end

@implementation NezOpenAL

@synthesize context;
@synthesize device;
@synthesize inInterruption;
@synthesize isEnabled;

-(id)init {
	if ((self = [super init])) {
		isEnabled = NO;
		inInterruption = NO;
		
		InitAudioSession(kAudioSessionCategory_AmbientSound, NezOpenALInterruptionCallback, self, PREFERRED_SAMPLE_OUTPUT_RATE);
		device = alcOpenDevice(NULL); // select the "preferred device"
		if (device) {
			alcMacOSXMixerOutputRate(PREFERRED_SAMPLE_OUTPUT_RATE);

			nextOpenIndex = 0;
			memset(soundSourceList, 0, sizeof(ALuint)*MAX_SOUND_SOURCES);
			
			loadedBuffersCount = 0;
			maxBuffers = SOUND_BUFFER_LIST_INCREMENT;
			soundBufferList = (ALuint*)malloc(sizeof(ALuint)*maxBuffers);
			
			// use the device to make a context
			context = alcCreateContext(device, NULL);
			// set my context to the currently active one
			alcMakeContextCurrent(context);
			
			alGenSources(MAX_SOUND_SOURCES, soundSourceList);
			
			self.listenerGain = 0.5;
		}
	}
	return self;
}

-(NSString*)getALErrorString:(ALenum)err {
	switch(err) {
		case AL_NO_ERROR:
			return @"AL_NO_ERROR";
		case AL_INVALID_NAME:
			return @"AL_INVALID_NAME";
		case AL_INVALID_ENUM:
			return @"AL_INVALID_ENUM";
		case AL_INVALID_VALUE:
			return @"AL_INVALID_VALUE";
		case AL_INVALID_OPERATION:
			return @"AL_INVALID_OPERATION";
		case AL_OUT_OF_MEMORY:
			return @"AL_OUT_OF_MEMORY";
	};
	return @"NO ERROR";
}

-(NSString*)getALStateString:(ALenum)state {
	switch(state) {
		case AL_STOPPED:
			return @"AL_STOPPED";
		case AL_PLAYING:
			return @"AL_PLAYING";
		default:
			return [NSString stringWithFormat:@"Unknown state:%d", state];
	};
}

-(ALuint)loadSoundEffectWithPathForResource:(NSString*)file ofType:(NSString*)type inDirectory:(NSString*)dir {
	// get the full path of the file
	NSString *fileName = [[NSBundle mainBundle] pathForResource:file ofType:type inDirectory:dir];
	//NSLog(@"%@", fileName);
	// first, open the file
	AudioFileID fileID = [self openAudioFile:fileName];
	
	// find out how big the actual audio data is
	UInt32 fileSize = [self audioFileSize:fileID];

	// this is where the audio data will live for the moment
	unsigned char * outData = malloc(fileSize);

	// this where we actually get the bytes from the file and put them
	// into the data buffer
	OSStatus result = noErr;
	result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
	AudioFileClose(fileID); //close the file

	if (result != 0) {
		if (outData) {
			free(outData);
		}
		//NSLog(@"cannot load effect: %@",fileName);
		return -1;
	}

	// grab a buffer ID from openAL
	alGenBuffers(1, &soundBufferList[loadedBuffersCount]);
	NSUInteger soundBufferID = soundBufferList[loadedBuffersCount++];
	if (loadedBuffersCount >= maxBuffers) {
		maxBuffers += SOUND_BUFFER_LIST_INCREMENT;
		NSUInteger *newSoundBufferList = (NSUInteger*)malloc(sizeof(NSUInteger)*maxBuffers);
		memcpy(newSoundBufferList, soundBufferList, sizeof(NSUInteger)*loadedBuffersCount);
		free(soundBufferList);
		soundBufferList = newSoundBufferList;
	}
	
	// jam the audio data into the new buffer
	alBufferData(soundBufferID, AL_FORMAT_STEREO16, outData, fileSize, PREFERRED_SAMPLE_OUTPUT_RATE); 

	// clean up the buffer
	if (outData) {
		free(outData);
		outData = NULL;
	}
	return soundBufferID;
}

-(ALuint)getNextAvailableSource {
	ALint sourceState; // a holder for the state of the current source
	
	// first check: find a source that is not being used at the moment.
	for (int i=0; i<MAX_SOUND_SOURCES; i++) {
		alGetSourcei(soundSourceList[i], AL_SOURCE_STATE, &sourceState);
		// great! we found one! return it and shunt
		if (sourceState != AL_PLAYING) return soundSourceList[i];
	}
	
	// in the case that all our sources are being used, we will find the first non-looping source
	// and return that.
	// first kick out an error
	////NSLog(@"available source overrun, increase MAX_SOURCES");
	
	NSInteger looping;
	for (int i=0; i<MAX_SOUND_SOURCES; i++) {
		alGetSourcei(soundSourceList[i], AL_LOOPING, &looping);
		if (!looping) {
			// we found one that is not looping, cut it short and return it
			alSourceStop(soundSourceList[i]);
			return soundSourceList[i];
		}
	}
	
	// what if they are all loops? arbitrarily grab the first one and cut it short
	// kick out another error
	////NSLog(@"available source overrun, increase MAX_SOURCES");

	alSourceStop(soundSourceList[0]);
	return soundSourceList[0];
}

-(ALuint)playSound:(ALuint)bufferID gain:(ALfloat)gain pitch:(ALfloat)pitch loops:(BOOL)loops {
	if (!self.isEnabled) {
		return AL_NONE;
	}
	if(self.inInterruption) {
		return AL_NONE;
	}
	ALenum err = alGetError(); // clear error code 
	
	// now find an available source
	NSUInteger sourceID = [self getNextAvailableSource];	
	
	// make sure it is clean by resetting the source buffer to 0
	alSourcei(sourceID, AL_BUFFER, AL_NONE);
	// attach the buffer to the source
	alSourcei(sourceID, AL_BUFFER, bufferID); 
	
	// set the pitch and gain of the source
	alSourcef(sourceID, AL_PITCH, pitch);
	alSourcef(sourceID, AL_GAIN, gain);
	
	// set the looping value
	if (loops) {
		alSourcei(sourceID, AL_LOOPING, AL_TRUE);
	} else {
		alSourcei(sourceID, AL_LOOPING, AL_FALSE);
	}
	// check to see if there are any errors
	err = alGetError();
	if (err != 0) {
		//NSLog(@"%@", [self getALErrorString:err]);
		return 0;
	}
	// now play!
	alSourcePlay(sourceID);
	
	int sourceState;
	alGetSourcei(sourceID, AL_SOURCE_STATE, &sourceState);
	
//	//NSLog(@"playSound[%d] state = %@", sourceID, [self getALStateString:sourceState]);
	
	return sourceID; // return the sourceID so I can stop loops easily
}

-(void)setGain:(float)gain andPitch:(float)pitch forSource:(ALuint)sourceID {
	alSourcef(sourceID, AL_GAIN, gain);
//	alSourcef(sourceID, AL_PITCH, pitch); // something is screwey!!!
}

-(void)setGain:(float)gain forSource:(ALuint)sourceID {
	alSourcef(sourceID, AL_GAIN, gain);
}

-(void)setPitch:(float)pitch forSource:(ALuint)sourceID {
	alSourcef(sourceID, AL_PITCH, pitch);
}

-(void)stopSound:(ALuint)sourceID {
	alSourceStop(sourceID);
	alSourcei(sourceID, AL_BUFFER, AL_NONE);
//	//NSLog(@"stopSound[%d]", sourceID);
}

// open the audio file
// returns a big audio ID struct
-(AudioFileID)openAudioFile:(NSString*)filePath {
	AudioFileID outAFID;
	// use the NSURl instead of a cfurlref cuz it is easier
	NSURL * afUrl = [NSURL fileURLWithPath:filePath];
	
	// do some platform specific stuff..
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) {
		//NSLog(@"cannot openf file: %@",filePath);	
	}
	return outAFID;
}

// find the audio portion of the file
// return the size in bytes
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor {
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if(result != 0) {
		//NSLog(@"cannot find file size");
	}
	return (UInt32)outDataSize;
}

// Note: OpenAL default distance model is AL_INVERSE_DISTANCE_CLAMPED.
-(void)setDistanceModel:(ALenum)distanceModel {
	alDistanceModel(distanceModel);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting distance model");
	}
}

-(ALenum)getDistanceModel {
	ALint distanceModel = alGetInteger(AL_DISTANCE_MODEL);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting distance model");
	}
	return (ALenum)distanceModel;
}

-(void)setDopplerFactor:(ALfloat)dopplerFactor {
	alDopplerFactor(dopplerFactor);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting Doppler Factor");
	}
}

-(ALfloat)getDopplerFactor {
	ALfloat dopplerFactor = alGetFloat(AL_DOPPLER_FACTOR);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting Doppler Factor");
	}
	return dopplerFactor;
}

-(void)setSpeedOfSound:(ALfloat)speedOfSound {
	alSpeedOfSound(speedOfSound);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting Speed of Sound");
	}
}

-(ALfloat)getSpeedOfSound {
	ALfloat speedOfSound = alGetFloat(AL_SPEED_OF_SOUND);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting Speed of Sound");
	}
	return speedOfSound;
}

-(void)setListenerPos:(vec3)pos {
	alListenerfv(AL_POSITION, &pos.x);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting Listener Position");
	}
}

-(vec3)getListenerPos {
	vec3 pos;
	alGetListenerfv(AL_POSITION, &pos.x);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting Listener Position");
	}
	return pos;
}

-(void)setListenerGain:(float)gain {
	alListenerfv(AL_GAIN, &gain);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting Listener Gain");
	}
}

-(float)getListenerGain {
	float gain;
	alGetListenerfv(AL_GAIN, &gain);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting Listener Gain");
	}
	return gain;
}

-(void)setListenerVelocity:(vec3)velocity {
	alListenerfv(AL_VELOCITY, &velocity.x);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting Listener Velocity");
	}
}

-(vec3)getListenerVelocity {
	vec3 velocity;
	alGetListenerfv(AL_VELOCITY, &velocity.x);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting Listener Velocity");
	}
	return velocity;
}

-(void)setListenerOrientation:(orientation3)orientation {
	alListenerfv(AL_ORIENTATION, &orientation.forward.x);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error setting Listener Orientation");
	}
}

-(orientation3)getListenerOrientation {
	orientation3 orientation;
	alGetListenerfv(AL_ORIENTATION, &orientation.forward.x);
	ALenum al_error = alGetError();
	if(AL_NO_ERROR != al_error) {
		//NSLog(@"Error getting Listener Orientation");
	}
	return orientation;
}

-(void)cleanUpOpenAL {
	// delete the sources
	alDeleteSources(MAX_SOUND_SOURCES, soundSourceList);

	for (int i=0; i<loadedBuffersCount; i++) {
		if (soundBufferList[i]) {
			alDeleteBuffers(1, &soundBufferList[i]);
		}
	}
	free(soundBufferList);

	// destroy the context
	alcDestroyContext(context);
	// close the device
	alcCloseDevice(device);
}

-(void)dealloc {
	//NSLog(@"dealloc:NezOpenAL");
	[self cleanUpOpenAL];
	[super dealloc];
}

@end
