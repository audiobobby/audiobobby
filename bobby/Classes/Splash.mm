//
//  Splash.mm
//  Unicorn
//
//  Created by Mehayhe on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Splash.h"
#import "Button.h"
#import "MusicPlayer.h"
#import "SimpleAudioEngine.h"
#import "FlurryAPI.h"

@implementation Splash

@synthesize delegate;


-(id) init
{
	if( (self=[super init])) 
	{	
		self.isTouchEnabled = YES;
		self.anchorPoint = ccp(0, 0);
		self.position = ccp(-[[CCDirector sharedDirector] winSize].width, 0);
		winSize = [[CCDirector sharedDirector] winSize];
		
		back = [CCSprite spriteWithFile:PNG(@"scroll")];
		back.position = ccp(winSize.width/2.0, winSize.height/1.9);
		back.tag = 1;

		[self addChild:back];	
		
		bottomLine = ([[Properties sharedProperties] isIPad]) ? 0.31 : 0.27;
		
		/*
		CGPoint p1 = ccp(30, 30);
		CGPoint p2 = ccp(90, 90);
		float dist = ccpDistance(p1, p2);
		float r = atan2( p2.y - p1.y , p2.x - p1.x );
		float x = p1.x + cos(r) * dist/2.0;
		float y = p1.y + sin(r) * dist/2.0;
		TRACE(@"====================\ndist:%f x:%f y:%f", dist, x, y);*/
	}
	return self;
}


- (void) onEnter 
{
	[super onEnter];
	TRACE(@"show splash");
	
	id action1 = [CCMoveTo actionWithDuration:0.3f position:ccp(0, 0)];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(showCompleted:)]; 
	id seq = [CCSequence actions:action1, action2, nil];
	//id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowBanner" object:nil];
}


- (void) hide
{
	TRACE(@"hide splash");
	id action1 = [CCMoveTo actionWithDuration: 0.5 position:ccp([[CCDirector sharedDirector] winSize].width, 0)];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(hideCompleted:)]; 
	id seq = [CCSequence actions:[CCEaseIn actionWithAction:action1 rate:2], action2, nil];
	//id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HideBanner" object:nil];
}

- (void) showCompleted:(id)node
{
	
}

- (void) hideCompleted:(id)node
{
	TRACE(@"hide completed");
	[delegate operationCompleted:OperationSplashHidden];
}

- (void) reset
{
	TRACE(@"reset");
	view = SplashViewOther;

	for(CCNode *node in self.children)
	{
		if(node.tag != 1) {
			//TRACE(@"remove node:%@", node);
			[self removeChild:node cleanup:YES];
		}
	}
}

- (void) showTitle
{	
	[self reset];
	view = SplashViewTitle;
	
	title = [CCSprite spriteWithFile:PNG(@"title")];
	title.position = ccp(winSize.width/2.0, round(winSize.height*0.55));
	//title.opacity = 0;
	[self addChild:title];
	
	menuLabel = [CCLabelBMFont labelWithString:@"- Tap to Continue -" fntFile:PROPS(@"CaptionFont")];
	menuLabel.position = ccp(winSize.width/2.0, winSize.height*bottomLine);
	[self addChild:menuLabel];		
}


