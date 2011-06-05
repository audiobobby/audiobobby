//
//  FinalScene.m
//  bobby
//
//  Created by Jonathan Dalrymple on 04/06/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//


#import "FinalScene.h"
#import "GameScene.h"
#import "Button.h"
#import "SHK.h"

@interface FinalScene(private)

-(void) reportScore:(NSNumber*) aScore forCategory:(NSString*) aString;
-(UIViewController*) modalWrapper;

@end

@implementation FinalScene


+(id) scene
{
	CCScene *scene = [CCScene node];
	FinalScene *layer = [FinalScene node];
	[scene addChild: layer];
	return scene;
}


-(id) init
{
	if( (self=[super init])) 
	{	

		//Get the window size
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		//Set the background
		CCSprite *back = [CCSprite spriteWithFile:PNG(@"MenuEnd")];
		
		back.anchorPoint = ccp(0, 0);
		
		[self addChild:back];
		
		//The score label
		CCLabelTTF	*scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",122]
													fontName:@"8bitWonder32"
													fontSize:60.0f
								   ];
		
		[scoreLabel setColor:ccc3(255, 196, 67)];
		
		[scoreLabel setPosition:ccp(winSize.width*0.65f, winSize.height * 0.64f)];
		
		[self addChild:scoreLabel];
		
		//The buttons
		Button *leaderBoardBtn = [Button buttonWithImage:PNG(@"btnLeaderboard") 
												 onImage:PNG(@"btnLeaderboardHit") 
											  atPosition:ccp(winSize.width*0.25f, winSize.height * 0.1f) 
												  target:self 
												selector:@selector(onLeaderboard)
						   ];
		
		[self addChild:leaderBoardBtn];
		
		Button *shareBtn = [Button buttonWithImage:PNG(@"btnShare") 
										   onImage:PNG(@"btnShareHit") 
										atPosition:ccp(winSize.width*0.75f, winSize.height * 0.1f) 
											target:self 
										  selector:@selector(onShare)
						  ];
		
		[self addChild:shareBtn];
		
		Button *newGameBtn = [Button buttonWithImage:PNG(@"btnEndNewSong") 
											 onImage:PNG(@"btnEndNewSongHit") 
										  atPosition:ccp(winSize.width*0.5f, winSize.height * 0.38f) 
											  target:self 
											selector:@selector(onRestart)
					];
		
		[self addChild:newGameBtn];
		
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

//Attempt to send the score when the transition is finished
-(void) onEnterTransitionDidFinish{
		
	if( [[GKLocalPlayer localPlayer] isAuthenticated] ){
		//Attempt to send game kit score
		[self reportScore:[NSNumber numberWithInt:33] 
			  forCategory:@""
		 ];		
	}

}

#pragma mark - Game Kit
//Report the score to game kit
-(void) reportScore:(NSNumber*) aScore forCategory:(NSString*) aString{
	
	GKScore	*score = [[[GKScore alloc] initWithCategory:aString] autorelease];
	
	[score setValue:[aScore integerValue]];
	
	[score reportScoreWithCompletionHandler:^(NSError *error){
		
		NSLog(@"Score reported %@",error);
	}];
	
}

#pragma mark - GKLeaderboardViewControllerDelegate
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	
	NSLog(@"LeaderboardDidPressDismiss");
	
}

#pragma mark - Event handlers

-(void) onLeaderboard{
	
	UIViewController			*controller;
	__block GKLeaderboardViewController	*leaderboardController;
	
	
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
		
		if( [[GKLocalPlayer localPlayer] isAuthenticated] ){
			
			leaderboardController = [[GKLeaderboardViewController alloc] init];
			
			[leaderboardController setLeaderboardDelegate:self];
		
			[[self modalWrapper] presentModalViewController:leaderboardController
										  animated:YES
			 ];
			
			[leaderboardController release];
		}		
		else{
			NSLog(@"GK authentication error %@",error);
		}
		
	}];

}

-(void) onShare{
	
	SHKItem			*item;
	SHKActionSheet	*sheet;
	
	item = [SHKItem text:NSLocalizedString(@"I achieved %f on Audiobobby", 1)];
	
	sheet = [SHKActionSheet actionSheetForItem:item];
	
	[sheet showInView:[[CCDirector sharedDirector] openGLView]];
	
}

-(void) onRestart{
	
	[[CCDirector sharedDirector] replaceScene:[GameScene scene]];
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
