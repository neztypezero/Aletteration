//
//  GameKitBagmanNamingController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "GameKitBagmanNamingController.h"
#import "GameKitBagmanNamingView.h"
#import "AletterationGameState.h"
#import "PhotoChoiceController.h"
#import "TakePictureController.h"
#import "AletterationPreferences.h"
#import "UIWaitingPlayerTableViewCell.h"
#import "AletterationNetCmd.h"

@interface GameKitBagmanNamingController ()

-(void)reloadData;
-(NSMutableArray*)getPlayerList;

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;
-(void)receivedAcceptStartPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;

-(void)dropPeer:(NSString*)peerID;

@end

@implementation GameKitBagmanNamingController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		tapToHideKeyboad = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
		tapToHideKeyboad.cancelsTouchesInView = NO;
		tapToHideKeyboad.delaysTouchesBegan = NO;
		tapToHideKeyboad.delaysTouchesEnded = NO;
		
		[self createSessionWithMode:GKSessionModeServer];
    }
    return self;
}

-(NSString*)stateString:(GKPeerConnectionState)state {
		switch (state) {
			case GKPeerStateAvailable:
				return @"GKPeerStateAvailable";
			case GKPeerStateUnavailable:
				return @"GKPeerStateUnavailable";
			case GKPeerStateConnected:
				return @"GKPeerStateConnected";
			case GKPeerStateDisconnected:
				return @"GKPeerStateDisconnected";
			case GKPeerStateConnecting:
				return @"GKPeerStateConnecting";
			default:
				return @"NoState";
		}
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

-(void)receivedNetworkPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	for (NSString *key in [message allKeys]) {
		if ([key isEqualToString:NET_CMD_PLAYER_INFO]) {
			[self receivedPlayerInfoPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_ACCEPT_START]) {
			[self receivedAcceptStartPacket:message fromPeer:peerID];
		}
	}
	[self reloadData];
}

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	AletterationPlayerInfo *playerInfo = [message objectForKey:NET_CMD_PLAYER_INFO];
	BOOL isNewPlayer = [gameState updatePlayerInfo:playerInfo];
	
	if (isNewPlayer) {
		NSMutableArray *playerList = [self getPlayerList];
		for (int i=0,n=[playerList count];i<n;i++) {
			AletterationPlayerInfo *pInfo = [playerList objectAtIndex:i];
			if ([pInfo.ip compare:peerID] == NSOrderedSame) {
				[playerList removeObjectAtIndex:i];
				break;
			}
		}
		if ([playerList count] > 0) {
			NSDictionary *playerListMessage = [NSDictionary dictionaryWithObjectsAndKeys:playerList, NET_CMD_PLAYER_LIST, nil];
			[self sendMessage:playerListMessage toPeer:peerID];
		}
	}
	[self broadcastPlayerInfo:playerInfo];
}

-(void)receivedAcceptStartPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	AletterationPlayerInfo *playerInfo = [gameState.playerInfoList objectForKey:peerID];
	if (playerInfo != nil) {
		playerInfo.canStart = YES;
	}
}

-(NSMutableArray*)getPlayerList {
	return [NSMutableArray arrayWithArray:[gameState.playerInfoList allValues]];
}

-(void)dropPeer:(NSString*)peerID {
	[self.gameSession disconnectPeerFromAllPeers:peerID];
	if (peerID != nil && [gameState.playerInfoList objectForKey:peerID]) {
		[gameState.playerInfoList removeObjectForKey:peerID];
	}
}

-(IBAction)chooseImage:(id)sender {
	[PhotoChoiceController showModal:self delegate:self selector:@selector(photoPicked:)];
}

-(IBAction)takePhoto:(id)sender {
	[TakePictureController showModal:self delegate:self selector:@selector(photoPicked:)];
}

-(void)photoPicked:(UIImage*)photoImage {
	GameKitBagmanNamingView *view = (GameKitBagmanNamingView*)self.view;
	view.portraitImageView.image = photoImage;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:UIImageJPEGRepresentation(photoImage, 1.0) forKey:PREF_PLAYER_PORTRAIT];
	[defaults setInteger:photoImage.imageOrientation forKey:PREF_PLAYER_PORTRAIT_ORIENTATION];
	[defaults synchronize];
	
	gameState.localPlayerInfo.portrait = photoImage;
	[self broadcastPlayerInfo:[self getPlayerPortraitInfo]];
}

