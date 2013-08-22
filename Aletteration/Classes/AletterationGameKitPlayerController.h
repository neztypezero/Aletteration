//
//  AletterationGameKitPlayerController.h
//  Aletteration
//
//  Created by David Nesbitt on 11-11-17.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationSinglePlayerGameController.h"

@interface AletterationGameKitPlayerController : AletterationSinglePlayerGameController<UITableViewDelegate,UITableViewDataSource> {
	int receivedLetterIndex;
	BOOL isGameTerminated;
}

@end