- (void) showUpgrade
{
	[self reset];
	view = SplashViewOther;
	CCNode *panel = [CCNode node];
	panel.anchorPoint = ccp(0, 0);
	
	CCLabelBMFont *continueLabel = [CCLabelBMFont labelWithString:@"-  Get the Full Version" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:continueLabel target:self selector:@selector(getFullVersion)];
	
	CCLabelBMFont *leaderboardLabel = [CCLabelBMFont labelWithString:@"Show Menu  -" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:leaderboardLabel target:self selector:@selector(showMenu)];
	
	CCLabelBMFont *sepLabel1 = [CCLabelBMFont labelWithString:@"-" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *separator1 = [CCMenuItemLabel itemWithLabel:sepLabel1 target:self selector:@selector(doNothing)];
	
	menu = [CCMenu menuWithItems:item1, separator1, item3, nil];
	[menu setPosition:ccp(winSize.width/2.0, round(winSize.height*bottomLine))];
	[menu alignItemsHorizontallyWithPadding:round(winSize.width/50.0)];
	
	////////
	
	[panel addChild:menu];
	
	CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"The messenger survived the initial attacks." fntFile:PROPS(@"CaptionFont")];
	CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"Next onslaught begins in the full version." fntFile:PROPS(@"CaptionFont")];
	
	float yOff = ([[Properties sharedProperties] isIPad]) ? 0.0 : 0.04;
	label1.position = ccp(round(winSize.width * 0.5), round(winSize.height * (0.71 + yOff)));
	label2.position = ccp(round(winSize.width * 0.5), round(winSize.height * (0.64 + yOff)));
	
	[panel addChild:label1];
	[panel addChild:label2];
	
	NSString *file = ([[Properties sharedProperties] isIPad]) ? @"screenshots-ipad.png" : @"screenshots.png";
	CCSprite *screens = [CCSprite spriteWithFile:file];
	screens.position = ccp(round(winSize.width*0.5), round(winSize.height * 0.475));
	[panel addChild:screens];
	
	[self addChild:panel];
	
}


