//
//  NezObjGeometry.h
//  Aletteration
//
//  Created by David Nesbitt on 3/15/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezGeometry.h"
#import "NezVertexArray.h"


@interface NezObjGeometry : NezGeometry {
    NezVertexArray* objVertexArray;

}

-(id)initWithObjFile:(NSString*)name VertexArray:(NezVertexArray*)vertexArray modelMatrix:(mat4)mat color:(color4uc)c;

@end
