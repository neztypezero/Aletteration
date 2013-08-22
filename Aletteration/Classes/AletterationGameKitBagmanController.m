//
//  AletterationGameKitBagmanController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-17.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameKitBagmanController.h"
#import "AletterationGameKitPlayerView.h"
#import "AletterationNetCmd.h"
#import "WaitForPlayersView.h"
#import "AletterationGameState.h"
#import "UIWaitingPlayerTableViewCell.h"
#import "AnimatedWord.h"

@interface AletterationGameKitBagmanController ()

-(void)dropPeer:(NSString*)peerID;
-(void)reloadData;

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString*)peerID;
-(void)receivedUsedRowPacket:(NSDictionary*)message fromPeer:(NSString*)peerID;
-(void)receivedAddWordPacket:(NSDictionary*)message fromPeer:(NSString*)peerID;
-(void)receivedGameOverPacket:(NSDictionary*)message fromPeer:(NSString*)peerID;

-(void)broadcastStartGameMessage;
-(void)broadcastLetterIndex:(int)letterIndex;
-(void)broadcastRowIndex:(int)row andTurn:(int)turn forPlayer:(NSString*)peerID;
-(void)broadcastGameOverForPlayer:(NSString*)peerID;
-(void)broadcastAddWordFromRow:(int)row wordLength:(int)wordLength forPlayer:(NSString*)peerID word:(NSString*)word;

-(void)fadeInWaitView;
-(void)fadeOutWaitView;

-(void)allPlayersHaveFinished;

@end

@implementation AletterationGameKitBagmanController

-(void)viewDidLoad {
	if (self.gameSession == nil && self.loadParams != nil) {
		self.gameSession = self.loadParams;
		self.loadParams = nil;
		[self broadcastStartGameMessage];
	}
	[super viewDidLoad];
	
	AletterationGameKitPlayerView *view = (AletterationGameKitPlayerView*)self.view;
	[view.waitingForPlayersView loadRoundCornersAndBorders];
	view.waitingForPlayersView.playerTableView.delegate = self;
	view.waitingForPlayersView.playerTableView.dataSource = self;
}

-(void)waitForNextTurn {
	[gameState getSelectedBlock];
	[self broadcastLetterIndex:gameState.currentLetterIndex];
	[super waitForNextTurn];
}

-(void)waitForEndTurn {
	if (![gameState isNextTurnOverForAllPlayers]) {
		[self fadeInWaitView];
	} else {
		[self allPlayersHaveFinished];
	}
}

-(void)waitForAllPlayersToFinishTurn {
	if (![gameState isNextTurnOverForAllPlayers]) {
		[self performSelector:@selector(waitForAllPlayersToFinishTurn) withObject:nil afterDelay:0.5];
	} else {
		[self fadeOutWaitView];
	}
}

-(void)allPlayersHaveFinished {
	[super waitForEndTurn];
}

-(void)letterAddedToLineIndex:(int)lineIndex {
	[self broadcastRowIndex:lineIndex andTurn:gameState.currentTurn forPlayer:self.gameSession.peerID];
	[super letterAddedToLineIndex:lineIndex];
}

-(void)doGameOver {
	[self broadcastGameOverForPlayer:self.gameSession.peerID];
	if (![gameState isGameOverForAllPlayers]) {
		[self fadeInWaitView];
	} else {
		[super doGameOver];
	}
}

-(void)waitForGameOverForAllPlayers {
	if (![gameState isGameOverForAllPlayers]) {
		[self performSelector:@selector(waitForGameOverForAllPlayers) withObject:nil afterDelay:0.5];
	} else {
		[self fadeOutWaitView];
	}
}

-(void)fadeInWaitView {
	AletterationGameKitPlayerView *view = (AletterationGameKitPlayerView*)self.view;
	[self reloadData];
	view.waitingForPlayersView.alpha = 0.0;
	view.waitingForPlayersView.hidden = NO;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 view.waitingForPlayersView.alpha = 1.0;
					 }
					 completion:^(BOOL completed){
						 if (gameState.localPlayerInfo.gameOver) {
							 [self waitForGameOverForAllPlayers];
						 } else {
							 [self waitForAllPlayersToFinishTurn];
						 }
					 }
	 ];
}