- (void) showScore:(int)score
{
	[self reset];
	view = SplashViewOther;
	CCNode *panel = [CCNode node];
	panel.anchorPoint = ccp(0, 0);
		
	CCLabelBMFont *continueLabel = [CCLabelBMFont labelWithString:@"-  Play Again" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:continueLabel target:self selector:@selector(doPlay)];
		
	CCLabelBMFont *leaderboardLabel = [CCLabelBMFont labelWithString:@"Show Menu  -" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:leaderboardLabel target:self selector:@selector(showMenu)];
		
	CCLabelBMFont *sepLabel1 = [CCLabelBMFont labelWithString:@"-" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *separator1 = [CCMenuItemLabel itemWithLabel:sepLabel1 target:self selector:@selector(doNothing)];
	//CCLabelBMFont *sepLabel2 = [CCLabelBMFont labelWithString:@"-" fntFile:PROPS(@"CaptionFont")];
	//CCMenuItemLabel *separator2 = [CCMenuItemLabel itemWithLabel:sepLabel2 target:self selector:@selector(doNothing)];
	
	menu = [CCMenu menuWithItems:item1, separator1, item3, nil];
	[menu setPosition:ccp(winSize.width/2.0, round(winSize.height*bottomLine))];
	[menu alignItemsHorizontallyWithPadding:round(winSize.width/50.0)];
	
	////////
	
	[panel addChild:menu];
	
	CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Final Score:" fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"High Score:" fntFile:PROPS(@"MenuFont")];
	
	label1.anchorPoint = ccp(1, 0.5);
	label2.anchorPoint = ccp(1, 0.5);
	
	label1.position = ccp(round(winSize.width * 0.52), round(winSize.height * 0.62));
	label2.position = ccp(round(winSize.width * 0.52), round(winSize.height * 0.50));
	
	[panel addChild:label1];
	[panel addChild:label2];
	
	//////
	
	CCLabelBMFont *label1b = [CCLabelBMFont labelWithString:[[Properties sharedProperties] formattedScore:score] fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label2b = [CCLabelBMFont labelWithString:[[Properties sharedProperties] formattedScore:[Properties sharedProperties].highScore] fntFile:PROPS(@"MenuFont")];
	
	label1b.anchorPoint = ccp(0, 0.5);
	label2b.anchorPoint = ccp(0, 0.5);
	
	label1b.position = ccp(round(winSize.width * 0.55), round(winSize.height * 0.62));
	label2b.position = ccp(round(winSize.width * 0.55), round(winSize.height * 0.50));
	
	[panel addChild:label1b];
	[panel addChild:label2b];
		
	[self addChild:panel];
	
}
	
- (void) showMenu
{
	TRACE(@"show menu");
	[self reset];
	view = SplashViewMenu;

	CCNode *panel = [CCNode node];
	panel.anchorPoint = ccp(0, 0);
	
	CCLabelBMFont *playLabel = [CCLabelBMFont labelWithString:@"Play Game" fntFile:PROPS(@"MenuFont")];
	CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:playLabel target:self selector:@selector(doPlay)];
	
	//CCLabelBMFont *leaderboardLabel = [CCLabelBMFont labelWithString:@"Leaderboard" fntFile:PROPS(@"MenuFont")];
	//CCMenuItemLabel *item2 = [CCMenuItemLabel itemWithLabel:leaderboardLabel target:self selector:@selector(showLeaderboard)];
	
	CCLabelBMFont *settingsLabel = [CCLabelBMFont labelWithString:@"Settings" fntFile:PROPS(@"MenuFont")];
	CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:settingsLabel target:self selector:@selector(showSettings)];
	
	CCLabelBMFont *helpLabel = [CCLabelBMFont labelWithString:@"How to Play" fntFile:PROPS(@"MenuFont")];
	CCMenuItemLabel *item4 = [CCMenuItemLabel itemWithLabel:helpLabel target:self selector:@selector(showHelp)];
	
	CCLabelBMFont *statsLabel = [CCLabelBMFont labelWithString:@"My Stats" fntFile:PROPS(@"MenuFont")];
	CCMenuItemLabel *item5 = [CCMenuItemLabel itemWithLabel:statsLabel target:self selector:@selector(showStats)];
	
	menu = [CCMenu menuWithItems:item1, item5, item3, item4, nil];
	[menu setPosition:ccp(winSize.width/2.0, round(winSize.height*0.55))];
	[menu alignItemsVerticallyWithPadding:0];
	[panel addChild:menu];
	
	///////////
	
#if !defined(LITE_APP)
	CCLabelBMFont *continueLabel = [CCLabelBMFont labelWithString:@"-  Leaderboards" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *itemA = [CCMenuItemLabel itemWithLabel:continueLabel target:self selector:@selector(showLeaderboard)];
	
	CCLabelBMFont *restartLabel = [CCLabelBMFont labelWithString:@"Achievements  -" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *itemB = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(showAchievements)];
	
	CCLabelBMFont *sepLabel1 = [CCLabelBMFont labelWithString:@"-" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *separator1 = [CCMenuItemLabel itemWithLabel:sepLabel1 target:self selector:@selector(doNothing)];
	
	CCMenu *menu2 = [CCMenu menuWithItems:itemA, separator1, itemB, nil];
	[menu2 setPosition:ccp(winSize.width/2.0, round(winSize.height*bottomLine))];
	[menu2 alignItemsHorizontallyWithPadding:round(winSize.width/50.0)];
	[panel addChild:menu2];
#else
	CCLabelBMFont *fullLabel = [CCLabelBMFont labelWithString:@"-  Get the Full Version  -" fntFile:PROPS(@"CaptionFont")];
	CCMenuItemLabel *itemA = [CCMenuItemLabel itemWithLabel:fullLabel target:self selector:@selector(getFullVersion)];
	
	CCMenu *menu2 = [CCMenu menuWithItems:itemA, nil];
	[menu2 setPosition:ccp(winSize.width/2.0, round(winSize.height*bottomLine))];
	[menu2 alignItemsHorizontallyWithPadding:round(winSize.width/50.0)];
	[panel addChild:menu2];
#endif
	
	////////////////
	
	
	[self addChild:panel];
}

//////////////////

- (void) getFullVersion
{
	if([[Properties sharedProperties] isIPad])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.com/apps/protectthemessengerhd"]];
	}
	else
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.com/apps/protectthemessenger"]];	
	}
}

//////////////////////////

