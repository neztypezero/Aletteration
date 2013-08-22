//
//  SimpleObjLoader.m
//  Aletteration
//
//  Created by David Nesbitt on 2/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "SimpleObjLoader.h"
#import "StructureObjects.h"

@interface SimpleObjGroup : NSObject {
@public
	int firstIndex;
	int indexCount;
	int firstVertex;
	int vertexCount;
}

@end

@implementation SimpleObjGroup

-(id)initWithFirstVertex:(int)vertex Index:(int)index {
	if ((self = [super init])) {
		firstVertex = vertex;
		vertexCount = 0;
		firstIndex = index;
		indexCount = 0;
	}
	return self;
}

@end

@interface IndexedVertexObj : NSObject {
@public
	int vertexIndex;
	int normalIndex;
	int uvIndex;
	int vertexArrayIndex;
}

+(IndexedVertexObj*)indexedVertexObj;

@end

@implementation IndexedVertexObj

+(IndexedVertexObj*)indexedVertexObj {
	return [[[IndexedVertexObj alloc] init] autorelease];
}

-(id)init {
	if ((self = [super init])) {
		vertexIndex = -1;
		normalIndex = -1;	
		uvIndex = -1;	
		vertexArrayIndex = -1;	
	}
	return self;
}

@end

@interface SimpleObjLoader (private)

+(void)readVertexFrom:(char*)line into:(NSMutableArray*)vertexList;
+(void)readNormalFrom:(char*)line into:(NSMutableArray*)normalList;
+(void)readUVFrom:(char*)line into:(NSMutableArray*)uvList;
+(void)readFaceFrom:(char*)line into:(NSMutableArray*)indexList with:(NSMutableDictionary*)indexDic;
+(SimpleObjGroup*)readGroupFrom:(char*)line into:(NSMutableDictionary*)groupDictionary withFirstVertex:(int)firstVertex Index:(int)firstIndex;

@end

@implementation SimpleObjLoader

-(id)initWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	if ((self = [super init])) {
		groupDictionary = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
		vertexArray = [SimpleObjLoader loadVertexArrayWithFile:file Type:ext Dir:dir Groups:groupDictionary];
		if (vertexArray->vertexCount > 0) {
			vec3 min = vertexArray->vertexList[0].pos;
			vec3 max = vertexArray->vertexList[0].pos;
			for (int i=1; i<vertexArray->vertexCount; i++) {
				Vertex *v = &vertexArray->vertexList[i];
				if (min.x > v->pos.x) { min.x = v->pos.x; }
				if (min.y > v->pos.y) { min.y = v->pos.y; }
				if (min.z > v->pos.z) { min.z = v->pos.z; }
				if (max.x < v->pos.x) { max.x = v->pos.x; }
				if (max.y < v->pos.y) { max.y = v->pos.y; }
				if (max.z < v->pos.z) { max.z = v->pos.z; }
			}
			dimensions.w = max.x-min.x;
			dimensions.h = max.y-min.y;
			dimensions.d = max.z-min.z;
		} else {
			dimensions = SIZE3ZERO;
		}
	}
	return self;
}

-(NezVertexArray*)makeVertexArrayForGroup:(NSString*)groupName {
	if (groupDictionary) {
		SimpleObjGroup *group = [groupDictionary objectForKey:groupName];
		if (group) {
			NezVertexArray *array = [[NezVertexArray alloc] initWithVertexIncrement:group->vertexCount indexIncrement:group->indexCount];
			array->indexCount = group->indexCount;
			for (int i=0; i<group->indexCount; i++) {
				array->indexList[i] = vertexArray->indexList[group->firstIndex+i]-group->firstVertex;
			}
			array->vertexCount = group->vertexCount;
			memcpy(array->vertexList, &vertexArray->vertexList[group->firstVertex], sizeof(Vertex)*group->vertexCount);
			return array;
		}
	}
	return nil;
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir {
	return [SimpleObjLoader loadVertexArrayWithFile:file Type:ext Dir:dir Groups:nil];
}

+(NezVertexArray*)loadVertexArrayWithFile:(NSString*)file Type:(NSString*)ext Dir:(NSString*)dir Groups:(NSMutableDictionary*)groupDic {
	NSMutableArray *vertexList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *normalList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *uvList = [NSMutableArray arrayWithCapacity:128];
	NSMutableArray *indexList = [NSMutableArray arrayWithCapacity:128];
	NSMutableDictionary *indexDic = [NSMutableDictionary dictionaryWithCapacity:128];
	
	NSString *path = [SimpleObjLoader getModelResourceWithFile:file Type:ext Dir:dir];
	
	FILE *objFile = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "rb");
	char line[1024];
	
	SimpleObjGroup *curentGroup = nil;
	
	while (fgets(line, 1023, objFile)) {
		switch (line[0]) {
			case 'v':
				switch (line[1]) {
					case ' ':
						[SimpleObjLoader readVertexFrom:line into:vertexList];
						break;
					case 't':
						[SimpleObjLoader readUVFrom:line into:uvList];
						break;
					case 'n':
						[SimpleObjLoader readNormalFrom:line into:normalList];
						break;
					default:
						break;
				}
				break;
			case 'f':
				[SimpleObjLoader readFaceFrom:line into:indexList with:indexDic];
				break;
			case 'g':
				if (groupDic != nil && line[1] ==  ' ') {
					curentGroup = [SimpleObjLoader readGroupFrom:line into:groupDic withFirstVertex:[indexDic count] Index:[indexList count]];
				} else if (curentGroup) {
					curentGroup->vertexCount = [indexDic count]-curentGroup->firstVertex;
					curentGroup->indexCount = [indexList count]-curentGroup->firstIndex;
					curentGroup = nil;
				}
				break;
			default:
				break;
		}
	}
	if (curentGroup) {
		curentGroup->vertexCount = [indexDic count]-curentGroup->firstVertex;
		curentGroup->indexCount = [indexList count]-curentGroup->firstIndex;
		curentGroup = nil;
	}
	if ([indexList count] > 0) {
		NezVertexArray *varray = [[NezVertexArray alloc] initWithVertexIncrement:[indexDic count] indexIncrement:[indexList count]];
		varray->indexCount = [indexList count];
		varray->vertexCount = [indexDic count];
		
		for (IndexedVertexObj *indexedVertex in [indexDic objectEnumerator]) {
			Vertex *v = &varray->vertexList[indexedVertex->vertexArrayIndex];
			v->pos = ((Vec3Obj*)[vertexList objectAtIndex:indexedVertex->vertexIndex])->vec;
			v->uv = ((Vec2Obj*)[uvList objectAtIndex:indexedVertex->uvIndex])->vec;
			v->normal = ((Vec3Obj*)[normalList objectAtIndex:indexedVertex->normalIndex])->vec;
		}
		int i=0;
		for (IndexedVertexObj *indexedVertex in indexList) {
			varray->indexList[i++] = indexedVertex->vertexArrayIndex;
		}
		return varray;
	} else {
		return nil;
	}
}

