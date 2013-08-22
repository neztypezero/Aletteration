//
//  GameKitPlayerNamingController.m
//  Aletteration
//
//  Created by David Nesbitt on 11-11-10.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "GameKitPlayerNamingController.h"
#import "GameKitPlayerNamingView.h"
#import "AletterationGameState.h"
#import "AletterationPreferences.h"
#import "PhotoChoiceController.h"
#import "TakePictureController.h"
#import "AletterationNetCmd.h"


@interface GameKitPlayerNamingController ()

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;
-(void)receivedPlayerListPacket:(NSDictionary*)message fromPeer:(NSString *)peerID;
-(void)receivedPlayerInfo:(AletterationPlayerInfo*)playerInfo;
-(void)receivedStartGamePacket:(NSDictionary*)message fromPeer:(NSString *)peerID;

-(void)dropPeer:(NSString*)peerID;
-(void)disconnectFromServer;
-(void)animatedDisconnectFromServer;

-(void)showPlayerPortraits;

-(void)showDialogWithTitle:(NSString*)title andMessage:(NSString*)message;

@end

@implementation GameKitPlayerNamingController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		tapToHideKeyboad = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
		tapToHideKeyboad.cancelsTouchesInView = NO;
		tapToHideKeyboad.delaysTouchesBegan = NO;
		tapToHideKeyboad.delaysTouchesEnded = NO;
		
		isConnectedToGameServer = NO;
		isShowingServerPortrait = NO;

		[self createSessionWithMode:GKSessionModeClient];
	}
    return self;
}

-(void)connectToPeer:(NSString*)peerID {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	[view.serversTableView setUserInteractionEnabled:NO];
	
	self.serverID = peerID;
	isShowingServerPortrait = NO;
	
	view.connectingBall.alpha = 0.0;
	[view.connectingBall startAnimating];

	view.waitingLabel.text = @"Connecting to server...";
	view.waitingLabel.hidden = NO;
	view.waitingBall.hidden = NO;
	[view.waitingBall startAnimating];

	[UIView animateWithDuration:0.25
		animations:^{
			view.connectingBall.alpha = 1.0;
			view.waitingLabel.alpha = 1.0;
			view.waitingBall.alpha = 1.0;
		}
		completion:^(BOOL completed){
			[self.gameSession connectToPeer:peerID withTimeout:100.0];
		}
	];
}

-(void)disconnectFromServer {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	view.serversLabel.text = @"Games to Join";
	view.serverPortraitImageView.image = nil;
	[self.gameSession disconnectFromAllPeers]; 
	[gameState resetPlayerInfoList];
	[view.serversTableView setUserInteractionEnabled:YES];
	isConnectedToGameServer = NO;
	isShowingServerPortrait = NO;
	[view resetUIElements];
}

-(void)animatedDisconnectFromServer {
	[UIView animateWithDuration:0.25
		animations:^{
			GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
			view.serverScrollView.contentOffset = CGPointMake(0,0);
			for(UIView *picView in [view.playerPortraitsDic allValues]) {
				picView.alpha = 0.0;
			}
			view.connectingBall.alpha = 0.0;
			view.waitingLabel.alpha = 0.0;
			view.waitingBall.alpha = 0.0;
		}
		completion:^(BOOL completed){
			[self disconnectFromServer];
		}
	];
}

-(void)connectionComplete {
	//NSLog(@"Connection successfully completed.");
	
	isConnectedToGameServer = YES;
	
	// send player portrait to server
	AletterationPlayerInfo *playerInfo = gameState.localPlayerInfo;
	if (playerInfo.name != nil && playerInfo.portrait != nil) {
		playerInfo.ip = self.gameSession.peerID;
		[self sendPlayerInfo:playerInfo toPeer:self.serverID];
	}
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
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	if (isConnectedToGameServer == NO) {
		switch (state) {
			case GKPeerStateConnected:
				[self connectionComplete];
				break;
			default:
				break;
		}
	} else {
		switch (state) {
			case GKPeerStateAvailable:
			case GKPeerStateUnavailable:
			case GKPeerStateConnected:
				break;
			case GKPeerStateDisconnected:
				if (isConnectedToGameServer && [self.serverID compare:peerID] == NSOrderedSame) {
					[self animatedDisconnectFromServer];
					[self showDialogWithTitle:@"Error" andMessage:@"Connection to server lost."];
				} else {
					[self dropPeer:peerID];
				}
				break;
			case GKPeerStateConnecting:
			default:
				break;
		}
	}
	self.availablePeersArray = [session peersWithConnectionState:GKPeerStateAvailable];
	[view.serversTableView reloadData];
}

