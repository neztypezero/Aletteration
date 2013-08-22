//
//  AletterationPlayerInfoTableViewDelegate.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-29.
//  Copyright (c) 2011 David Nesbitt. All rights reserved.
//

#import "AletterationPlayerInfoTableViewDelegate.h"
#import "AletterationPlayerInfo.h"
#import <objc/runtime.h>

@implementation AletterationPlayerInfoTableViewDelegate

@synthesize playerInfo;
@synthesize wordsTableView;

-(void)setPlayerInfo:(AletterationPlayerInfo*)pInfo {
	if (playerInfo != nil) {
		[playerInfo release];
	}
	if (pInfo != nil) {
		playerInfo = [pInfo retain];
		
	} else {
		playerInfo = nil;
	}
	[self.wordsTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [NSString stringWithFormat:@"Word List"];
		default:
			return @"";
	}
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *words = self.playerInfo.completedWordList;
	if (words != nil && [words count] > 0) {
		return [words count];
	}
	return 0;
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"UICellCompletedWord";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
	}
	NSArray *words = self.playerInfo.completedWordList;
	if (words != nil && [words count] > 0) {
		cell.textLabel.text = [words objectAtIndex:indexPath.row];
	}
	return cell;
}

-(void)dealloc {
	self.playerInfo = nil;
	self.wordsTableView = nil;
	[super dealloc];
}

@end
