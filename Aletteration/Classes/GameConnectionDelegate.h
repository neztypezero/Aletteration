//
//  GameConnectionDelegate.h
//  Aletteration
//
//  Created by David Nesbitt on 5/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

@protocol GameConnectionDelegate

-(void)receivedMessage:(NSDictionary*)message;
-(void)gameTerminated:(id)gameConnection reason:(NSString*)string;
-(void)finishedConnecting;

@end
