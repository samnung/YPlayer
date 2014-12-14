//
// Created by Roman Kříž on 28.04.14.
// Copyright (c) 2014 Touch Art, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AppKit;


typedef NS_ENUM(NSUInteger, PlayerViewState) {
	PlayerViewStateStopped,
	PlayerViewStateFailed,

	PlayerViewStateInitialBuffering,
	PlayerViewStateBuffering,

	PlayerViewStatePlaying,
	PlayerViewStatePaused
};

static inline BOOL PlayerViewStateIsPlaying(PlayerViewState state)
{
	return state == PlayerViewStatePlaying || state == PlayerViewStateBuffering || state == PlayerViewStateInitialBuffering;
}
static inline BOOL PlayerViewStateIsStopped(PlayerViewState state)
{
	return state == PlayerViewStateStopped || state == PlayerViewStateFailed;
}
static inline BOOL PlayerViewStateIsBuffering(PlayerViewState state)
{
	return state == PlayerViewStateBuffering || state == PlayerViewStateInitialBuffering;
}



@class PlayerView;


@protocol PlayerViewDelegate <NSObject>

- (void) playerView:(PlayerView *)player changedStateToState:(PlayerViewState)to;
- (void) playerView:(PlayerView *)player recievedDuration:(NSTimeInterval)duration;
- (void) playerView:(PlayerView *)player currentTimeDidChange:(NSTimeInterval)newTime;

- (void) playerView:(PlayerView *)player didFailedWithPlayingWithError:(NSError *)error;

@end




const NSTimeInterval PlayerViewDefaultStartTime;


@interface PlayerView : NSView

@property (nonatomic, weak) id <PlayerViewDelegate> delegate;

@property (nonatomic, readonly) PlayerViewState state;

@property (nonatomic) NSTimeInterval currentTime;

@property (nonatomic) NSURL * streamURL;

- (void) setStreamURL:(NSURL *)url startTime:(NSTimeInterval)startTime;

- (void) play;
- (void) pause;
- (void) stop;

@end