-(void)startGame {
	[UIView animateWithDuration:1.0
			animations:^{
			self.view.alpha = 0.0;
		}
		completion:^(BOOL completed) {
			[self pushViewControllerWithNibName:@"AletterationGameKitBagmanController" animated:NO loadParameters:self.gameSession];
//			self.gameSession = nil;
		}
	];
}

-(void)waitForStartGame {
	for (AletterationPlayerInfo *pInfo in gameState.playerInfoList.allValues) {
		if(gameState.localPlayerInfo != pInfo && pInfo.canStart == NO) {
			[self performSelector:@selector(waitForStartGame) withObject:nil afterDelay:0.1];
			return;
		}
	}
	[self startGame];
}

-(IBAction)dismissKeyboard:(id)sender {
	GameKitBagmanNamingView *view = (GameKitBagmanNamingView*)self.view;
	if (view.playerNameField.isFirstResponder && view.playerNameField.text.length > 0) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:view.playerNameField.text forKey:PREF_PLAYER_NAME];
		gameState.localPlayerInfo.name = [NSString stringWithFormat:@"%@", view.playerNameField.text];
		[view.playerNameField resignFirstResponder];
		[self broadcastPlayerInfo:[self getPlayerNameInfo]];
	}
}

-(IBAction)cancelGame:(id)cancelButton {
	[self invalidateSession];
	[self popViewControllerAnimated:YES];
}

-(IBAction)startGame:(id)startButton {
	GameKitBagmanNamingView *view = (GameKitBagmanNamingView*)self.view;
	view.startGameButton.enabled = NO;
	view.startGameButton.alpha = 0.5;
	self.gameSession.available = NO;
	[self waitForStartGame];
}

-(void)reloadData {
	GameKitBagmanNamingView *view = (GameKitBagmanNamingView*)self.view;
	BOOL loading = NO;
	for (AletterationPlayerInfo *pInfo in gameState.playerInfoList.allValues) {
		if (pInfo.name == nil) {
			loading = YES;
		}
	}
	if (self.availablePeersArray != nil && [self.availablePeersArray count] > 0 && !loading) {
		view.startGameButton.enabled = YES;
		view.startGameButton.alpha = 1.0;
	} else {
		view.startGameButton.enabled = NO;
		view.startGameButton.alpha = 0.5;
	}	
	[view.playersTableView reloadData];
	view.gameInfoLabel.text = [NSString stringWithFormat:@"Players joined: %d", [self.availablePeersArray count]];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	GameKitBagmanNamingView *view = (GameKitBagmanNamingView*)self.view;
	view.playerNameField.text = gameState.localPlayerInfo.name;
	
	NSArray *roundedCornerViewArray = [NSArray arrayWithObjects:
		view.areaView, 
		view.gameInfoView, 
		view.playersTableView.superview, 
		view.portraitImageView.superview, 
		nil
	];
	
	view.portraitImageView.superview.clipsToBounds = YES;
	view.portraitImageView.image = gameState.localPlayerInfo.portrait;
	
	for (UIView *rView in roundedCornerViewArray) {
		rView.layer.borderColor = [UIColor blackColor].CGColor;
		rView.layer.borderWidth = 2.0;
		rView.layer.cornerRadius = 9;
	}
	[self reloadData];
	[view addGestureRecognizer:tapToHideKeyboad];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.availablePeersArray != nil) {
		return [self.availablePeersArray count];
	}
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"UICellWaitingForPlayer";
	
	UIWaitingPlayerTableViewCell *cell = (UIWaitingPlayerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (UIWaitingPlayerTableViewCell*)[nib objectAtIndex:0];
		cell.shouldDisplayCheckmark = NO;
    }
	AletterationPlayerInfo *playerInfo = [gameState.playerInfoList objectForKey:[self.availablePeersArray objectAtIndex:indexPath.row]];
	if (playerInfo.name != nil) {
		cell.portraitImageView.image = playerInfo.portrait;
		cell.nameLabel.text = playerInfo.name;
		cell.isWaiting = NO;
	} else {
		cell.portraitImageView.image = [UIImage imageNamed:@"profile.png"];
		cell.nameLabel.text = @"Joining...";
		cell.isWaiting = YES;
	}
	return cell;
}

-(void)dealloc {
	[tapToHideKeyboad release];
	self.gameSession = nil;
	[super dealloc];
}

@end
