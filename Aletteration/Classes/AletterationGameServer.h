//
//  AletterationServerDelegate.h
//  Aletteration
//
//  Created by David Nesbitt on 5/17/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "Server.h"
#import "ServerDelegate.h"
#import "ConnectionDelegate.h"
#import "AletterationPlayerInfo.h"
#import "ServerConnectionDelegate.h"

@class AletterationGameState;

@interface AletterationGameServer : NSObject<ServerDelegate, ConnectionDelegate> {
   	Server* server;
	// Container for all connected clients
	NSMutableArray *clients;
	AletterationGameState *gameState;
	
	id<ServerConnectionDelegate> delegate;
}

-(BOOL)start:(NSString*)serviceName;
-(void)stop;

-(AletterationPlayerInfo*)getPlayerInfoForIndex:(int)index;

-(void)startGame;
-(void)broadcastPlayerInfo:(AletterationPlayerInfo*)playerInfo;
-(void)broadcastPlayer:(NSString*)playerIP row:(int)row forTurn:(int)turn;
-(void)broadcastLetterIndex:(int)letterIndex;
-(void)broadcastAddWordWithPlayer:(NSString*)playerIP row:(int)row wordLength:(int)wordLength;
-(void)broadcastGameOverWithPlayerIP:(NSString*)playerIP;
-(void)broadcastConnectionDroppedWithPlayerIP:(NSString*)playerIP;

@property(nonatomic,retain) id<ServerConnectionDelegate> delegate;
@property(nonatomic, readonly, getter=getPlayerCount) int playerConnectedCount;

@end
