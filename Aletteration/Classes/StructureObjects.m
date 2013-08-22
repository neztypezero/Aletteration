//
//  StructureObjects.m
//  Aletteration
//
//  Created by David Nesbitt on 2/22/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "StructureObjects.h"


@implementation Vec2Obj

+(Vec2Obj*)vec2ObjWithVec2:(vec2)vector {
	return [[[Vec2Obj alloc] initWithVec2:vector] autorelease];
}

-(id)initWithVec2:(vec2)vector {
	if ((self = [super init])) {
		vec = vector;
	}
	return self;
}

@end

@implementation Vec3Obj

+(Vec3Obj*)vec3ObjWithVec3:(vec3)vector {
	return [[[Vec3Obj alloc] initWithVec3:vector] autorelease];
}

-(id)initWithVec3:(vec3)vector {
	if ((self = [super init])) {
		vec = vector;
	}
	return self;
}

@end
