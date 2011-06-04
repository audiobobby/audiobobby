//
//  MusicPlayer.h
//  Balloons
//
//  Created by Mehayhe on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define SIMPLE_PLAYER 0

typedef enum {
	MusicPlayerModePlayNextSelected,
	MusicPlayerModePlayNextRandom,
	MusicPlayerModeStop
} MusicPlayerMode;

@interface MusicPlayer : NSObject <AVAudioPlayerDelegate> {
	int currentIndex;
	NSTimer *timer;
	int mode;
	int totalSongs;
	NSMutableString *selectedSong;
	AVAudioPlayer *player;
}

+ (MusicPlayer *) sharedMusicPlayer;
- (void) playNext;
- (void) playIfNot;
- (void) stop;
- (void) selectSong:(NSString *)song;
- (void) playSong;
- (void) pause;
- (void) resume;
- (void) setVolume:(float)val;
- (void) rewind;
- (void) preloadSong:(NSString *)song;

@end
