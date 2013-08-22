//
//  AletterationRemoteConnection.m
//  Aletteration
//
//  Created by David Nesbitt on 5/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationRemoteConnection.h"
#import "AletterationNetCmd.h"
#import "AletterationGameState.h"
#import "NetworkUtilities.h"


// Private properties
@interface AletterationRemoteConnection ()

@property(nonatomic,retain) NetworkConnection *connection;

-(void)receivedAddWordPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con;
-(void)receivedPlayerRowPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con;
-(void)receivedGameOverPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con;
-(void)receivedPlayerDroppedPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con;

@end

@implementation AletterationRemoteConnection

@synthesize delegate;
@synthesize connection;

// Initialize and connect to a net service
- (id)initWithNetService:(NSNetService*)netService {
	if((self = [super init])) {
		gameState = [AletterationGameState instance];
		connection = [[NetworkConnection alloc] initWithNetService:netService];
		[gameState resetLocalPlayerInfo];
	}
	return self;
}

-(void)sendPlayerName {
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	if (playerInfo.name != nil) {
		AletterationPlayerInfo *playerName = [AletterationPlayerInfo blankInfo];
		playerName.name = playerInfo.name;
		playerName.ip = playerInfo.ip;
		NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerName, NET_CMD_PLAYER_INFO, nil];
		[self sendMessage:message];
	}
}

-(void)sendPlayerPortrait {
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	if (playerInfo.portrait != nil) {
		AletterationPlayerInfo *playerPortait = [AletterationPlayerInfo blankInfo];
		playerPortait.portrait = playerInfo.portrait;
		playerPortait.ip = playerInfo.ip;
		NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerPortait, NET_CMD_PLAYER_INFO, nil];
		[self sendMessage:message];
	}
}

-(void)sendPlayerInfo {
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	if (playerInfo.name != nil && playerInfo.portrait != nil) {
		NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerInfo, NET_CMD_PLAYER_INFO, nil];
		[self sendMessage:message];
	}
}

-(void)sendUsedRow:(int)row andTurnIndex:(int)turn {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX,
							 [NSNumber numberWithInt:turn], NET_CMD_TURN, 
							 nil];
	[self sendMessage:message];
}

-(void)sendAddWordWithRow:(int)row wordLength:(int)wordLength {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX, 
								   [NSNumber numberWithInt:wordLength], NET_CMD_WORD_LENGTH, 
								   nil];
	NSDictionary *addRow = [NSDictionary dictionaryWithObjectsAndKeys:message, NET_CMD_ADD_WORD, nil];
	[self sendMessage:addRow];
}

-(void)sendGameOver {
	NSString *ip = gameState.localPlayerInfo.ip;
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:ip, NET_CMD_GAME_OVER, nil];
	[self sendMessage:message];
}

// Send message to the server
-(void)sendMessage:(NSDictionary*)message {
	[connection sendNetworkPacket:message];
}

// Start everything up, connect to server
-(BOOL)start {
	if(connection == nil) {
		return NO;
	}
	// We are the delegate
	connection.delegate = self;
	
	return [connection connect];
}


// Stop everything, disconnect from server
-(void)stop {
	if(connection == nil) {
		return;
	}
	[connection close];
	self.connection = nil;
	[delegate gameTerminated:self reason:@"Connection to server closed"];
}

#pragma mark ConnectionDelegate Method Implementations

-(void)connectionAttemptFailed:(NetworkConnection*)connection {
	[delegate gameTerminated:self reason:@"Wasn't able to connect to server"];
}

-(void)connectionTerminated:(NetworkConnection*)connection {
	[delegate gameTerminated:self reason:@"Connection to server closed"];
}

-(void)streamsOpenComplete {
	[delegate finishedConnecting];
}

-(void)receivedNetworkPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con {
	for (NSString *key in [message allKeys]) {
		if ([key isEqualToString:NET_CMD_PLAYER_LIST]) {
			[gameState setPlayerList:[message objectForKey:key]];
		} else if ([key isEqualToString:NET_CMD_PLAYER_INFO]) {
			[gameState updatePlayerInfo:[message objectForKey:key]];
		} else if ([key isEqualToString:NET_CMD_PLAYER_ROW]) {
			[self receivedPlayerRowPacket:message viaConnection:con];
		} else if ([key isEqualToString:NET_CMD_ADD_WORD]) {
			[self receivedAddWordPacket:[message objectForKey:key] viaConnection:con];
		} else if ([key isEqualToString:NET_CMD_GAME_OVER]) {
			[self receivedGameOverPacket:message viaConnection:con];
		} else if ([key isEqualToString:NET_CMD_PLAYER_DROPPED]) {
			[self receivedPlayerDroppedPacket:message viaConnection:con];
		}
	}
	[delegate receivedMessage:message];
}

-(void)receivedAddWordPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con {
	NSNumber *row = [message objectForKey:NET_CMD_ROW_INDEX];
	NSNumber *wordLength = [message objectForKey:NET_CMD_WORD_LENGTH];
	NSString *ip = [message objectForKey:NET_CMD_PLAYER_IP];
	
	[gameState completeWordForPlayerIP:ip lineIndex:[row intValue] wordLength:[wordLength intValue]];
}

-(void)receivedPlayerRowPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con {
	NSDictionary *rowInfoDic = [message objectForKey:NET_CMD_PLAYER_ROW];
	
	NSNumber *rowIndex = [rowInfoDic objectForKey:NET_CMD_ROW_INDEX];
	NSNumber *turn = [rowInfoDic objectForKey:NET_CMD_TURN];
	NSString *ip = [rowInfoDic objectForKey:NET_CMD_PLAYER_IP];
	
	if (rowIndex != nil && turn != nil && ip != nil) {
		AletterationPlayerInfo *playerInfo = [gameState getPlayerInfoForIP:ip];
		if (playerInfo != nil) {
			int lineIndex = [rowIndex intValue];
			int currentTurn = [turn intValue];
			[gameState setCharAtLine:lineIndex toPlayer:playerInfo forTurn:currentTurn];
		}
	}
}

-(void)receivedGameOverPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con {
	NSString *ip = [message objectForKey:NET_CMD_GAME_OVER];
	[gameState setGameOverForPlayerIP:ip];
}

-(void)receivedPlayerDroppedPacket:(NSDictionary*)message viaConnection:(NetworkConnection*)con {
	NSString *ip = [message objectForKey:NET_CMD_PLAYER_DROPPED];
	[gameState dropPlayerForIP:ip];
}

// Cleanup
- (void)dealloc {
	self.delegate = nil;
	self.connection = nil;
	[super dealloc];
}

@end
