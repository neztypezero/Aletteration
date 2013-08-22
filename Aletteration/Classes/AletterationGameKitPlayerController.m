//
//  AletterationGameKitPlayerController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-17.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameKitPlayerController.h"
#import "AletterationGameKitPlayerView.h"
#import "WaitForPlayersView.h"
#import "AletterationGameState.h"
#import "UIWaitingPlayerTableViewCell.h"
#import "AnimatedWord.h"
#import "AletterationNetCmd.h"

@interface AletterationGameKitPlayerController (private)

-(void)dropPeer:(NSString*)peerID;

-(void)fadeInWaitView;
-(void)fadeOutWaitView;

-(void)waitForNextLetterIndex;
-(void)setLetterIndex;

-(void)waitForGameOverForAllPlayers;

-(void)reloadData;

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString*)peerID;
-(void)receivedLetterIndexPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;
-(void)receivedAddWordPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;
-(void)receivedPlayerRowPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;
-(void)receivedGameOverPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;

-(void)sendUsedRow:(int)row andTurnIndex:(int)turn;
-(void)sendAddWordWithRow:(int)row wordLength:(int)wordLength word:(NSString*)word;
-(void)sendGameOver;

@end

@implementation AletterationGameKitPlayerController

-(void)viewDidLoad {
	if (self.gameSession == nil && self.loadParams != nil) {
		NSDictionary *params = self.loadParams;
		self.serverID = [params objectForKey:@"SERVER_ID"];
		self.gameSession = [params objectForKey:@"SESSION"];
		self.loadParams = nil;
	}
	[super viewDidLoad];
	
	AletterationGameKitPlayerView *view = (AletterationGameKitPlayerView*)self.view;
	[view.waitingForPlayersView loadRoundCornersAndBorders];
	view.waitingForPlayersView.playerTableView.delegate = self;
	view.waitingForPlayersView.playerTableView.dataSource = self;
}


-(void)waitForNextLetterIndex {
	if (receivedLetterIndex == -1 || ![gameState isTurnOverForAllPlayers]) {
		[self performSelector:@selector(waitForNextLetterIndex) withObject:nil afterDelay:0.5];
	} else {
		[self fadeOutWaitView];
	}
}

-(void)waitForNextTurn {
	if ([gameState.letterList count] == 0) {
		[super waitForNextTurn];
	} else {
		if (receivedLetterIndex == -1 || ![gameState isTurnOverForAllPlayers]) {
			[self fadeInWaitView];
		} else {
			[self setLetterIndex];
		}
	}
}

-(void)letterAddedToLineIndex:(int)lineIndex {
	receivedLetterIndex = -1;
	[self sendUsedRow:lineIndex andTurnIndex:gameState.currentTurn];
	[super letterAddedToLineIndex:lineIndex];
}

-(void)doGameOver {
	[self sendGameOver];
	
	isGameTerminated = YES;
//	gameState.remoteConnection.delegate = nil;
//	[gameState.remoteConnection stop];
	
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
						 if (gameState.isGameOver || isGameTerminated) {
							 [self waitForGameOverForAllPlayers];
						 } else {
							 [self waitForNextLetterIndex];
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
						 if (gameState.isGameOver || isGameTerminated) {
							 [super doGameOver];
						 } else {
							 [self setLetterIndex];
						 }
					 }
	 ];
}

-(void)setLetterIndex {
	[gameState setSelectedBlockWithIndex:receivedLetterIndex];
	receivedLetterIndex = -1;
	[super waitForNextTurn];
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
	if ([peerID compare:self.serverID] == NSOrderedSame) {
		if (isGameTerminated == NO) {
			isGameTerminated = YES;
			
			NSString *title = @"Game Over";
			NSString *reason = @"Connection to server has been lost.";
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:reason delegate:self cancelButtonTitle:nil otherButtonTitles:@"Quit Game", nil];
			[alert show];
			[alert release];
		}
	} else {
		if (peerID != nil && [gameState.playerInfoList objectForKey:peerID]) {
			[gameState.playerInfoList removeObjectForKey:peerID];
		}
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
			[self sendPlayerInfo:[self getPlayerNameInfo] toPeer:self.serverID];
			break;
		case 2:
			[self sendPlayerInfo:[self getPlayerPortraitInfo] toPeer:self.serverID];
			break;
		case 3:
			[self sendPlayerInfo:gameState.localPlayerInfo toPeer:self.serverID];
			break;
		default:
			break;
	}
}

