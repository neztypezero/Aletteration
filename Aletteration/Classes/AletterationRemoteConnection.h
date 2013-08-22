//
//  AletterationRemoteConnection.h
//  Aletteration
//
//  Created by David Nesbitt on 5/21/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NetworkConnection.h"
#import "ConnectionDelegate.h"
#import "GameConnectionDelegate.h"
#import "AletterationPlayerInfo.h"

@class AletterationGameState;

@interface AletterationRemoteConnection : NSObject<ConnectionDelegate> {
	// Our connection to the game server
	NetworkConnection *connection;
	id<GameConnectionDelegate>delegate;
	AletterationGameState *gameState;
}

@property(nonatomic,retain) id<GameConnectionDelegate> delegate;

// Initialize with a reference to a net service discovered via Bonjour
-(id)initWithNetService:(NSNetService*)netService;

-(void)sendPlayerName;     //send just the player's name
-(void)sendPlayerPortrait; //send just the player's portrait
-(void)sendPlayerInfo;     //send whole playerinfo object

-(void)sendUsedRow:(int)row andTurnIndex:(int)turn;
-(void)sendAddWordWithRow:(int)row wordLength:(int)wordLength;
-(void)sendGameOver;

-(void)sendMessage:(NSDictionary*)message;

-(BOOL)start;
-(void)stop;

@end
