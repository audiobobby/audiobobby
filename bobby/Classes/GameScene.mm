//
//  GameScene.m
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "World.h"
#import "Hub.h"
#import "SimpleAudioEngine.h"
//#import "MusicPlayer.h"
//#import "CircularLayer.h"
//#import "Splash.h"
#import "FlurryAPI.h"
#import "Tips.h"
#import "MainScene.h"
#import "FinalScene.h"

@interface GameScene (internal)
- (void) destroy;
- (void) showSplash;
- (void) removeNode:(CCNode *)node;
@end

@implementation GameScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init])) 
	{	
		
		//CGSize size = [[CCDirector sharedDirector] winSize];
		
		if([[Properties sharedProperties] isLowResIPhone])
		{
			CCSprite *back = [CCSprite spriteWithFile:@"background.png"];
			back.anchorPoint = ccp(0, 0);
			[self addChild:back];
		}
		else
		{
			CCTMXTiledMap *back = [CCTMXTiledMap tiledMapWithTMXFile:TMX(@"background")];
			back.anchorPoint = ccp(0, 0);
			[self addChild:back];
		}
		
		//////////////////
		
		world = [World node];
		world.anchorPoint = ccp(0, 0);
		world.position = ccp(0, 0);
		world.delegate = self;
		[self addChild:world z:10];
		
		hub = [Hub node];
		hub.delegate = self;
		hub.worldDelegate = world;
		[self addChild:hub z:12];
		//[hub show];
		[self performSelector:@selector(startGame) withObject:nil afterDelay:0.3];
	}
	return self;
}


- (void) tick:(ccTime)dt
{
	elapsed += dt;
	[hub setScore:score];
}

-(void) update:(ccTime)dt
{
//	for(CircularLayer *layer in backElements) {
//		[layer scroll:-cloudSpeed];
//	}	
}

- (void) setBackgroundSpeed:(float)val
{
	cloudSpeed = val;
}

- (void) showTips
{
	if(tips != nil) return;
	tips = [Tips node];
	tips.delegate = self;
	[self addChild:tips z:20];
}

- (void) startGame
{
	if(started == YES) return;
	TRACE(@"GAME STARTED"); 
#if !DEBUG_MODE
	[FlurryAPI logEvent:@"PLAY"];
#endif
	
	if(tips != nil) {
		[tips hide];
	}
	
	score = 0;
	elapsed = 0;
	lives = MAX_LIVES;
	started = YES;
	//if(level > MAX_LEVELS-1) level = MAX_LEVELS-1;
	
	//[hub setLife:lives];
	[hub reset];
	//[hub show];
	
	
	//[self schedule:@selector(tick:) interval:0.5];	
	
	[world initRun];
}

- (void) pauseGame
{
	TRACE(@"PAUSE GAME"); 
	[Properties sharedProperties].paused = YES;
	[[CCDirector sharedDirector] pause];
	//[[MusicPlayer sharedMusicPlayer] pause];
	[[SimpleAudioEngine sharedEngine] setMute:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowPausePanel" object:nil];	
}
- (void) resumeGame
{
	TRACE(@"RESUME GAME"); 
	[[SimpleAudioEngine sharedEngine] setMute:NO];
	if([Properties sharedProperties].audio == NO) {
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
	}
	[Properties sharedProperties].paused = NO;
	[[CCDirector sharedDirector] resume];
	//[[MusicPlayer sharedMusicPlayer] resume];
}

- (void) endGame
{
	//if(started == NO) return;
	
	TRACE(@"END GAME"); 
	started = NO;
	
	[world endRun];
	
	[self unschedule:@selector(tick:)];
		
	[Properties sharedProperties].lastScore = score;
	if([Properties sharedProperties].highScore < score) {
		[Properties sharedProperties].highScore = score;
		[Properties sharedProperties].newHigh = YES;
	}
	[Properties sharedProperties].totalGames++;
	[Properties sharedProperties].totalScore += score;
	[[Properties sharedProperties] save];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SubmitScore" object:nil];
	
	TRACE(@"total game: %d, %d", [Properties sharedProperties].totalGames, [Properties sharedProperties].counter);
	if([Properties sharedProperties].totalGames >= [Properties sharedProperties].counter)
	{
		[NSTimer scheduledTimerWithTimeInterval: 1.0
																		 target: self
																	 selector: @selector(ratingTimer:)
																	 userInfo: nil
																		repeats: NO
		 ];
	}
	
#if FLURRY
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"level", [NSString stringWithFormat:@"%d", level], nil];
	[FlurryAPI logEvent:@"GAME_COMPLETED" withParameters:dictionary];
#endif
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.5f scene:[FinalScene scene]]];

}

