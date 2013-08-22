//
//  SimpleObjLoader.h
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezModelLoader.h"

@interface SimpleObjLoader : NezModelLoader {
	NSMutableDictionary *groupDictionary;
}

-(NezVertexArray*)makeVertexArrayForGroup:(NSString*)groupName;

@end