-(void)showDialogWithTitle:(NSString*)title andMessage:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)dropPeer:(NSString*)peerID {
	if (peerID != nil && [gameState.playerInfoList objectForKey:peerID]) {
		[gameState.playerInfoList removeObjectForKey:peerID];

		GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
		[view removePlayerPortrait:peerID];
	}
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"session:session connectionWithPeerFailed:%@ [%d], [%x]", peerID, [error code], [error code]);
	NSLog(@"%@", [error localizedFailureReason]);
	[self animatedDisconnectFromServer];
	[self showDialogWithTitle:@"Error" andMessage:[error localizedFailureReason]];
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError");
	NSLog(@"%@", [error localizedFailureReason]);
	[self animatedDisconnectFromServer];
}

-(void)receivedNetworkPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	for (NSString *key in [message allKeys]) {
		NSLog(@"receivedNetworkPacket:%@", key);
		if ([key isEqualToString:NET_CMD_PLAYER_INFO]) {
			[self receivedPlayerInfoPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_PLAYER_LIST]) {
			[self receivedPlayerListPacket:message fromPeer:peerID];
		} else if ([key isEqualToString:NET_CMD_START_GAME]) {
			[self receivedStartGamePacket:message fromPeer:peerID];
		}
	}
}

-(void)receivedPlayerInfoPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	AletterationPlayerInfo *playerInfo = [message objectForKey:NET_CMD_PLAYER_INFO];
	[self receivedPlayerInfo:playerInfo];
}

-(void)receivedPlayerListPacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	NSArray *playerInfoList = [message objectForKey:NET_CMD_PLAYER_LIST];
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	view.waitingLabel.text = @"Waiting for game to start...";
	[view updatePlayerPortrait:gameState.localPlayerInfo];
	for (AletterationPlayerInfo *playerInfo in playerInfoList) {
		[self receivedPlayerInfo:playerInfo];
	}
	NSDictionary *acceptStartMessage = [NSDictionary dictionaryWithObjectsAndKeys:@"", NET_CMD_ACCEPT_START, nil];
	[self sendMessage:acceptStartMessage toPeer:self.serverID];
}

-(void)receivedPlayerInfo:(AletterationPlayerInfo*)playerInfo {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	[gameState updatePlayerInfo:playerInfo];
	NSLog(@"receivedPlayerInfo:%@, %@", playerInfo.ip, self.serverID);
	if ([playerInfo.ip compare:self.serverID] == NSOrderedSame) {
		NSLog(@"isShowingServerPortrait:%@", isShowingServerPortrait?@"YES":@"NO");
		if (isShowingServerPortrait == NO) {
			view.serverPortraitImageView.image = playerInfo.portrait;
			
			[UIView animateWithDuration:0.25
				animations:^{
					CGPoint point = { view.serverScrollView.bounds.size.width, 0 };
					view.connectingBall.alpha = 0.0;
					view.serverScrollView.contentOffset = point;
				}
				completion:^(BOOL completed){
					isShowingServerPortrait = YES;
					view.serversLabel.text = playerInfo.name;
				}
			];
		} else {
			view.serverPortraitImageView.image = playerInfo.portrait;
			view.serversLabel.text = playerInfo.name;
		}
	}
	[view updatePlayerPortrait:playerInfo];
}

-(void)receivedStartGamePacket:(NSDictionary*)message fromPeer:(NSString *)peerID {
	[UIView animateWithDuration:1.0
		animations:^{
			self.view.alpha = 0.0;
		}
		completion:^(BOOL completed){
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
				self.serverID, @"SERVER_ID", 
				self.gameSession, @"SESSION", 
				nil
			];
			GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
			[view.waitingBall stopAnimating];
			[self pushViewControllerWithNibName:@"AletterationGameKitPlayerController" animated:NO loadParameters:params];
			self.gameSession = nil;
		}
	];
}

