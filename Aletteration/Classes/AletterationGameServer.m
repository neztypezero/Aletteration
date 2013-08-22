//
//  AletterationServerDelegate.m
//  Aletteration
//
//  Created by David Nesbitt on 5/17/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameServer.h"
#import "NetworkConnection.h"
#import "AletterationNetCmd.h"
#import "AletterationGameState.h"

// Private properties
@interface AletterationGameServer ()
@property(nonatomic,retain) Server* server;
@property(nonatomic,retain) NSMutableArray* clients;

-(void)receivedUsedRowPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection;
-(void)receivedPlayerInfoPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection;
-(void)receivedAddWordPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection;
-(void)receivedGameOverPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection;

@end

@implementation AletterationGameServer

@synthesize delegate;
@synthesize server, clients;

-(id)init {
	if((self = [super init])) {
		server = nil;
		clients = [[NSMutableArray alloc] init];
		delegate = nil;
		gameState = [AletterationGameState instance];
	}
	return self;
}

-(AletterationPlayerInfo*)getServerPlayerInfo {
	return (AletterationPlayerInfo*)[gameState.playerInfoList objectForKey:@""];
}

-(AletterationPlayerInfo*)getPlayerInfoForIndex:(int)index {
	if (index >=0 && index < [clients count]) {
		NetworkConnection *connection = [clients objectAtIndex:index];
		AletterationPlayerInfo *info = [gameState.playerInfoList objectForKey:connection.hostAddress];
		return info;
	}
	return nil;
}

-(AletterationPlayerInfo*)getPlayerInfoForIP:(NSString*)ip {
	if (ip == nil) {
		return nil;
	}
	AletterationPlayerInfo *info = [gameState.playerInfoList objectForKey:ip];
	return info;
}

// Stop everything
-(void)stop {
	// Destroy server
	[server stop];
	self.server = nil;
	
	// Close all connections
	[clients makeObjectsPerformSelector:@selector(close)];
	[clients removeAllObjects];
	[gameState resetPlayerInfoList];
}

// Server has been terminated because of an error
-(void)serverFailed:(Server*)server reason:(NSString*)reason {
	[self stop];
}

// Server has accepted a new connection and it needs to be processed
-(void)handleNewConnection:(NetworkConnection*)connection {
	// Delegate everything to us
	connection.delegate = self;
	
//	AletterationPlayerInfo *info = [AletterationPlayerInfo blankInfo];
//	info.ip = connection.hostAddress;
	
	// Add to our list of clients
	[clients addObject:connection];
//	[gameState.playerInfoList setObject:info forKey:info.ip];
	
	[delegate connectionAdded:connection];
}

-(void)connectionAttemptFailed:(NetworkConnection*)connection {
	
}

-(void)connectionTerminated:(NetworkConnection*)connection {
	[connection retain];
	[gameState.playerInfoList removeObjectForKey:connection.hostAddress];
	[clients removeObject:connection];
	[delegate connectionDropped:connection];
	[connection release];
}

-(int)getPlayerCount {
	return [clients count];
}

-(NSArray*)getPlayerList {
	NSMutableArray *playerList = [NSMutableArray arrayWithArray:[gameState.playerInfoList allValues]];
	return playerList;
}

-(void)receivedNetworkPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection {
	for (NSString *key in [message allKeys]) {
		if ([key isEqualToString:NET_CMD_PLAYER_INFO]) {
			[self receivedPlayerInfoPacket:message viaConnection:connection];
		} else if ([key isEqualToString:NET_CMD_ROW_INDEX]) {
			[self receivedUsedRowPacket:message viaConnection:connection];
		} else if ([key isEqualToString:NET_CMD_ADD_WORD]) {
			[self receivedAddWordPacket:[message objectForKey:key] viaConnection:connection];
		} else if ([key isEqualToString:NET_CMD_GAME_OVER]) {
			[self receivedGameOverPacket:message viaConnection:connection];
		}
	}
	[delegate recievedMessage:message viaConnection:connection];
}

-(void)receivedUsedRowPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection {
	NSNumber *index = [message objectForKey:NET_CMD_ROW_INDEX];
	if (index != nil) {
		NSNumber *tindex = [message objectForKey:NET_CMD_TURN];
		int lineIndex = [index intValue];
		int turnIndex = [tindex intValue];
		AletterationPlayerInfo *playerInfo = [self getPlayerInfoForIP:connection.hostAddress];
		[gameState setCharAtLine:lineIndex toPlayer:playerInfo];
		
		NSString *ip = connection.hostAddress;
		[self broadcastPlayer:ip row:lineIndex forTurn:turnIndex];
	}
}

