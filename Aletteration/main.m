//
//  main.m
//  Aletteration
//
//  Created by David Nesbitt on 4/19/11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
	int retVal = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		retVal = UIApplicationMain(argc, argv, nil, nil);
	}
	@catch (NSException *exception) {
		NSArray *backtrace = [exception callStackSymbols];
		NSString *message = [NSString stringWithFormat:@"Backtrace:\n%@", backtrace];
		NSLog(@"%@", message);
	}
	@finally {
		[pool release];
		return retVal;
	}
}
