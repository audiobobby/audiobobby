//
//  Hub.m
//  Balloons
//
//  Created by Mehayhe on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tips.h"
#import "Button.h"

@implementation Tips

@synthesize delegate;


-(id) init
{
	if( (self=[super init])) 
	{	
		TRACE(@"init tips");
		self.anchorPoint = ccp(0, 0);
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(-winSize.width, 0);
		
		back = [CCSprite spriteWithFile:HD_PNG(@"tips")];
		back.position = ccp(winSize.width/2.0, winSize.height/2.0);
			
		[self addChild:back];	
		
		NSString *fontName = @"Arial-BoldMT";
		int fontSize = ([[Properties sharedProperties] isIPad]) ? 32 : 18;
		
		CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Don't Show This Again" fontName:fontName fontSize:fontSize];
		label1.color = ccc3(255,255,255);
		CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:label1 target:self selector:@selector(doNotShow)];
		
		CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"Play Game Now" fontName:fontName fontSize:fontSize];
		label3.color = ccc3(255,255,255);
		CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:label3 target:self selector:@selector(doPlay)];
		
		CCLabelTTF *sepLabel1 = [CCLabelTTF labelWithString:@"  |  " fontName:fontName fontSize:fontSize];
		sepLabel1.color = ccc3(90,90,90);
		CCMenuItemLabel *separator1 = [CCMenuItemLabel itemWithLabel:sepLabel1 target:self selector:@selector(doNothing)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, separator1, item3, nil];
		float bottom_ratio = ([[Properties sharedProperties] isIPad]) ? 0.20 : 0.14;
		[menu setPosition:ccp(winSize.width/2.0, round(winSize.height*bottom_ratio))];
		[menu alignItemsHorizontally];
		[self addChild:menu];											
	}
	return self;
}


- (void) onEnter 
{
	[super onEnter];
	TRACE(@"show splash");
	
	id action0 = [CCMoveBy actionWithDuration:0.5f position:ccp(0, 0)];
	id action1 = [CCMoveTo actionWithDuration:0.3f position:ccp(0, 0)];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(showCompleted:)]; 
	id seq = [CCSequence actions:action0, action1, action2, nil];
	//id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];
}


- (void) hide
{
	TRACE(@"hide splash");
	id action1 = [CCMoveTo actionWithDuration: 0.5 position:ccp([[CCDirector sharedDirector] winSize].width, 0)];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(hideCompleted:)]; 
	id seq = [CCSequence actions:[CCEaseIn actionWithAction:action1 rate:2], action2, nil];
	//id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];	
}

/*
- (void) onEnter 
{
	[super onEnter];
	id action1 = [CCFadeIn actionWithDuration:1];
	[back runAction:action1];	
}

- (void) hide
{
	id action1 = [CCFadeOut actionWithDuration:1];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(hideCompleted:)]; 
	id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];	
}
*/

- (void) showCompleted:(id)node
{
	
}

- (void) hideCompleted:(id)node
{
	[delegate operationCompleted:OperationRemoveTips];
}

- (void) doNotShow
{
	TRACE(@"don't show again");
	[Properties sharedProperties].tips = NO;
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tips"];
	[delegate startGame];
}

- (void) doPlay
{
	[delegate startGame];
}

- (void) doNothing
{
	
}

- (void) dealloc
{
	TRACE(@"dealloc tips");
	[self removeChild:back cleanup:YES];
	[super dealloc];
}

@end
