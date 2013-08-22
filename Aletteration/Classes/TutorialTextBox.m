//
//  TutorialTextBox.m
//  Aletteration
//
//  Created by David Nesbitt on 12-06-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TutorialTextBox.h"

@implementation TutorialTextBox

@synthesize text;
@synthesize autoLetterList;
@synthesize frame;
@synthesize autoNextLastLetter;
@synthesize actionString;

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.text forKey: @"text"];
	[aCoder encodeObject:self.autoLetterList forKey: @"autoLetterList"];
	[aCoder encodeCGRect:self.frame forKey:@"frame"];
	[aCoder encodeBool:self.autoNextLastLetter forKey:@"autoNextLastLetter"];
	[aCoder encodeObject:self.actionString forKey: @"actionString"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super init])) {
		if ([aDecoder containsValueForKey:@"text"]) {
			self.text = [aDecoder decodeObjectForKey:@"text"];
		}
		if ([aDecoder containsValueForKey:@"autoLetterList"]) {
			self.autoLetterList = [aDecoder decodeObjectForKey:@"autoLetterList"];
		}
		if ([aDecoder containsValueForKey:@"frame"]) {
			self.frame = [aDecoder decodeCGRectForKey:@"frame"];
		}
		if ([aDecoder containsValueForKey:@"autoNextLastLetter"]) {
			self.autoNextLastLetter = [aDecoder decodeBoolForKey:@"autoNextLastLetter"];
		}
		if ([aDecoder containsValueForKey:@"actionString"]) {
			self.actionString = [aDecoder decodeObjectForKey:@"actionString"];
		}
	}
	return self;
}

+(TutorialTextBox*)textBoxWithText:(NSString*)t AutoLetterList:(NSArray*)all andFrame:(CGRect)f {
	TutorialTextBox *box = [[[TutorialTextBox alloc] initWithText:t AutoLetterList:all andFrame:f] autorelease];
	return box;
}

-(id)initWithText:(NSString*)t AutoLetterList:(NSArray*)all andFrame:(CGRect)f {
	if ((self = [super init])) {
  		self.text = t;
        self.autoLetterList = [NSMutableArray arrayWithArray:all];
		self.frame = f;
		self.autoNextLastLetter = NO;
		self.actionString = kTutorialActionNone;
	}
	return self;
}

-(void)dealloc {
	self.text = nil;
	self.autoLetterList = nil;
	[super dealloc];
}

@end

@implementation TutorialAutoLetter

@synthesize letter;
@synthesize lineIndex;
@synthesize autoDblTapLineIndex;

-(void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInt32:self.letter forKey:@"letter"];
	[aCoder encodeInt32:self.lineIndex forKey:@"lineIndex"];
	[aCoder encodeInt32:self.autoDblTapLineIndex forKey:@"autoDblTapLineIndex"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	char a;
	int li, atli;
	if ([aDecoder containsValueForKey:@"letter"]) {
		a = (char)[aDecoder decodeInt32ForKey:@"letter"];
	} else {
		a = '~';
	}
	if ([aDecoder containsValueForKey:@"lineIndex"]) {
		li = [aDecoder decodeInt32ForKey:@"lineIndex"];
	} else {
		li = -1;
	}
	if ([aDecoder containsValueForKey:@"autoDblTapLineIndex"]) {
		atli = [aDecoder decodeInt32ForKey:@"autoDblTapLineIndex"];
	} else {
		atli = -1;
	}
	if((self = [self initLetter:a LineIndex:li AutoDblTapLineIndex:atli])) {
	}
	return self;
}

+(TutorialAutoLetter*)autoLetter:(char)l LineIndex:(int)li AutoDblTapLineIndex:(int)atli {
	TutorialAutoLetter *autoLetter = [[[TutorialAutoLetter alloc] initLetter:l LineIndex:li AutoDblTapLineIndex:atli] autorelease];
	return autoLetter;
}

-(id)initLetter:(char)l LineIndex:(int)li AutoDblTapLineIndex:(int)atli {
	if ((self = [super init])) {
		self.letter = l;
		self.lineIndex = li;
		self.autoDblTapLineIndex = atli;
	}
	return self;
}

@end
