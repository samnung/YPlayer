//
// Created by Roman Kříž on 28.04.14.
// Copyright (c) 2014 Touch Art, s.r.o. All rights reserved.
//

#import "PlayerView.h"

#import <AVFoundation/AVFoundation.h>
#import <BlocksKit/BlocksKit.h>


static const NSTimeInterval StalledRecoveryTimeInterval = 5.0;

const NSTimeInterval PlayerViewDefaultStartTime = NAN;


#define CaseReturnNSString(caseLabel) \
	case caseLabel: \
		return @ # caseLabel;

static NSString * PlayerViewStateToString(PlayerViewState state)
{
	switch ( state )
	{
		CaseReturnNSString(PlayerViewStateBuffering)
		CaseReturnNSString(PlayerViewStateInitialBuffering)
		CaseReturnNSString(PlayerViewStateFailed)
		CaseReturnNSString(PlayerViewStateStopped)
		CaseReturnNSString(PlayerViewStatePaused)
		CaseReturnNSString(PlayerViewStatePlaying)
	}
}



@interface PlayerView ()

@property (nonatomic) id periodicPlayerBlock;

@property (nonatomic) NSTimer * timer;
@property (nonatomic) NSDate * stalledDate;

@property (nonatomic) BOOL sentDuration;
@property (nonatomic) BOOL justSentStartTime;

@property (nonatomic, strong) AVPlayerItem * currentItem;

@property (nonatomic) NSTimeInterval startTime;

@end


@implementation PlayerView

#pragma mark Init

- (instancetype) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if ( self )
	{
		[self __commonInit];
	}

	return self;
}

- (instancetype) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if ( self )
	{
		[self __commonInit];
	}

	return self;
}


- (void) __commonInit
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
												  target:self
												selector:@selector(__timerDidFire:)
												userInfo:nil
												 repeats:YES];

	self.layer = [AVPlayerLayer layer];
}

- (void) dealloc
{
	[self.timer invalidate];
	[self.player removeTimeObserver:self.periodicPlayerBlock];
	self.player = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Layer

- (AVPlayer *) player
{
	return [(AVPlayerLayer *) self.layer player];
}

- (void) setPlayer:(AVPlayer *)player
{
	[(AVPlayerLayer *) self.layer setPlayer:player];
}

#pragma mark - Public

- (void) play
{
	[self.player play];
	self.state = PlayerViewStatePlaying;
}

- (void) pause
{
	[self.player pause];
	self.state = PlayerViewStatePaused;
}

- (void) stop
{
	[self.player pause];

	[self.player replaceCurrentItemWithPlayerItem:nil];
	self.state = PlayerViewStateStopped;
}

- (void) setCurrentTime:(NSTimeInterval)currentTime
{
	[self.player seekToTime:CMTimeMakeWithSeconds(currentTime, 100)];
}

- (NSTimeInterval) currentTime
{
	return CMTimeGetSeconds(self.player.currentTime);
}


#pragma mark Private

- (void) setState:(PlayerViewState)state
{
	if ( _state == state )
	{
		return;
	}

	if ( PlayerViewStateIsBuffering(_state) && PlayerViewStateIsBuffering(state) )
	{
		return;
	}

	if ( _state == PlayerViewStateStopped && state == PlayerViewStatePaused )
	{
		return;
	}

	if ( (_state == PlayerViewStateStopped && state == PlayerViewStateFailed) ||
		 (_state == PlayerViewStateFailed && state == PlayerViewStateStopped) )
	{
		return;
	}

	_state = state;

	NSLog(@"%@: switched to state %@", self.class, PlayerViewStateToString(state));

	[self.delegate playerView:self changedStateToState:state];
}

- (void) setStreamURL:(NSURL *)streamURL
{
	[self setStreamURL:streamURL startTime:PlayerViewDefaultStartTime];
}

- (void) setStreamURL:(NSURL *)url startTime:(NSTimeInterval)startTime
{
	_streamURL = url;

	if ( !url )
	{
		[self stop];
		return;
	}

	// remove all previous
	[self.player replaceCurrentItemWithPlayerItem:nil];
	self.sentDuration = NO;
	self.stalledDate = nil;
	self.state = PlayerViewStateInitialBuffering;
	self.startTime = startTime;

	// create new item and set to player
	AVPlayerItem * newItem = [AVPlayerItem playerItemWithURL:url];
	[self __handleNewPlayerItem:newItem];

	// start playing
	[self.player play];

	NSLog(@"%@: setting new stream URL: `%@`", self.class, url);
}

- (void) __handleNewPlayerItem:(AVPlayerItem *)item
{
	__weak __typeof(self) _self = self;

	if ( !self.player )
	{
		self.player = [AVPlayer playerWithPlayerItem:item];
		self.periodicPlayerBlock = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.25, 100)
																			 queue:dispatch_get_main_queue()
																		usingBlock:^(CMTime time)
																		{
																			[_self __handlePeriodicTimeChange:CMTimeGetSeconds(time)];
																		}];
	}
	else
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];

		[self.player replaceCurrentItemWithPlayerItem:item];
	}


	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(__playerItemStalled:)
												 name:AVPlayerItemPlaybackStalledNotification
											   object:item];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(__playerItemFinished:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:item];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(__playerItemFailed:)
												 name:AVPlayerItemFailedToPlayToEndTimeNotification
											   object:item];

	__block BOOL sent = NO;
	self.justSentStartTime = NO;

	[item bk_addObserverForKeyPath:@"status" task:^(__typeof(item) target) {

		switch ( target.status )
		{
			case AVPlayerItemStatusReadyToPlay:
				if ( !sent )
				{
					if ( !isnan(_self.startTime) && ABS(CMTimeGetSeconds(target.currentTime) - _self.startTime) > 5 )
					{
						NSLog(@"PlayerView: just sent the correct start time");
						[self.player seekToTime:CMTimeMakeWithSeconds(_self.startTime, 100)];
						self.justSentStartTime = YES;
					}

					sent = YES;
				}
				break;

			case AVPlayerItemStatusFailed:
				[_self __playerItemFailedWithError:target.error];
				break;

			default:
				break;
		}
	}];

	[self.currentItem bk_removeAllBlockObservers];
	self.currentItem = item;
}



