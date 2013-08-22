//
//  GLSLProgramManager.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "GLSLProgram.h"


@interface GLSLProgramManager : NSObject {
	NSMutableDictionary *programDict;
}

+(GLSLProgramManager*)instance;

- (GLSLProgram*) loadProgram:(NSString*)programName;

-(void)releaseAll;

@end
