//
//  AletterationGKSessionGameController.m
//  Aletteration
//
//  Created by David Nesbitt on 12-06-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AletterationGKSessionGameController.h"
#import "AletterationGKSessionConstants.h"
#import "AletterationGameState.h"

@interface AletterationGKSessionGameController ()

@end

@implementation AletterationGKSessionGameController

@synthesize gkSession;
@synthesize sessionID;

#pragma mark - GKSession setup and teardown

-(void)setupSession {
	NSLog(@"setupSession");
   self.gkSession = [[GKSession alloc] initWithSessionID:self.sessionID displayName:gameState.localPlayerInfo.name sessionMode:sessionMode];
	gkSession.delegate = self; 
	[gkSession setDataReceiveHandler:self withContext:NULL];
   gkSession.disconnectTimeout = 5;
   gkSession.available = sessionAvailable;
	self.sessionID = self.gkSession.sessionID;
}

-(void)teardownSession {
	NSLog(@"teardownSession");
   gkSession.available = NO;
   gkSession.delegate = nil;
	[gkSession setDataReceiveHandler:nil withContext:NULL];
   [gkSession disconnectFromAllPeers];
	self.gkSession = nil;
}

#pragma mark - View lifecycle

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.gkSession = nil;
		sessionAvailable = NO;
		self.sessionID = ALETTERATION_GK_SESSION_ID;
	}
	return self;
}

-(void)viewDidLoad {
   [super viewDidLoad];
   
   NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

   // Register for notifications when the application leaves the background state
   // on its way to becoming the active application.
   [defaultCenter addObserver:self 
                     selector:@selector(setupSession) 
                         name:UIApplicationWillEnterForegroundNotification
                       object:nil];

   // Register for notifications when when the application enters the background.
   [defaultCenter addObserver:self 
                     selector:@selector(teardownSession) 
                         name:UIApplicationDidEnterBackgroundNotification 
                       object:nil];
}

-(void)viewDidUnload {
   // Unregister for notifications when the view is unloaded.
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
	 [self teardownSession];
	 
   [super viewDidUnload];
}

-(void)setupView {
	NSString *type = (NSString*)self.loadParams;
	if ([type compare:ALETTERATION_GK_SERVER] == NSOrderedSame) {
		sessionMode = GKSessionModeServer;
		sessionAvailable = YES;
	} else if ([type compare:ALETTERATION_GK_CLIENT] == NSOrderedSame) {
		sessionMode = GKSessionModeClient;
		sessionAvailable = YES;
	}
	NSLog(@"%@ %@", self.loadParams, (sessionAvailable?@"YES":@"NO"));
   [self setupSession];
}


#pragma mark - GKSessionDelegate protocol methods

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {	
	switch (state) {
		case GKPeerStateAvailable:
			NSLog(@"didChangeState: peer %@ available (%@)", [session displayNameForPeer:peerID], peerID);

//       [NSThread sleepForTimeInterval:0.5];

//			[session connectToPeer:peerID withTimeout:5];
			break;
			
		case GKPeerStateUnavailable:
			NSLog(@"didChangeState: peer %@ unavailable (%@)", [session displayNameForPeer:peerID], peerID);
			break;
			
		case GKPeerStateConnected:
			NSLog(@"didChangeState: peer %@ connected (%@)", [session displayNameForPeer:peerID], peerID);
			break;
			
		case GKPeerStateDisconnected:
			NSLog(@"didChangeState: peer %@ disconnected (%@)", [session displayNameForPeer:peerID], peerID);
			break;
			
		case GKPeerStateConnecting:
			NSLog(@"didChangeState: peer %@ connecting (%@)", [session displayNameForPeer:peerID], peerID);
			break;
	}
	
//	[self.tableView reloadData];
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSLog(@"didReceiveConnectionRequestFromPeer: %@", [session displayNameForPeer:peerID]);

   [session acceptConnectionFromPeer:peerID error:nil];
	
//	[self.tableView reloadData];
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"connectionWithPeerFailed: peer: %@, error: %@", [session displayNameForPeer:peerID], error);
	
//	[self.tableView reloadData];
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: error: %@", error);
	
	[session disconnectFromAllPeers];
	
//	[self.tableView reloadData];
}

#pragma mark - Data Receive Handler

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession: (GKSession *)session context:(void *)context {
}

@end
