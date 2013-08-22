//
//  AletterationGKSessionController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-16.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneController.h"
#import <GameKit/GameKit.h>

@class AletterationGameState;
@class AletterationPlayerInfo;

@interface AletterationGKSessionController : NezBaseSceneController<GKSessionDelegate> {
	AletterationGameState *gameState;
	GKSession *_gameSession;
}

@property(nonatomic, retain, setter=setGameSession:) GKSession *gameSession;
@property(nonatomic, retain) NSArray *availablePeersArray;
@property(nonatomic, retain) NSMutableDictionary *incomingChunkDic;

@property(nonatomic, copy) NSString *serverID;

-(void)createSessionWithMode:(GKSessionMode)sessionMode;

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context;
-(void)receivedChunkPacket:(NSDictionary*)chunkMessage fromPeer:(NSString *)peerID;
-(void)receivedNetworkPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;

-(AletterationPlayerInfo*)getPlayerNameInfo;
-(AletterationPlayerInfo*)getPlayerPortraitInfo;

-(void)sendPlayerInfo:(AletterationPlayerInfo*)playerInfo toPeer:(NSString*)peerID;

-(void)sendMessage:(NSDictionary*)message toPeer:(NSString*)peerID;
-(void)sendMessage:(NSDictionary*)message toPeers:(NSArray*)peerArray;

-(void)broadcastMessage:(NSDictionary*)message;
-(void)broadcastMessage:(NSDictionary*)message excludingPeer:(NSString*)excludedPeeerID;

-(void)broadcastPlayerInfo:(AletterationPlayerInfo*)playerInfo;

-(void)invalidateSession;

@end
