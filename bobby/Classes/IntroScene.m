//
//  IntroScene.m
//  Unicorn
//
//  Created by Mehayhe on 10/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IntroScene.h"
#import "MainScene.h"

@implementation IntroScene


+(id) scene
{
	CCScene *scene = [CCScene node];
	IntroScene *layer = [IntroScene node];
	[scene addChild: layer];
	return scene;
}


-(id) init
{
	if( (self=[super init])) 
	{	
						
	}
	return self;
}


- (void) fadeOut
{
	[self unscheduleAllSelectors];
	CCSprite *back = [CCSprite spriteWithFile:PNG(@"h2indie")];
	back.anchorPoint = ccp(0, 0);
	back.opacity = 0;
	[self addChild:back];
	id action1 = [CCFadeIn actionWithDuration:0.3];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(switchScene)]; 
	//id seq = [CCSequence actions:[CCEaseIn actionWithAction:action1 rate:4], action2, nil];
	id seq = [CCSequence actions:action1, action2, nil];
	[back runAction:seq];		
}

- (void) switchScene
{	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5f scene:[MainScene scene]]];
}

- (void) onEnter
{
	[super onEnter];
	[self schedule:@selector(fadeOut) interval:3];
	[self fadeOut];
}

- (void) onExit
{
	[super onExit];
	[self removeAllChildrenWithCleanup:YES];
}


@end