-(void)receivedPlayerInfoPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection {
	AletterationPlayerInfo *playerInfo = [message objectForKey:NET_CMD_PLAYER_INFO];
	BOOL isNewPlayer = [gameState updatePlayerInfo:playerInfo];
	
	if (isNewPlayer) {
		NSArray *playerList = [self getPlayerList];
		NSDictionary *playerListMessage = [NSDictionary dictionaryWithObjectsAndKeys:playerList, NET_CMD_PLAYER_LIST, nil];
		[connection sendNetworkPacket:playerListMessage];
	}
	[self broadcastPlayerInfo:playerInfo];
}

-(void)receivedAddWordPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection {
	NSNumber *row = [message objectForKey:NET_CMD_ROW_INDEX];
	NSNumber *wordLength = [message objectForKey:NET_CMD_WORD_LENGTH];
	NSString *ip = connection.hostAddress;
	
	[self broadcastAddWordWithPlayer:ip row:[row intValue] wordLength:[wordLength intValue]];
	[gameState completeWordForPlayerIP:ip lineIndex:[row intValue] wordLength:[wordLength intValue]];
}

-(void)receivedGameOverPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)connection {
	NSString *ip = connection.hostAddress;

	[self broadcastGameOverWithPlayerIP:ip];
	[gameState setGameOverForPlayerIP:ip];
}

-(BOOL)start:(NSString*)serviceName {
	if (server != nil) {
		[self stop];
	}
	// Create new instance of the server and start it up
	server = [[Server alloc] init];
	
	// We will be processing server events
	server.delegate = self;
	
	// Try to start it up
	if (![server start:serviceName]) {
		self.server = nil;
		return NO;
	}
	gameState.localPlayerInfo.name = serviceName;
	
	return YES;
}

-(void)broadcastMessage:(NSDictionary*)message excludingIP:(NSString*)excludedIP {
	for (NetworkConnection *connection in clients) {
		if ([connection.hostAddress compare:excludedIP] != NSOrderedSame) {
			[connection sendNetworkPacket:message];
		}
	}
}

-(void)broadcastPlayerInfo:(AletterationPlayerInfo*)playerInfo {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerInfo, NET_CMD_PLAYER_INFO, nil];
	[self broadcastMessage:message excludingIP:playerInfo.ip];
}

-(void)broadcastPlayer:(NSString*)playerIP row:(int)row forTurn:(int)turn {
	NSDictionary *playerRowDic = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX, 
								  [NSNumber numberWithInt:turn], NET_CMD_TURN, 
								  playerIP, NET_CMD_PLAYER_IP, 
								 nil];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerRowDic, NET_CMD_PLAYER_ROW, nil];
	[self broadcastMessage:message excludingIP:playerIP];
}

-(void)broadcastAddWordWithPlayer:(NSString*)playerIP row:(int)row wordLength:(int)wordLength {
	NSDictionary *playerWordDic = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX, 
								  [NSNumber numberWithInt:wordLength], NET_CMD_WORD_LENGTH, 
								  playerIP, NET_CMD_PLAYER_IP, 
								  nil];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerWordDic, NET_CMD_ADD_WORD, nil];
	[self broadcastMessage:message excludingIP:playerIP];
}

-(void)broadcastLetterIndex:(int)letterIndex {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:letterIndex], NET_CMD_LETTER_INDEX, nil];
	[self broadcastMessage:message excludingIP:@""];
}

-(void)broadcastGameOverWithPlayerIP:(NSString*)playerIP {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerIP, NET_CMD_GAME_OVER, nil];
	[self broadcastMessage:message excludingIP:playerIP];
}

-(void)broadcastConnectionDroppedWithPlayerIP:(NSString*)playerIP {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerIP, NET_CMD_PLAYER_DROPPED, nil];
	[self broadcastMessage:message excludingIP:@""];

}

-(void)startGame {
	[server unpublishService];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:@"", NET_CMD_START_GAME, nil];
	for (NetworkConnection *connection in clients) {
		[connection sendNetworkPacket:message];
	}
}

-(void)streamsOpenComplete {
}

-(void)dealloc {
	[self stop];
	self.clients = nil;
	self.server = nil;
	self.delegate = nil;
	[super dealloc];
}

@end
