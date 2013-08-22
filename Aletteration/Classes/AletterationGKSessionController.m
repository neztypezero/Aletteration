//
//  AletterationGKSessionController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGKSessionController.h"
#import "AletterationGameState.h"
#import "AletterationNetCmd.h"
#import "GameKitConstants.h"
#import "AletterationPlayerInfo.h"

#define MAX_PAYLOAD_SIZE 8192

@implementation AletterationGKSessionController

@synthesize serverID;
@synthesize gameSession = _gameSession;
@synthesize availablePeersArray;
@synthesize incomingChunkDic;

-(GKSessionMode)getSessionMode {
	return GKSessionModeServer;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		gameState = [AletterationGameState instance];
		_gameSession = nil;
		self.availablePeersArray = nil;
		self.incomingChunkDic = [NSMutableDictionary dictionaryWithCapacity:16];
    }
    return self;
}

-(void)createSessionWithMode:(GKSessionMode)sessionMode {
	[gameState resetPlayerInfoList];

	NSString *displayName = gameState.localPlayerInfo.name;
	GKSession *session = [[GKSession alloc] initWithSessionID:ALETTERATION_SESSION_ID displayName:displayName sessionMode:sessionMode];
	self.gameSession = session;
	self.gameSession.available = YES;
	[session release];
}

-(void)setGameSession:(GKSession*)session {
	if (_gameSession != nil) {
		_gameSession.available = NO;
		_gameSession.delegate = nil; 
		[_gameSession setDataReceiveHandler:nil withContext:NULL];
		[_gameSession release];
		_gameSession = nil;
	}
	if (session != nil) {
		_gameSession = [session retain];
		
		//Must set local playerInfo.ip to peerID
		gameState.localPlayerInfo.ip = _gameSession.peerID;
		
		_gameSession.delegate = self; 
		[_gameSession setDataReceiveHandler:self withContext:NULL];
	}
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	self.availablePeersArray = [session peersWithConnectionState:GKPeerStateConnected];
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSError* error=nil;
	BOOL success = [session acceptConnectionFromPeer:peerID error:&error];
	if (!success) {
		//NSLog(@"%@", [error localizedFailureReason]);
	}
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	//NSLog(@"connectionWithPeerFailed:%@", peerID);
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error {
	//NSLog(@"didFailWithError");
}

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession: (GKSession *)session context:(void *)context {
	@try {
		NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		for (NSString *key in [message allKeys]) {
			if ([key isEqualToString:NET_CMD_CHUNK]) {
				[self receivedChunkPacket:[message objectForKey:NET_CMD_CHUNK] fromPeer:peerID];
				return;
			}
		}
		[self receivedNetworkPacket:message fromPeer:peerID];
	} @catch (NSException *exception) {
		//NSLog(@"%@", [exception callStackSymbols]);
	} @finally {
	}
}

-(void)receivedChunkPacket:(NSDictionary*)chunkMessage fromPeer:(NSString *)peerID {
	NSNumber *chunkIndex = [chunkMessage objectForKey:NET_CMD_CHUNK_INDEX];
	NSNumber *chunkCount = [chunkMessage objectForKey:NET_CMD_CHUNK_COUNT];
	NSData *chunkData = [chunkMessage objectForKey:NET_CMD_CHUNK_DATA];
	
	NSMutableArray *chunkArray = [self.incomingChunkDic objectForKey:peerID];
	if (chunkArray == nil) {
		chunkArray = [NSMutableArray arrayWithCapacity:[chunkCount intValue]];
		[self.incomingChunkDic setObject:chunkArray forKey:peerID];
	}
	if ([chunkIndex intValue] == [chunkArray count]) {
		[chunkArray addObject:chunkData];
	} else {
		//NSLog(@"Packet Order Error!!!");
	}
	if ([chunkArray count] == [chunkCount intValue]) {
		NSUInteger capacity = 0;
		for (NSData *chunk in chunkArray) {
			capacity += [chunk length];
		}
		NSMutableData *joinedChunkData = [NSMutableData dataWithCapacity:capacity];
		for (NSData *chunk in chunkArray) {
			[joinedChunkData appendData:chunk];
		}
		NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:joinedChunkData];
		[self receivedNetworkPacket:message fromPeer:peerID];
		[self.incomingChunkDic removeObjectForKey:peerID];
	}
}

-(void)receivedNetworkPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
}

-(void)sendMessage:(NSDictionary*)message toPeer:(NSString*)peerID {
	[self sendMessage:message toPeers:[NSArray arrayWithObject:peerID]];
}

