//
//  NezVertexArrayArray.h
//  Aletteration
//
//  Created by David Nesbitt on 3/12/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezVertexArray.h"


@interface NezVertexArrayArray : NSObject {
	int vertexArrayLength;
	int vertexArrayIncrement;
@public
	NezVertexArray **vertexArrayList;
	int vertexArrayCount;
}

-(id)init;
-(void)addVertexArray:(NezVertexArray*)vertexArray;

@end