-(void)fadeOutWaitView {
	AletterationGameKitPlayerView *view = (AletterationGameKitPlayerView*)self.view;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 view.waitingForPlayersView.alpha = 0.0;
					 }
					 completion:^(BOOL completed){
						 view.waitingForPlayersView.hidden = YES;
						 if (gameState.localPlayerInfo.gameOver) {
//							 gameState.gameServer.delegate = nil;
//							 [gameState.gameServer stop];
							 [super doGameOver];
						 } else {
							 [self allPlayersHaveFinished];
						 }
					 }
	 ];
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	switch (state) {
		case GKPeerStateAvailable:
			break;
		case GKPeerStateUnavailable:
			break;
		case GKPeerStateConnected:
			break;
		case GKPeerStateDisconnected:
			[self dropPeer:peerID];
			break;
		case GKPeerStateConnecting:
			break;
		default:
			break;
	}
	self.availablePeersArray = [session peersWithConnectionState:GKPeerStateConnected];
	[self reloadData];
}

//Duplicate from GameKitBagmanNamingController
-(void)dropPeer:(NSString*)peerID {
	[self.gameSession disconnectPeerFromAllPeers:peerID];
	if (peerID != nil && [gameState.playerInfoList objectForKey:peerID]) {
		[gameState.playerInfoList removeObjectForKey:peerID];
	}
}

-(void)reloadData {
	AletterationGameKitPlayerView *view = (AletterationGameKitPlayerView*)self.view;
	[view.waitingForPlayersView.playerTableView reloadData];
}

-(void)optionsDialogDidClose:(NSNumber*)flags {
	[super optionsDialogDidClose:flags];
	switch ([flags intValue]) {
		case 1:
			[self broadcastPlayerInfo:[self getPlayerNameInfo]];
			break;
		case 2:
			[self broadcastPlayerInfo:[self getPlayerPortraitInfo]];
			break;
		case 3:
			[self broadcastPlayerInfo:gameState.localPlayerInfo];
			break;
		default:
			break;
	}
}

-(void)receivedNetworkPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	for (NSString *key in [message allKeys]) {
		if ([key isEqualToString:NET_CMD_PLAYER_INFO]) {
			[self receivedPlayerInfoPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_ROW_INDEX]) {
			[self receivedUsedRowPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_ADD_WORD]) {
			[self receivedAddWordPacket:[message objectForKey:key] fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_GAME_OVER]) {
			[self receivedGameOverPacket:message fromPeer:peerID];
		}
	}
	[self reloadData];
}

-(BOOL)removeWordFromLine:(int)lineIndex Count:(int)wordCount {
	if (wordCount >= 4) {
		NSString *word = [gameState getStringForLine:lineIndex wordLength:wordCount];
		BOOL didRemoveWord = [super removeWordFromLine:lineIndex Count:wordCount];
		if (didRemoveWord) {
			[self broadcastAddWordFromRow:lineIndex wordLength:wordCount forPlayer:self.gameSession.peerID word:word];
		}
		return didRemoveWord;
	}
	return NO;
}

-(void)addAutomatedWord:(AnimatedWord*)aWord LineIndex:(int)lineIndex {
	[super addAutomatedWord:aWord LineIndex:lineIndex];

	NSString *word = aWord.word;
	[self broadcastAddWordFromRow:lineIndex wordLength:word.length forPlayer:self.gameSession.peerID word:word];
}

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString*)peerID {
	AletterationPlayerInfo *playerInfo = [message objectForKey:NET_CMD_PLAYER_INFO];
	[gameState updatePlayerInfo:playerInfo];
	[self broadcastPlayerInfo:playerInfo];
	[self updateScoreDisplaysForPlayerInfo:[gameState.playerInfoList objectForKey:playerInfo.ip]];
}

