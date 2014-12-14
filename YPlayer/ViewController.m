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



@interface ViewController ()

@property (weak) IBOutlet NSTextField *inputTextField;
@property (weak) IBOutlet NSButton *goButton;

@property (weak) IBOutlet PlayerView *playerView;

@end



@implementation ViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.playerView.wantsLayer = YES;
	self.playerView.layer.backgroundColor = [NSColor grayColor].CGColor;
}

- (void) viewWillDisappear
{
	[self.playerView stop];
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

@end
