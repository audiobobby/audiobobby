//
//  IntroScene.m
//  Unicorn
//
//  Created by Mehayhe on 10/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainScene.h"
#import "GameScene.h"
#import "Button.h"
#import "AppDelegate.h"

@interface MainScene(private)

-(UIViewController*) modalWrapper;

@end

@implementation MainScene


+(id) scene
{
	CCScene *scene = [CCScene node];
	MainScene *layer = [MainScene node];
	[scene addChild: layer];
	return scene;
}


-(id) init
{
	if( (self=[super init])) 
	{	
		CCSprite *back = [CCSprite spriteWithFile:PNG(@"MainScreen")];
		back.anchorPoint = ccp(0, 0);
		[self addChild:back];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		Button *playBtn = [Button buttonWithImage:PNG(@"btnPlay") onImage:PNG(@"btnPlayHit") 
																	 atPosition:ccp(winSize.width*0.5, winSize.height * 0.35) target:self selector:@selector(playGame)];
		[self addChild:playBtn];
		
		Button *lbBtn = [Button buttonWithImage:PNG(@"btnLeaderboard") 
										onImage:PNG(@"btnLeaderboardHit") 
									 atPosition:ccp(winSize.width*0.5, winSize.height * 0.1) 
										 target:self 
									   selector:@selector(onLeaderboard)];
		[self addChild:lbBtn];
	}
	return self;
}

-(UIViewController*) modalWrapper{
	
	if( !modalWrapper_ ){
		
		modalWrapper_ = [[UIViewController alloc] init];
		
		[modalWrapper_ setView:[[CCDirector sharedDirector] openGLView]];
		
		[modalWrapper_ setModalPresentationStyle:UIModalTransitionStyleFlipHorizontal];
		
	}
	
	return modalWrapper_;
}

#pragma mark - GKLeaderboardViewControllerDelegate
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	
	NSLog(@"LeaderboardDidPressDismiss");
	
}

#pragma mark - Actions
-(void) onLeaderboard{
	
	__block GKLeaderboardViewController	*leaderboardController;
	
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
		
		if( [[GKLocalPlayer localPlayer] isAuthenticated] ){
			
			leaderboardController  = [[GKLeaderboardViewController alloc] init];
			
			[leaderboardController setLeaderboardDelegate:self];
			
			[[self modalWrapper] presentModalViewController:leaderboardController
												   animated:YES
			 ];
			
			[leaderboardController release];
			
		}
		
	}];
	
}

- (void) playGame
{	
	[(AppDelegate *)[UIApplication sharedApplication].delegate showMusicPicker];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.5f scene:[GameScene scene]]];
}

- (void) onEnter
{
	[super onEnter];
}

- (void) onExit
{
	[super onExit];
	[self removeAllChildrenWithCleanup:YES];
}

-(void) dealloc{
	
	[modalWrapper_ release];
	modalWrapper_ = nil;
	
	[super dealloc];
}

@end