- (void) ratingTimer:(NSTimer *)_timer
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PromptRating" object:nil];
}

- (void) removeNode:(CCNode *)node
{
	[self removeChild:node cleanup:YES];
}

- (void) onTerminating:(NSNotification *)notif
{
	TRACE(@"terminate game");
	[self resumeGame];
	[self endGame];
}

- (void) onEnter
{
	[super onEnter];
	[self scheduleUpdate];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUpgrade) name:@"ShowUpgrade" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeGame) name:@"ResumeGame" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTerminating:) name:@"TerminateApp" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTerminating:) name:@"EndGame" object:nil];
}

- (void) onExit
{
	TRACE(@"exit game");
	[super onExit];
	[self unscheduleAllSelectors];
}

- (void) operationCompleted:(int)operation
{
	switch (operation) {
//		case OperationSplashHidden:
//			TRACE(@"remove splash");
//			[self removeChild:splash cleanup:YES];
//			splash = nil;
//			break;
			
		case OperationHubHidden:
			[self removeChild:hub cleanup:YES];
			hub = nil;
			break;
		
		case OperationRemoveTips:
			[self removeChild:tips cleanup:YES];
			tips = nil;
			break;
	}
}

- (int) hit
{
	CCSprite *flash = [CCSprite spriteWithFile:PNG(@"HurtFlash")];
	flash.anchorPoint = ccp(0, 0);
	[self addChild:flash z:12];
	id fade = [CCFadeOut actionWithDuration:0.5];
	id remove = [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)]; 
	id seq = [CCSequence actions:fade, remove, nil];
	[flash runAction:seq];
	
	lives--;
	if(lives >= 0)
	{
		[hub setLife:lives];
	}
	return MAX_LIVES-lives;
}

- (int) currentLevel
{
	return level;
}

- (int) nextLevel
{
//	if(lives <= 0) return level;
//	if(level < MAX_LEVELS-1) {
//		level++;
//		if(lives < MAX_LIVES) {
//			lives++;
//			[hub setLife:lives];
//		}
//	}
//	else 
//	{
//		return level;
//	}
//
//	[self showMessage:[NSString stringWithFormat:@"Level %d of %d", level+1, MAX_LEVELS] offset:0];
//	
//	if(level > [Properties sharedProperties].level)
//	{
//		[Properties sharedProperties].level = level;
//#if !DEBUG_MODE
//		[[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"level"];
//#endif
	return level;
}


- (void) showInfo:(NSString *)info
{
	if(hub != nil) [hub setInfo:info];
}

- (void) addPoints:(int)points
{
	//TRACE(@"add points: %d", points);
	score += points;
	if(score < 0) score = 0;
}

//////////////////////////

- (void) showMessage:(NSString *)mesg offset:(int)offset
{
	CCLabelBMFont *label = [CCLabelBMFont labelWithString:mesg fntFile:PROPS(@"MessageFont")];
	CGSize size = [[CCDirector sharedDirector] winSize];
	label.anchorPoint = ccp(0, 0);
	label.position = ccp(size.width/20.0, size.height/20.0 + offset);
	label.opacity = 0.0;
	[self addChild:label z:101];

	id action2 = [CCFadeTo actionWithDuration:0.1 opacity:200];
	id action3 = [CCMoveBy actionWithDuration:3 position:ccp(0, 0)];
	//id groupAction1 = [CCEaseOut actionWithAction:[CCSpawn actions:action2, nil] rate:2];
	id action4 = [CCFadeTo actionWithDuration:1 opacity:0];
	//id groupAction2 = [CCEaseInOut actionWithAction:[CCSpawn actions:action4, nil] rate:3];
	id actionCallFuncN = [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)]; 
	id seq = [CCSequence actions:action2, action3, action4, actionCallFuncN, nil];
	[label runAction:seq];
}

//////////////////

- (void) destroy
{
	[self removeChild:hub cleanup:YES];
	[self removeChild:world cleanup:YES];

}

- (void) dealloc
{	
	TRACE(@"dealloc game scene");
	[self destroy];
	//[backElements release];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[[CCDirector sharedDirector] purgeCachedData];
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

@end