-(void)sendMessage:(NSDictionary*)message toPeers:(NSArray*)peerArray {
	NSError* error=nil;
	NSData* messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
	
	NSUInteger length = [messageData length];
	if (length > MAX_PAYLOAD_SIZE) {
		NSRange range;
		NSMutableArray *chunkArray = [NSMutableArray arrayWithCapacity:(length/MAX_PAYLOAD_SIZE)+1];
		for (int loc=0;loc<length;) {
			int nextIndex = loc+MAX_PAYLOAD_SIZE;
			if (nextIndex > length) {
				range = NSMakeRange(loc, length-loc);
			} else {
				range = NSMakeRange(loc, MAX_PAYLOAD_SIZE);
			}
			loc = nextIndex;
			[chunkArray addObject:[messageData subdataWithRange:range]];
		}
		int packetIndex = 0;
		int packetCount = [chunkArray count];
		for (NSData *chunkData in chunkArray) {
			NSDictionary *chunkDataMessage = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:packetIndex++], NET_CMD_CHUNK_INDEX,
				[NSNumber numberWithInt:packetCount], NET_CMD_CHUNK_COUNT,
				chunkData, NET_CMD_CHUNK_DATA,
				nil
			];
			NSDictionary *chunkMessage = [NSDictionary dictionaryWithObjectsAndKeys:chunkDataMessage, NET_CMD_CHUNK, nil];
			NSData *chunkOut = [NSKeyedArchiver archivedDataWithRootObject:chunkMessage];
			
			BOOL success = [self.gameSession sendData:chunkOut toPeers:peerArray withDataMode:GKSendDataReliable error:&error];
			if (!success) {
				//NSLog(@"%@", [error localizedFailureReason]);
			}
		}
	} else {
		BOOL success = [self.gameSession sendData:messageData toPeers:peerArray withDataMode:GKSendDataReliable error:&error];
		if (!success) {
			//NSLog(@"%@", [error localizedFailureReason]);
		}
	}
}

-(void)broadcastPlayerInfo:(AletterationPlayerInfo*)playerInfo {
	if (playerInfo != nil) {
		NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerInfo, NET_CMD_PLAYER_INFO, nil];
		[self broadcastMessage:message excludingPeer:playerInfo.ip];
	}
}

-(void)sendPlayerInfo:(AletterationPlayerInfo*)playerInfo toPeer:(NSString*)peerID {
	if (playerInfo != nil) {
		NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerInfo, NET_CMD_PLAYER_INFO, nil];
		[self sendMessage:message toPeer:peerID];
	}
}

-(AletterationPlayerInfo*)getPlayerNameInfo {
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	if (playerInfo.name != nil) {
		AletterationPlayerInfo *playerNameInfo = [AletterationPlayerInfo blankInfo];
		playerNameInfo.name = playerInfo.name;
		playerNameInfo.ip = playerInfo.ip;
		return playerNameInfo;
	}
	return nil;
}

-(AletterationPlayerInfo*)getPlayerPortraitInfo {
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	if (playerInfo.portrait != nil) {
		AletterationPlayerInfo *playerPortaitInfo = [AletterationPlayerInfo blankInfo];
		playerPortaitInfo.portrait = playerInfo.portrait;
		playerPortaitInfo.ip = playerInfo.ip;
		return playerPortaitInfo;
	}
	return nil;
}

-(void)broadcastMessage:(NSDictionary*)message {
	[self broadcastMessage:message excludingPeer:self.gameSession.peerID];
}

-(void)broadcastMessage:(NSDictionary*)message excludingPeer:(NSString*)excludedPeeerID {
	NSMutableArray *peerList = [NSMutableArray arrayWithCapacity:16];
	NSString *bagmanPeerID = _gameSession.peerID;
	for (AletterationPlayerInfo *pInfo in gameState.playerInfoList.allValues) {
		if ([pInfo.ip compare:excludedPeeerID] != NSOrderedSame && [pInfo.ip compare:bagmanPeerID] != NSOrderedSame) {
			[peerList addObject:pInfo.ip];
		}
	}
	if ([peerList count] > 0) {
		[self sendMessage:message toPeers:peerList];
	}
}

-(void)invalidateSession {
	if(self.gameSession != nil) {
		self.gameSession.available = NO; 
		[self.gameSession disconnectFromAllPeers]; 
		[self.gameSession setDataReceiveHandler: nil withContext: NULL]; 
		self.gameSession.delegate = nil;
		self.gameSession = nil;
	}
}

-(void)dealloc {
	[self invalidateSession];
	self.availablePeersArray = nil;
	self.incomingChunkDic = nil;
	self.serverID = nil;
	[super dealloc];
}

@end
