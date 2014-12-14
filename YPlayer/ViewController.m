//
//  ViewController.m
//  YPlayer
//
//  Created by Roman Kříž on 14.12.14.
//  Copyright (c) 2014 Roman Kříž. All rights reserved.
//


#import "ViewController.h"
#import "PlayerView.h"



@interface ViewController ()

@property (weak) IBOutlet PlayerView *someView;

@end



@implementation ViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.someView.wantsLayer = YES;
	self.someView.layer.backgroundColor = [NSColor grayColor].CGColor;
	[self.someView setStreamURL:[NSURL URLWithString:@"https://archive.org/download/Pbtestfilemp4videotestmp4/video_test.mp4"]];

	NSLog(@"viewDidLoad");
}

@end