-(void)showPlayerPortraits {
	//NSLog(@"showPlayerPortraits");
	
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	view.waitingLabel.text = @"Waiting for game to start...";
	for (AletterationPlayerInfo *playerInfo in gameState.playerInfoList.allValues) {
		[view updatePlayerPortrait:playerInfo];
	}
	view.waitingLabel.alpha = 1.0;
	view.waitingBall.alpha = 1.0;
	view.waitingBall.alpha = 1.0;
	view.waitingLabel.hidden = NO;
	view.waitingBall.hidden = NO;
	view.waitingBall.hidden = NO;
	[view.waitingBall startAnimating];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	
	NSArray *roundedCornerViewArray = [NSArray arrayWithObjects:
		view.playersScrollView,
		view.areaView, 
		view.serverScrollView, 
		view.portraitImageView.superview, 
		nil
	];
	
	view.portraitImageView.superview.clipsToBounds = YES;
	view.portraitImageView.image = gameState.localPlayerInfo.portrait;
	
	CGSize contentSize = view.serverScrollView.bounds.size;
	contentSize.width *= 2.0;
	[view.serverScrollView setContentSize:contentSize];
	
	for (UIView *rView in roundedCornerViewArray) {
		rView.layer.borderColor = [UIColor blackColor].CGColor;
		rView.layer.borderWidth = 2.0;
		rView.layer.cornerRadius = 12;
	}
	view.playerNameField.text = gameState.localPlayerInfo.name;
	
	[view addGestureRecognizer:tapToHideKeyboad];
	
	[view resetUIElements];
	
	//NSLog(@"PlayerNamingController:viewDidLoad");
	//This is to reload the player portrait list after memory low
	if (isConnectedToGameServer) {
		[self showPlayerPortraits];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	if (view.playerNameField.text == nil) {
		[view.playerNameField becomeFirstResponder];
	}
}

-(void)removeAllPlayerPortraits {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	[view removeAllPlayerPortraits];
}

-(void)photoPicked:(UIImage*)photoImage {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	view.portraitImageView.image = photoImage;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:UIImageJPEGRepresentation(photoImage, 1.0) forKey:PREF_PLAYER_PORTRAIT];
	[defaults setInteger:photoImage.imageOrientation forKey:PREF_PLAYER_PORTRAIT_ORIENTATION];
	[defaults synchronize];
	
	gameState.localPlayerInfo.portrait = photoImage;

	[view updatePlayerPortrait:gameState.localPlayerInfo];
	
	if (isConnectedToGameServer) {
		[self sendPlayerInfo:[self getPlayerPortraitInfo] toPeer:self.serverID];
	}
}

#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.availablePeersArray != nil) {
		return [self.availablePeersArray count];
	}
	return 0;
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"ServersCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	}
	NSString *peerID = [self.availablePeersArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [self.gameSession displayNameForPeer:peerID];
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *peerID = [self.availablePeersArray objectAtIndex:indexPath.row];
	[self connectToPeer:peerID];
}
-(void)showPhotoChoiceDialog {
	[PhotoChoiceController showModal:self delegate:self selector:@selector(photoPicked:)];
}

-(void)showTakePictureDialog {
	[TakePictureController showModal:self delegate:self selector:@selector(photoPicked:)];
}

-(IBAction)chooseImage:(id)sender {
	[self showPhotoChoiceDialog];
}

-(IBAction)takePhoto:(id)sender {
	[self showTakePictureDialog];
}

-(IBAction)dismissKeyboard:(id)sender {
	GameKitPlayerNamingView *view = (GameKitPlayerNamingView*)self.view;
	if (view.playerNameField.text.length > 0) {
		if ([view.playerNameField.text compare:gameState.localPlayerInfo.name] != NSOrderedSame) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:view.playerNameField.text forKey:PREF_PLAYER_NAME];
			gameState.localPlayerInfo.name = [NSString stringWithFormat:@"%@", view.playerNameField.text];
			if (isConnectedToGameServer) {
				[self sendPlayerInfo:[self getPlayerNameInfo] toPeer:self.serverID];
			}
		}
		[view.playerNameField resignFirstResponder];
	}
}

-(IBAction)goBack:(UIButton*)button {
	[self invalidateSession];
	[self popViewControllerAnimated:YES];
}

-(IBAction)disconnectFromServer:(id)sender {
	[self animatedDisconnectFromServer];
}

-(void)dealloc {
	//NSLog(@"dealloc:GameKitPlayerNamingController");
	[self invalidateSession];
	self.availablePeersArray = nil;
	self.serverID = nil;
	[tapToHideKeyboad release];
	[super dealloc];
}

@end