#pragma mark Notifying

- (void) __handleDurationChange:(NSTimeInterval)seconds
{
	NSLog(@"%@: player duration changed to %g", self.class, seconds);
	[self.delegate playerView:self currentTimeDidChange:seconds];
}


#pragma mark Timer handling

- (void) __timerDidFire:(NSTimer *)timer
{
	// detection of long loading
	if ( fabs([self.stalledDate timeIntervalSinceNow]) > StalledRecoveryTimeInterval && self.state == PlayerViewStateBuffering )
	{
		self.stalledDate = nil;
		[self play];
	}

	if ( !self.sentDuration && CMTimeGetSeconds(self.player.currentItem.duration) > 0.0 )
	{
		self.sentDuration = YES;

		[self __handleDurationChange:CMTimeGetSeconds(self.player.currentItem.duration)];
	}

	if ( self.state == PlayerViewStatePlaying && self.player.rate == 0.0 )
	{
		self.state = PlayerViewStatePaused;
	}
}

- (void) __handlePeriodicTimeChange:(NSTimeInterval)time
{
	if ( self.player.rate > 0.0 )
	{
		self.state = PlayerViewStatePlaying;

		[self __handleDurationChange:time];

		if ( self.justSentStartTime )
		{
			self.justSentStartTime = NO;
		}
	}
}


#pragma mark Notifications handling

- (void) __playerItemStalled:(NSNotification *)note
{
	NSLog(@"%@: player stalled", self.class);
	self.stalledDate = [NSDate date];

	self.state = PlayerViewStateBuffering;
}

- (void) __playerItemFinished:(NSNotification *)note
{
	NSLog(@"%@: player finished", self.class);

	self.state = PlayerViewStateStopped;
}

- (void) __playerItemFailedWithError:(NSError *)error
{
	NSLog(@"%@: player catch error %@", self.class, error);

	[self.delegate playerView:self didFailedWithPlayingWithError:error];

	self.state = PlayerViewStateFailed;
}

- (void) __playerItemFailed:(NSNotification *)note
{
	NSError * error = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
	[self __playerItemFailedWithError:error];
}

@end