+(float)getFloatFromCString:(char*)string Next:(char**)next {
	char *start = string;
	for(;;start++) {
		if (*start == '-') {
			break;
		}
		if (*start >= '0' && *start <= '9') {
			break;
		}
	}
	char *end = start;
	for(;;end++) {
		if ((*end >= '0' && *end <= '9') || *end == '-' || *end == '.') {
			continue;
		}
		break;
	}
	*end = '\0';
	*next = end+1;
	return atof(start);
}

+(void)readVertexFrom:(char*)line into:(NSMutableArray*)vertexList {
	vec3 pos = {
		[SimpleObjLoader getFloatFromCString:line Next:&line],
		[SimpleObjLoader getFloatFromCString:line Next:&line],
		[SimpleObjLoader getFloatFromCString:line Next:&line]
	};
	Vec3Obj *vertexObj = [Vec3Obj vec3ObjWithVec3:pos];
	[vertexList addObject:vertexObj];
}

+(void)readNormalFrom:(char*)line into:(NSMutableArray*)normalList {
	vec3 normal = {
		[SimpleObjLoader getFloatFromCString:line Next:&line],
		[SimpleObjLoader getFloatFromCString:line Next:&line],
		[SimpleObjLoader getFloatFromCString:line Next:&line]
	};
	Vec3Obj *normalObj = [Vec3Obj vec3ObjWithVec3:normal];
	[normalList addObject:normalObj];
}

+(void)readUVFrom:(char*)line into:(NSMutableArray*)uvList {
	vec2 uv = {
		[SimpleObjLoader getFloatFromCString:line Next:&line],
		1.0-[SimpleObjLoader getFloatFromCString:line Next:&line],
	};
	Vec2Obj *uvObj = [Vec2Obj vec2ObjWithVec2:uv];
	[uvList addObject:uvObj];
}

+(void)readFaceFrom:(char*)line into:(NSMutableArray*)indexList with:(NSMutableDictionary*)indexDic {
	NSString *string = [NSString stringWithFormat:@"%s", line];
	NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSCharacterSet *slashCharSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
	for (NSString *s in lines) {
		NSRange range = [s rangeOfCharacterFromSet:slashCharSet];
		if (range.location != NSNotFound) {
			IndexedVertexObj *indexedVertex = [IndexedVertexObj indexedVertexObj];
			IndexedVertexObj *value = [indexDic objectForKey:s];
			if (value) {
				indexedVertex->vertexArrayIndex = value->vertexArrayIndex;
			} else {
				NSArray *iList = [s componentsSeparatedByCharactersInSet:slashCharSet];
				indexedVertex->vertexIndex = [[iList objectAtIndex:0] integerValue]-1;
				indexedVertex->uvIndex = [[iList objectAtIndex:1] integerValue]-1;
				indexedVertex->normalIndex = [[iList objectAtIndex:2] integerValue]-1;
				indexedVertex->vertexArrayIndex = [indexDic count];
				[indexDic setObject:indexedVertex forKey:s];
			}
			[indexList addObject:indexedVertex];
		}
	}
}

+(SimpleObjGroup*)readGroupFrom:(char*)line into:(NSMutableDictionary*)groupDictionary withFirstVertex:(int)firstVertex Index:(int)firstIndex {
	NSString *string = [NSString stringWithFormat:@"%s", line];
	NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([words count] > 1) {
		SimpleObjGroup *group = [[[SimpleObjGroup alloc] initWithFirstVertex:firstVertex Index:firstIndex] autorelease];
		[groupDictionary setObject:group forKey:[words objectAtIndex:1]];
		return group;
	}
	return nil;
}

-(void)dealloc {
	//NSLog(@"dealloc:SimpleObjGroup");
	[groupDictionary removeAllObjects];
	[groupDictionary release];
	[vertexArray release];
	[super dealloc];
}

@end
