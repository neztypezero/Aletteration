//
//  GLSLProgramManager.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "GLSLProgramManager.h"


GLSLProgramManager *g_GLSLProgramManager;
NSLock *programMutex;

@implementation GLSLProgramManager

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_GLSLProgramManager = [[GLSLProgramManager alloc] init];
		programMutex=[NSLock new];
    }
}

+ (GLSLProgramManager*)instance {
	return(g_GLSLProgramManager);
}

- (id) init {
	if ((self = [super init])) {
		programDict = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	return self;
}

- (GLSLProgram*) loadProgram:(NSString*)programName {
	[programMutex lock];
	GLSLProgram *programObject = [programDict objectForKey:programName];
	if (!programObject) {
		programObject = [[[GLSLProgram alloc] initWithProgramName:programName] autorelease];
		[programDict setObject:programObject forKey:programName];
	}
	[programMutex unlock];
	return programObject;
}

- (void) dealloc {
	[self releaseAll];
	[programDict release];
	
    [super dealloc];
}

- (void) releaseAll {
	[programDict removeAllObjects];
}


@end
