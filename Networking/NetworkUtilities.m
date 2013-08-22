//
//  NetworkUtilities.m
//  Aletteration
//
//  Created by David Nesbitt on 6/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NetworkUtilities.h"

char *getIpStr(const struct sockaddr *sa, char *s, size_t maxlen) {
    switch(sa->sa_family) {
        case AF_INET:
            inet_ntop(AF_INET, &(((struct sockaddr_in *)sa)->sin_addr), s, maxlen);
            break;
        case AF_INET6:
            inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr), s, maxlen);
            break;
        default:
            strncpy(s, "Unknown AF", maxlen);
            return NULL;
    }
    return s;
}

NSString* getLocalIPAddress() { 
	NSString *address = @"error"; 
	struct ifaddrs *interfaces = NULL; struct ifaddrs *temp_addr = NULL;
	int success = 0; // retrieve the current interfaces - returns 0 on success  
	success = getifaddrs(&interfaces); 
	if (success == 0)  { 
		// Loop through linked list of interfaces  
		temp_addr = interfaces; 
		while(temp_addr != NULL)  {
			// Check if interface is en0 which is the wifi connection on the iPhone  
			if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])  { 
				if(temp_addr->ifa_addr->sa_family == AF_INET) {
					// Get NSString from C String  
					char ipCString[255];
					if(getIpStr(temp_addr->ifa_addr, ipCString, 255) != NULL) {
						address = [NSString stringWithUTF8String:ipCString]; 
					}
				}
			} 
			temp_addr = temp_addr->ifa_next;
		} 
	} 
	// Free memory  
	freeifaddrs(interfaces); 
	return address; 
}