//
//  ServerConnectionDelegate.h
//  Aletteration
//
//  Created by David Nesbitt on 6/4/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NetworkConnection.h"

@protocol ServerConnectionDelegate

-(void)connectionAdded:(NetworkConnection*)connection;
-(void)connectionDropped:(NetworkConnection*)connection;

-(void)recievedMessage:(NSDictionary*)message viaConnection:(NetworkConnection*)connection;

@end
