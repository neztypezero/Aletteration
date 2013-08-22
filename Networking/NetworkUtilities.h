//
//  NetworkUtilities.h
//  Aletteration
//
//  Created by David Nesbitt on 6/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//
#import <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>


char *getIpStr(const struct sockaddr *sa, char *s, size_t maxlen);
NSString* getLocalIPAddress();