-(void)receivedNetworkPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	for (NSString *key in [message allKeys]) {
		if ([key isEqualToString:NET_CMD_PLAYER_INFO]) {
			[self receivedPlayerInfoPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_PLAYER_ROW]) {
			[self receivedPlayerRowPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_ADD_WORD]) {
			[self receivedAddWordPacket:[message objectForKey:key] fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_GAME_OVER]) {
			[self receivedGameOverPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_LETTER_INDEX]) {
			[self receivedLetterIndexPacket:message fromPeer:peerID];
		}
	}
	[self reloadData];
}

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString*)peerID {
	AletterationPlayerInfo *playerInfo = [message objectForKey:NET_CMD_PLAYER_INFO];
	[gameState updatePlayerInfo:playerInfo];
	[self updateScoreDisplaysForPlayerInfo:[gameState.playerInfoList objectForKey:playerInfo.ip]];
}

-(void)receivedLetterIndexPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	NSNumber *index = [message objectForKey:NET_CMD_LETTER_INDEX];
	receivedLetterIndex = [index intValue];
}

-(void)receivedAddWordPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	NSNumber *row = [message objectForKey:NET_CMD_ROW_INDEX];
	NSNumber *wordLength = [message objectForKey:NET_CMD_WORD_LENGTH];
	NSString *ip = [message objectForKey:NET_CMD_PLAYER_IP];
	
	[gameState completeWordForPlayerIP:ip lineIndex:[row intValue] wordLength:[wordLength intValue]];
	[self updateScoreDisplaysForPlayerInfo:[gameState.playerInfoList objectForKey:ip]];
}

-(void)receivedPlayerRowPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
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

-(void)receivedGameOverPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	NSString *ip = [message objectForKey:NET_CMD_GAME_OVER];
	[gameState setGameOverForPlayerIP:ip];
}

-(BOOL)removeWordFromLine:(int)lineIndex Count:(int)wordCount {
	NSString *word = [gameState getStringForLine:lineIndex wordLength:wordCount];
	if (wordCount >= 4) {
		BOOL didRemoveWord = [super removeWordFromLine:lineIndex Count:wordCount];
		if (didRemoveWord) {
			[self sendAddWordWithRow:lineIndex wordLength:wordCount word:word];
		}
		return didRemoveWord;
	}
	return NO;
}

-(void)addAutomatedWord:(AnimatedWord*)aWord LineIndex:(int)lineIndex {
	[super addAutomatedWord:aWord LineIndex:lineIndex];
	
	NSString *word = aWord.word;
	[self sendAddWordWithRow:lineIndex wordLength:word.length word:word];
}

-(void)sendUsedRow:(int)row andTurnIndex:(int)turn {
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX,
							 [NSNumber numberWithInt:turn], NET_CMD_TURN, 
							 nil];
	[self sendMessage:message toPeer:self.serverID];
}

-(void)sendAddWordWithRow:(int)row wordLength:(int)wordLength word:(NSString*)word {
	NSDictionary *addRow = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithInt:row], NET_CMD_ROW_INDEX, 
							[NSNumber numberWithInt:wordLength], NET_CMD_WORD_LENGTH, 
							word, NET_CMD_WORD, 
							 nil];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:addRow, NET_CMD_ADD_WORD, nil];
	[self sendMessage:message toPeer:self.serverID];
}

-(void)sendGameOver {
	NSString *ip = gameState.localPlayerInfo.ip;
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:ip, NET_CMD_GAME_OVER, nil];
	[self sendMessage:message toPeer:self.serverID];
}

-(void)resetGame {
	[UIView animateWithDuration:0.25
		animations:^{
			AletterationGameKitPlayerView *view = (AletterationGameKitPlayerView*)self.view;
			view.waitingForPlayersView.alpha = 0.0;
		}
		completion:^(BOOL completed){
		}
	];
	[super resetGame];
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
		if (gameState.localPlayerInfo.gameOver) {
			cell.isWaiting = !playerInfo.gameOver;
		} else {
			cell.isWaiting = ![gameState isPlayerDoneTurn:playerInfo];
		}
	}
	return cell;
}

@end
