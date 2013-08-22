//
//  AletterationServerBrowser.m
//  Aletteration
//
//  Created by David Nesbitt on 6/13/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationServerBrowser.h"
#import "NetworkUtilities.h"


@implementation AletterationServerBrowser

-(id)init {
	if((self = [super init])) {
		bagmanInfoDic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)addServerToList:(NSNetService *)netService {
	for (NSData* data in [netService addresses]) {
		struct sockaddr *addr = (struct sockaddr *)[data bytes];
		char s[SOCK_MAXADDRLEN];
		if(getIpStr(addr, s, SOCK_MAXADDRLEN)) {
			//NSString *host = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
		}
	}
	
	[super addServerToList:netService];
}

-(void)removeServerFromList:(NSNetService *)netService {
	[super removeServerFromList:netService];
}

-(void)dealloc {
	[bagmanInfoDic release];
	[super dealloc];
}

@end
