//
//  StructureObjects.h
//  Aletteration
//
//  Created by David Nesbitt on 2/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Structures.h"

@interface Vec2Obj : NSObject {
@public
	vec2 vec;
}

+(Vec2Obj*)vec2ObjWithVec2:(vec2)vector;
-(id)initWithVec2:(vec2)vector;
	
@end

@interface Vec3Obj : NSObject {
@public
	vec3 vec;
}

+(Vec3Obj*)vec3ObjWithVec3:(vec3)vector;
-(id)initWithVec3:(vec3)vector;

@end


