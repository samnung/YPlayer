//
//  ViewController.m
//  YPlayer
//
//  Created by Roman Kříž on 14.12.14.
//  Copyright (c) 2014 Roman Kříž. All rights reserved.
//


#import "ViewController.h"
#import "PlayerView.h"
#import "HCYoutubeParser.h"



@interface ViewController () <PlayerViewDelegate>

@property (weak) IBOutlet NSTextField *inputTextField;
@property (weak) IBOutlet NSButton *goButton;

@property (weak) IBOutlet NSButton *playPauseButton;

@property (weak) IBOutlet PlayerView *playerView;

@end



@implementation ViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.playerView.wantsLayer = YES;
	self.playerView.layer.backgroundColor = [NSColor grayColor].CGColor;
	self.playerView.delegate = self;

	[[NSNotificationCenter defaultCenter] addObserverForName:@"KeyPlayPauseDidClick" object:nil
													   queue:[NSOperationQueue mainQueue]
												  usingBlock:^ (NSNotification * note) {
													  [self playPauseButtonAction:self.playPauseButton];
												  }];
}

- (void) viewWillDisappear
{
	[self.playerView stop];

	[[NSNotificationCenter defaultCenter] removeObserver:nil name:@"KeyPlayPauseDidClick"
												  object:nil];
}


#pragma mark

- (IBAction) goButtonAction:(NSButton *)sender
{
	[HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:self.inputTextField.stringValue]
								completeBlock:^ (NSDictionary * videoDictionary, NSError * error) {
									NSLog(@"error = %@", error);
									NSLog(@"dict = %@", videoDictionary);

									NSURL * streamURL = [NSURL URLWithString:videoDictionary[@"medium"]];
									[self.playerView setStreamURL:streamURL];
								}];
}

- (IBAction) playPauseButtonAction:(NSButton *)sender
{
	if ( PlayerViewStateIsPlaying(self.playerView.state) )
	{
		[self.playerView pause];
	}
	else
	{
		[self.playerView play];
	}
}


- (void) playerView:(PlayerView *)player changedStateToState:(PlayerViewState)to
{
	if ( PlayerViewStateIsPlaying(to) )
	{
		self.playPauseButton.title = @"||";
	}
	else
	{
		self.playPauseButton.title = @">";
	}
}

- (void) playerView:(PlayerView *)player recievedDuration:(NSTimeInterval)duration
{

}

- (void) playerView:(PlayerView *)player currentTimeDidChange:(NSTimeInterval)newTime
{

}

- (void) playerView:(PlayerView *)player didFailedWithPlayingWithError:(NSError *)error
{

}


@end