- (void) showLeaderboard
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLeaderboards" object:nil];

	if([Properties sharedProperties].gamecenter == NO)
	{
		[self reset];
		CCNode *panel = [CCNode node];
		panel.anchorPoint = ccp(0, 0);
		CGPoint location = ccp(winSize.width/2.0, winSize.height * bottomLine);
		menuButton = [Button buttonWithImage:HD_PNG(@"back") onImage:HD_PNG(@"back") atPosition:location target:self selector:@selector(back)];
		[panel addChild:menuButton];
		[self addChild:panel];
	}
#if FLURRY	
	[FlurryAPI logEvent:@"VIEW_LEADERBOARDS"];
#endif
}

- (void) showAchievements
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAchievements" object:nil];
#if FLURRY
	[FlurryAPI logEvent:@"VIEW_ACHIEVEMENTS"];
#endif
}
	
////////////////////////


- (void) showStats
{
	[self reset];
	
	CCNode *panel = [CCNode node];
	panel.anchorPoint = ccp(0, 0);
	
	CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"High Score:" fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"Average Score:" fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label3 = [CCLabelBMFont labelWithString:@"Total Games:" fntFile:PROPS(@"MenuFont")];
	
	label1.anchorPoint = ccp(1, 0.5);
	label2.anchorPoint = ccp(1, 0.5);
	label3.anchorPoint = ccp(1, 0.5);
	
	label1.position = ccp(round(winSize.width * 0.52), round(winSize.height * 0.66));
	label2.position = ccp(round(winSize.width * 0.52), round(winSize.height * 0.54));
	label3.position = ccp(round(winSize.width * 0.52), round(winSize.height * 0.42));
	
	[panel addChild:label1];
	[panel addChild:label2];
	[panel addChild:label3];
	
	//////
	
	CCLabelBMFont *label1b = [CCLabelBMFont labelWithString:[[Properties sharedProperties] formattedScore:[Properties sharedProperties].highScore] fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label2b = [CCLabelBMFont labelWithString:[[Properties sharedProperties] formattedScore:[Properties sharedProperties].averageScore] fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label3b = [CCLabelBMFont labelWithString:[[Properties sharedProperties] formattedScore:[Properties sharedProperties].totalGames] fntFile:PROPS(@"MenuFont")];
	
	label1b.anchorPoint = ccp(0, 0.5);
	label2b.anchorPoint = ccp(0, 0.5);
	label3b.anchorPoint = ccp(0, 0.5);
	
	label1b.position = ccp(round(winSize.width * 0.55), round(winSize.height * 0.66));
	label2b.position = ccp(round(winSize.width * 0.55), round(winSize.height * 0.54));
	label3b.position = ccp(round(winSize.width * 0.55), round(winSize.height * 0.42));
	
	[panel addChild:label1b];
	[panel addChild:label2b];
	[panel addChild:label3b];
	
	//////
	
	CGPoint location = ccp(winSize.width/2.0, winSize.height * bottomLine);
	menuButton = [Button buttonWithImage:HD_PNG(@"back") onImage:HD_PNG(@"back") atPosition:location target:self selector:@selector(back)];
	[panel addChild:menuButton];
	[self addChild:panel];
}


////////////////////

- (void) showSettings
{
	TRACE(@"show settings");
	[self reset];
	
	CCNode *panel = [CCNode node];
	panel.anchorPoint = ccp(0, 0);
	
	CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Music:" fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label2 = [CCLabelBMFont labelWithString:@"Effects:" fntFile:PROPS(@"MenuFont")];
	CCLabelBMFont *label3 = [CCLabelBMFont labelWithString:@"Reset Level:" fntFile:PROPS(@"MenuFont")];
	
	Button *musicBtn = [Button buttonWithToggle:[Properties sharedProperties].music offImage:HD_PNG(@"box-no") onImage:HD_PNG(@"box-yes") 
																	 atPosition:ccp(round(winSize.width * 0.6), round(winSize.height * 0.67)) target:self selector:@selector(toggleMusic:)];
	[panel addChild:musicBtn];
	
	Button *fxBtn = [Button buttonWithToggle:[Properties sharedProperties].audio offImage:HD_PNG(@"box-no") onImage:HD_PNG(@"box-yes") 
																atPosition:ccp(round(winSize.width * 0.6), round(winSize.height * 0.54)) target:self selector:@selector(toggleFX:)];
	[panel addChild:fxBtn];
	
	
	Button *submitBtn = [Button buttonWithToggle:[Properties sharedProperties].resetLevel offImage:HD_PNG(@"box-no") onImage:HD_PNG(@"box-yes") 
																		atPosition:ccp(round(winSize.width * 0.6), round(winSize.height * 0.41)) target:self selector:@selector(toggleLevelReset:)];
	
	label1.anchorPoint = ccp(1, 0.5);
	label2.anchorPoint = ccp(1, 0.5);
	label3.anchorPoint = ccp(1, 0.5);
	
	label1.position = ccp(round(winSize.width * 0.5), round(winSize.height * 0.67));
	label2.position = ccp(round(winSize.width * 0.5), round(winSize.height * 0.54));
	label3.position = ccp(round(winSize.width * 0.5), round(winSize.height * 0.41));
	
	[panel addChild:label1];
	[panel addChild:label2];
	
	[panel addChild:label3];
	[panel addChild:submitBtn];
	
	CGPoint location = ccp(winSize.width/2.0, round(winSize.height * bottomLine));
	menuButton = [Button buttonWithImage:HD_PNG(@"back") onImage:HD_PNG(@"back") atPosition:location target:self selector:@selector(back)];
	[panel addChild:menuButton];
	[self addChild:panel];
	
#if FLURRY
	[FlurryAPI logEvent:@"VIEW_SETTINGS"];
#endif
}

- (void) toggleMusic:(id)sender
{
	ButtonItem *button = sender;
	[Properties sharedProperties].music = button._selected;
	[[NSUserDefaults standardUserDefaults] setBool:button._selected forKey:@"music"];
	if([Properties sharedProperties].music == NO) {
		[[MusicPlayer sharedMusicPlayer] stop];
	} else {
		[[MusicPlayer sharedMusicPlayer] playSong];
	}

}

- (void) toggleFX:(id)sender
{
	ButtonItem *button = sender;
	[Properties sharedProperties].audio = button._selected;
	[[NSUserDefaults standardUserDefaults] setBool:button._selected forKey:@"audio"];	
	if([Properties sharedProperties].audio == NO) {
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
	} else {
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:[Properties sharedProperties].effectVolume];
		if([SimpleAudioEngine sharedEngine].mute == YES) {
			[[SimpleAudioEngine sharedEngine] setMute:NO];
		}
	}
}

- (void) toggleLevelReset:(id)sender
{
	ButtonItem *button = sender;
	[Properties sharedProperties].resetLevel = button._selected;
	[[NSUserDefaults standardUserDefaults] setBool:button._selected forKey:@"resetLevel"];
}

////////////////////////////////

- (void) back
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePopup" object:nil];
	[self showMenu];
}

- (void) showHelp
{
	[self reset];
	TRACE(@"show help");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowInfo" object:nil];
	CCNode *panel = [CCNode node];
	panel.anchorPoint = ccp(0, 0);
		
	CGPoint location = ccp(winSize.width/2.0, winSize.height * bottomLine);
	menuButton = [Button buttonWithImage:HD_PNG(@"back") onImage:HD_PNG(@"back") atPosition:location target:self selector:@selector(back)];
	[panel addChild:menuButton];
	[self addChild:panel];
	
#if FLURRY	
	[FlurryAPI logEvent:@"VIEW_HELP"];
#endif
}

- (void) doPlay
{
	if([Properties sharedProperties].tips == YES)
	{
		[delegate showTips];
	}
	else {
		[delegate startGame];
	}
}

/*
- (void) doRestart
{
	[delegate restartGame];
}*/

- (void) doNothing
{
	
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	TRACE(@"touch began");
	//UITouch *touch = [touches anyObject];
	if(view == SplashViewTitle) {
		[self showMenu];
	}
}

- (void) dealloc
{
	TRACE(@"dealloc splash");
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

@end
