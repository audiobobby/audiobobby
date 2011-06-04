//
//  MusicPlayer.m
//  Balloons
//
//  Created by Mehayhe on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// No mercy, love futuristic, street patrol 2

#import "MusicPlayer.h"
#import "SynthesizeSingleton.h"
#import "SimpleAudioEngine.h"


@implementation MusicPlayer

SYNTHESIZE_SINGLETON_FOR_CLASS(MusicPlayer);

int songSeq[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
int lastSongIndex = -1;

- (id) init
{
	if((self = [super init]))
	{
		if([Properties sharedProperties].songList != nil)
		{
			totalSongs = [[Properties sharedProperties].songList count];
			
			int loop = arc4random() % 9;
			for(int j = 0; j < loop+1; j++)
			{
				for(int i = 0; i < totalSongs-1; i++)
				{
					int r = arc4random() % 10;
					//TRACE(@"ran:%d", r);
					if(r >= 5) {
						int t = songSeq[i+1];
						songSeq[i+1] = songSeq[i];
						songSeq[i] = t;
					}
				}
			}
			
#if DEBUG_MODE
			for(int i = 0; i < totalSongs; i++)
			{
				TRACE(@"song: %d", songSeq[i]);
			}
#endif
			
		}

		selectedSong = [[NSMutableString alloc] init];
	}
	return self;
}
		 
- (int) getRandomSongIndex
{
	int num;
	int counter = 0;
	do {
		num = rand() % [[Properties sharedProperties].songList count];
		counter++;
	} while(lastSongIndex == num || counter > 15);
	lastSongIndex = num;
	return num;
}

- (void) playNextSong
{
#if !SIMPLE_PLAYER
	if([Properties sharedProperties].musicVolume <= 0.0) return;
	NSString *song = [[Properties sharedProperties].songList objectAtIndex:songSeq[currentIndex]];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:song loop:NO];
	[SimpleAudioEngine sharedEngine].backgroundMusicVolume = [Properties sharedProperties].musicVolume;
	TRACE(@"play song: %@ vol:%f, %d, %d", song, [Properties sharedProperties].musicVolume, currentIndex, songSeq[currentIndex]);
	currentIndex++;
	if(currentIndex >= totalSongs) currentIndex = 0;
#endif
}

- (void) playIfNot
{
#if !SIMPLE_PLAYER	
	if([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] == NO)
	{
		[self playNextSong];
	}
#endif
}

- (void) playNext
{
	if([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] == YES)
	{
		if(timer != nil) [timer invalidate];
		timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
																						 target: self
																					 selector: @selector(handleTimer:)
																					 userInfo: nil
																						repeats: YES
						 ];		
		mode = MusicPlayerModePlayNextRandom;
	}
	else 
	{
		[self playNextSong];
	}
}

- (void) selectSong:(NSString *)song
{
#if SIMPLE_PLAYER
	[selectedSong setString:song];	
#else
	[selectedSong setString:[NSString stringWithFormat:@"%@.mp3", song]];	
#endif
	BOOL playing = (SIMPLE_PLAYER) ? player.playing : [[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying];
	if(playing)
	{
		if(timer != nil) [timer invalidate];
		timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
																						 target: self
																					 selector: @selector(handleTimer:)
																					 userInfo: nil
																						repeats: YES
						 ];		
		mode = MusicPlayerModePlayNextSelected;
	}
	else 
	{
		[self playSong];
	}
}

- (void) preloadSong:(NSString *)song
{
	[selectedSong setString:song];	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:selectedSong ofType:@"mp3"];
	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath:filePath] autorelease];
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: nil];
	player.volume = 0;
	[player prepareToPlay];	
}

- (void) playSong
{
	//return;
	if([Properties sharedProperties].music == NO) return;
	if([Properties sharedProperties].musicVolume <= 0.0) return;
#if SIMPLE_PLAYER
	if(player != nil) [player release];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:selectedSong ofType:@"mp3"];
	NSURL *fileURL = [[[NSURL alloc] initFileURLWithPath:filePath] autorelease];
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: nil];
	[player prepareToPlay];
	[player setDelegate:self];
	[player setVolume:[Properties sharedProperties].musicVolume];
	player.numberOfLoops = -1;
	[player play];
	TRACE(@"play song: %@ vol:%f", selectedSong, [Properties sharedProperties].musicVolume);
#else
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:selectedSong loop:YES];
	[SimpleAudioEngine sharedEngine].backgroundMusicVolume = [Properties sharedProperties].musicVolume;
	TRACE(@"play song: %@ vol:%f", selectedSong, [Properties sharedProperties].musicVolume);
#endif
}

- (void) handleTimer:(NSNotification *)notif
{
#if SIMPLE_PLAYER
	float vol = player.volume;
	if(vol > 0.0) {
		player.volume -= 0.02;
	} else {
		[player stop];
		[player release];
		player = nil;
		[timer invalidate];
		timer = nil;
		if(mode == MusicPlayerModePlayNextRandom) [self playNextSong];
		else if(mode == MusicPlayerModePlayNextSelected) [self playSong];
	}
#else
	float vol = [SimpleAudioEngine sharedEngine].backgroundMusicVolume;
	if(vol > 0.0) {
		[SimpleAudioEngine sharedEngine].backgroundMusicVolume -= 0.02;
	} else {
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[timer invalidate];
		timer = nil;
		if(mode == MusicPlayerModePlayNextRandom) [self playNextSong];
		else if(mode == MusicPlayerModePlayNextSelected) [self playSong];
	}
#endif
}

- (void) stop
{		
	mode = MusicPlayerModeStop;
	if(timer != nil) [timer invalidate];
	BOOL playing = (SIMPLE_PLAYER) ? player.playing : [[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying];
	if(playing)
	{
		timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
																					 target: self
																				 selector: @selector(handleTimer:)
																				 userInfo: nil
																					repeats: YES
					 ];
	}
}

- (void) pause
{
	if([Properties sharedProperties].music == YES)
	{
#if SIMPLE_PLAYER
		if(player != nil) [player pause];
#else
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
#endif
	}
}

- (void) resume
{
	if([Properties sharedProperties].music == YES)
	{
#if SIMPLE_PLAYER
		if(player != nil) [player play];
#else
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
#endif
	}
}

- (void) rewind
{
#if SIMPLE_PLAYER
	TRACE(@"rewind");
	if(player != nil) {
		if(player.playing == YES) {
			player.currentTime = 0;	
		} else {
			[player play];
		}
	}
#else
	//[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
#endif
}

- (void) setVolume:(float)val
{
#if SIMPLE_PLAYER
	if(player != nil) player.volume = val;
#else
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:val];
#endif
}

- (void) dealloc
{
	[selectedSong release];
	[super dealloc];
}

////////////


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)_player successfully:(BOOL)completed 
{
	TRACE(@"audioplayer completed:%d", completed);
	if(player != nil) [player playAtTime:0];
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	TRACE(@"audioPlayerBeginInterruption");
	
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	TRACE(@"audioPlayerEndInterruption");
}	

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	TRACE(@"audioPlayerDecodeErrorDidOccur");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AudioError" object:nil];
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
	TRACE(@"audioPlayerEndInterruption with flags");
}

////////////////

@end
