//
//  AletterationGKSessionGameController.h
//  Aletteration
//
//  Created by David Nesbitt on 12-06-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AletterationSinglePlayerGameController.h"

@interface AletterationGKSessionGameController : AletterationSinglePlayerGameController {
	GKSessionMode sessionMode;
	BOOL sessionAvailable;
}

@property (nonatomic, retain) GKSession *gkSession;
@property (nonatomic, copy) NSString *sessionID;

@end
