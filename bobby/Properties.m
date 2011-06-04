//
//  Settings.m
//  TopMovies
//
//  Created by Mehayhe on 2/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SynthesizeSingleton.h"


@implementation Properties

SYNTHESIZE_SINGLETON_FOR_CLASS(Properties);

@synthesize totalScore, highScore, averageScore, totalGames, username;
@synthesize audio, music, newHigh, percentage, submit, lastScore;
@synthesize scale, prompted, paused, level, ratingPrompted;
@synthesize coordinateDict, gamecenter, tips, counter, ready;
@synthesize songList, effectVolume, musicVolume, totalSessions, resetLevel;

- (void) load
{
	coordinateDict = [[NSPropertyListSerialization
										 propertyListFromData:[[NSFileManager defaultManager] 
																					 contentsAtPath: [[NSBundle mainBundle] 
																														pathForResource:@"Coordinates" 
																														ofType:@"plist"]]
										 mutabilityOption:NSPropertyListImmutable
										 format:nil errorDescription:nil] retain];
	
	//TRACE(@"coor:%@", coordinateDict);
	
	username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	totalSessions = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalSessions"];
	totalScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalScore"];
	highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
	averageScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"averageScore"];
	totalGames = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalGames"];
	
	counter = [[NSUserDefaults standardUserDefaults] integerForKey:@"counter"];
	level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
	
	resetLevel = [[NSUserDefaults standardUserDefaults] boolForKey:@"resetLevel"];
	audio = [[NSUserDefaults standardUserDefaults] boolForKey:@"audio"];
	music = [[NSUserDefaults standardUserDefaults] boolForKey:@"music"];
	submit = [[NSUserDefaults standardUserDefaults] boolForKey:@"submit"];
	prompted = [[NSUserDefaults standardUserDefaults] boolForKey:@"prompted"];
	ratingPrompted = [[NSUserDefaults standardUserDefaults] boolForKey:@"ratingPrompted"];
	tips = [[NSUserDefaults standardUserDefaults] boolForKey:@"tips"];
	
#if DEBUG_MODE
	//tips = YES;
	prompted = NO;
	username = nil;
	
#endif
	
	musicVolume = 0.6;
	effectVolume = 0.9;
	
	//effectVolume = [[NSUserDefaults standardUserDefaults] floatForKey:@"effectVolume"];
	//musicVolume = [[NSUserDefaults standardUserDefaults] floatForKey:@"musicVolume"];
	
	totalSessions++;
	[[NSUserDefaults standardUserDefaults] setInteger:totalSessions forKey:@"totalSessions"];
}


- (void) save
{	
	TRACE(@"save data");
	averageScore = (totalGames > 0) ? round(totalScore/(float)totalGames) : 0;
	
	[[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:@"highScore"];
	[[NSUserDefaults standardUserDefaults] setInteger:averageScore forKey:@"averageScore"];
	[[NSUserDefaults standardUserDefaults] setInteger:totalGames forKey:@"totalGames"];
	[[NSUserDefaults standardUserDefaults] setInteger:totalScore forKey:@"totalScore"];
}	

- (BOOL) isLowRes
{
#if defined(IPAD_APP)
	return NO;
#else
	return (scale > 1) ? NO : YES;
#endif
}

- (BOOL) isHighRes
{
	return (scale > 1) ? YES : NO;
}

- (BOOL) isLowResIPhone
{
	return ([[Properties sharedProperties] isIPad] || [[Properties sharedProperties] isHighRes]) ? NO : YES;
}

- (int) getOffset:(NSString *)key
{
	return [[coordinateDict objectForKey:key] intValue];
}

- (CGPoint) getNewPopupLocation
{
	CGSize winSize = [UIScreen mainScreen].bounds.size;
	if(winSize.height > winSize.width)
	{
		return CGPointMake(winSize.height/2.0, winSize.width/2.0);	
	}
	else 
	{
		return CGPointMake(winSize.width/2.0, winSize.height/2.0);	
	}

}

- (BOOL) isIPad
{
#if defined(IPAD_APP)
	return YES;
#elif defined(LITE_APP)
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
	return NO;
#endif
}

- (NSString *) getPropForKey:(NSString *)key
{
	NSDictionary *dict = [coordinateDict objectForKey:key];
	if([self isIPad])
	{
		return [dict objectForKey:@"ipad"];
	}
	else if([self isLowRes])
	{
		return [dict objectForKey:@"iphone"];
	}
	else 
	{
		return [dict objectForKey:@"iphone-high"];
	}	
}

- (NSString *) formattedScore:(int)score
{
	NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
	[numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *str = [numFormatter stringForObjectValue: [NSNumber numberWithInt:score]];
	[numFormatter release];
	return str;
}

- (NSString *) fontNameForType:(int)type;
{
	NSString *name = @"8bitWonder";
	int size = 32;
	switch (type) {
		case FontTypeScore:
			name = @"8bitWonder";
			size = 32;
			break;
	}
	//if([self isHighRes]) size *= 2.0;
	return [NSString stringWithFormat:@"%@%d.fnt", name, size];
	
}

- (void) dealloc
{
	[username release];
	[coordinateDict release];
	[super dealloc];
}

@end
