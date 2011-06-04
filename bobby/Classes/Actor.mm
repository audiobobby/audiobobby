//
//  Balloon.m
//  Balloons
//
//  Created by Mehayhe on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Actor.h"
#import "SimpleAudioEngine.h"

#define TOTAL_RUN_FRAMES 18
#define TOTAL_JUMP_FRAMES 30
#define TOTAL_FALL_FRAMES 31

@implementation Actor

@synthesize aFrame, justLanded, radius;
@synthesize delegate, rotate;
@synthesize body, fixture;

-(id) init
{
	if( (self=[super init])) 
	{	
		self.tag = ObjectTypeUnicorn;
		
		CCSpriteBatchNode *sheet4 = [CCSpriteBatchNode batchNodeWithFile:@"horserider.png" capacity:50];
		[self addChild:sheet4];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"horserider.plist"];
		
		sprite = [CCSprite spriteWithSpriteFrameName:@"gallop_0012.png"];
		[self addChild:sprite];
		sprite.scale = ([[Properties sharedProperties] isLowResIPhone] == NO) ? 1.0 : 0.5;
		radius = (sprite.contentSize.height * 0.41) * sprite.scale;
		
		runningFrames = [[NSMutableArray alloc] initWithCapacity:TOTAL_RUN_FRAMES];
		for(int i = 0; i < TOTAL_RUN_FRAMES; i++)
		{
			CCSpriteFrame *sf = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"gallop_%04d.png",i+12]];
			[runningFrames addObject:sf];
		}
				
		fallingFrames = [[NSMutableArray alloc] initWithCapacity:TOTAL_FALL_FRAMES];
		for(int i = 1; i <= TOTAL_FALL_FRAMES; i++)
		{
			CCSpriteFrame *sf = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"fall_%04d.png",i]];
			[fallingFrames addObject:sf];
		}
		
		[self setMode:ModeFalling];
		aFrame = 0;
		
	}
	return self;
}

- (void) update:(ccTime)dt
{
	CCSpriteFrame *sf;
	switch (mode) {
		case ModeRunning:
			if(aFrame >= TOTAL_RUN_FRAMES) aFrame = 0;
			sf = [runningFrames objectAtIndex:aFrame];
			[sprite setDisplayFrame:sf];
			aFrame++;
			break;

		case ModeFalling:
			if(aFrame < TOTAL_FALL_FRAMES) 
			{
				sf = [fallingFrames objectAtIndex:aFrame];
				[sprite setDisplayFrame:sf];
				aFrame+=1;
			}
			break;
	
	}
	//TRACE(@"frame:%d mode:%d", aFrame, mode);
}

- (void) setMode:(int)val
{
	[self unschedule:@selector(update:)];
	aFrame = 0;
	mode = val;
	[self schedule:@selector(update:) interval:1/30.0];
}

- (int) getMode
{
	return mode;
}

- (void) dealloc
{
	TRACE(@"dealloc unicorn");
	[self unscheduleAllSelectors];
	[self removeChild:sprite cleanup:YES];
	[jumpingFrames release];
	[runningFrames release];
	[fallingFrames release];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[super dealloc];
}

	
@end