-(void)receivedUsedRowPacket:(NSDictionary*)message fromPeer:(NSString*)peerID {
	NSNumber *index = [message objectForKey:NET_CMD_ROW_INDEX];
	if (index != nil) {
		NSNumber *tindex = [message objectForKey:NET_CMD_TURN];
		int lineIndex = [index intValue];
		int turnIndex = [tindex intValue];
		AletterationPlayerInfo *playerInfo = [gameState.playerInfoList objectForKey:peerID];
		[gameState setCharAtLine:lineIndex toPlayer:playerInfo];
		[self broadcastRowIndex:lineIndex andTurn:turnIndex forPlayer:peerID];
	}
}
-(void)receivedAddWordPacket:(NSDictionary*)message fromPeer:(NSString*)peerID {
	NSNumber *row = [message objectForKey:NET_CMD_ROW_INDEX];
	NSNumber *wordLength = [message objectForKey:NET_CMD_WORD_LENGTH];
	NSString *word = [message objectForKey:NET_CMD_WORD];
	
	[self broadcastAddWordFromRow:[row intValue] wordLength:[wordLength intValue] forPlayer:peerID word:word];
	[gameState completeWordForPlayerIP:peerID lineIndex:[row intValue] wordLength:[wordLength intValue]];
	[self updateScoreDisplaysForPlayerInfo:[gameState.playerInfoList objectForKey:peerID]];
}

-(void)receivedGameOverPacket:(NSDictionary*)message fromPeer:(NSString*)peerID {
	[self broadcastGameOverForPlayer:peerID];
	[gameState setGameOverForPlayerIP:peerID];
}

-(void)broadcastStartGameMessage {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:@"", NET_CMD_START_GAME, nil];
	[self broadcastMessage:message];
}

-(void)broadcastLetterIndex:(int)letterIndex {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:letterIndex], NET_CMD_LETTER_INDEX, nil];
	[self broadcastMessage:message];
}

-(void)broadcastRowIndex:(int)row andTurn:(int)turn forPlayer:(NSString*)peerID {
	NSDictionary *playerRowDic = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX, 
								  [NSNumber numberWithInt:turn], NET_CMD_TURN, 
								  peerID, NET_CMD_PLAYER_IP, 
								  nil];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerRowDic, NET_CMD_PLAYER_ROW, nil];
	[self broadcastMessage:message excludingPeer:peerID];
}

-(void)broadcastGameOverForPlayer:(NSString*)peerID {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:peerID, NET_CMD_GAME_OVER, nil];
	[self broadcastMessage:message excludingPeer:peerID];
}

-(void)broadcastAddWordFromRow:(int)row wordLength:(int)wordLength forPlayer:(NSString*)peerID word:(NSString*)word {
	NSDictionary *playerWordDic = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX, 
								   [NSNumber numberWithInt:wordLength], NET_CMD_WORD_LENGTH, 
								   word, NET_CMD_WORD, 
								   peerID, NET_CMD_PLAYER_IP, 
								   nil];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:playerWordDic, NET_CMD_ADD_WORD, nil];
	[self broadcastMessage:message excludingPeer:peerID];
}

#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [gameState.playerInfoList count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UICellWaitingForPlayer";
	
    UIWaitingPlayerTableViewCell *cell = (UIWaitingPlayerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (UIWaitingPlayerTableViewCell*)[nib objectAtIndex:0];
    }
	AletterationPlayerInfo *playerInfo = [gameState.playerInfoList.allValues objectAtIndex:indexPath.row];
	if (playerInfo != nil) {
		cell.portraitImageView.image = playerInfo.portrait;
		cell.nameLabel.text = playerInfo.name;
		if ([gameState isPlayerDoneNextTurn:playerInfo] || playerInfo.gameOver) {
			cell.isWaiting = NO;
		} else {
			cell.isWaiting = YES;
		}
	}
    return cell;
}

-(void)dealloc {
	[super dealloc];
}

@end
