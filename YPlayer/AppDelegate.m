//
//  AppDelegate.m
//  YPlayer
//
//  Created by Roman Kříž on 14.12.14.
//  Copyright (c) 2014 Roman Kříž. All rights reserved.
//


#import "AppDelegate.h"
#import "SPMediaKeyTap.h"



@interface AppDelegate ()

@property (nonatomic, strong) SPMediaKeyTap * keyTap;

@end



@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if ( [SPMediaKeyTap usesGlobalMediaKeyTap] )
	{
		[self.keyTap startWatchingMediaKeys];
	}
	else
	{
		NSLog(@"Media key monitoring disabled");
	}
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}


#pragma mark

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);

	if ( keyIsPressed )
	{
		switch ( keyCode )
		{
			case NX_KEYTYPE_PLAY:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"KeyPlayPauseDidClick" object:self];
				break;

			default:
				break;
		}
	}
}

@end
