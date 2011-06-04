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
		self.tag = ObjectTypeActor;
		
//		CCSpriteBatchNode *sheet4 = [CCSpriteBatchNode batchNodeWithFile:@"bobby.png" capacity:50];
//		[self addChild:sheet4];
//		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bobby.plist"];
		
		sprite = [CCSprite spriteWithFile:@"bobbyFront.png"]; // [CCSprite spriteWithSpriteFrameName:@"gallop_0012.png"];
		[self addChild:sprite];
		//sprite.scale = ([[Properties sharedProperties] isLowResIPhone] == NO) ? 1.0 : 0.5;
		radius = (sprite.contentSize.height * 0.5) * sprite.scale;
//		
//		runningFrames = [[NSMutableArray alloc] initWithCapacity:TOTAL_RUN_FRAMES];
//		for(int i = 0; i < TOTAL_RUN_FRAMES; i++)
//		{
//			CCSpriteFrame *sf = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"gallop_%04d.png",i+12]];
//			[runningFrames addObject:sf];
//		}
//				
//		fallingFrames = [[NSMutableArray alloc] initWithCapacity:TOTAL_FALL_FRAMES];
//		for(int i = 1; i <= TOTAL_FALL_FRAMES; i++)
//		{
//			CCSpriteFrame *sf = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"fall_%04d.png",i]];
//			[fallingFrames addObject:sf];
//		}
		
		[self setMode:AnimationIdle];
		aFrame = 0;
		speed = 5.0;
		
	}
	return self;
}

- (void) addToWorld:(b2World *)world location:(CGPoint)pos
{
	self.position = pos;
	TRACE(@"actor: %f, %f", pos.x, pos.y);
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set((self.position.x + (self.radius/2.0))/PTM_RATIO, self.position.y/PTM_RATIO);
	bodyDef.userData = self;
	self.body = world->CreateBody(&bodyDef);
	
	b2CircleShape shape;
	shape.m_radius = self.radius/PTM_RATIO;
	//shape.m_p = b2Vec2(0, -(actor.radius*0.3)/PTM_RATIO);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = self.radius * 2;
	fixtureDef.filter.groupIndex = 1;
	fixtureDef.filter.categoryBits = ACTOR_BIT;
	fixtureDef.filter.maskBits = GROUND_BIT;
	fixtureDef.userData = self;
	self.fixture = self.body->CreateFixture(&fixtureDef);
}

- (void) move:(int)move
{
	TRACE(@"MOVE: %d", move);
	switch (move) {
		case MoveActionJump:
			{
				b2Vec2 center = self.body->GetWorldCenter();
				float impulse = 10.0;
				self.body->ApplyLinearImpulse(b2Vec2(impulse, 0), center);
			}
			break;
			
		case MoveActionLeft:
			self.body->SetLinearVelocity(b2Vec2(speed*-1, 0));
			break;
			
		case MoveActionRight:
			self.body->SetLinearVelocity(b2Vec2(speed, 0));
			break;
			
		case MoveActionIdle:
			self.body->SetLinearVelocity(b2Vec2(0, 0));
			break;	
	}
}

- (void) update:(ccTime)dt
{
	CCSpriteFrame *sf;
	switch (mode) {
			/*
		case AnimationRunning:
			if(aFrame >= TOTAL_RUN_FRAMES) aFrame = 0;
			sf = [runningFrames objectAtIndex:aFrame];
			[sprite setDisplayFrame:sf];
			aFrame++;
			break;

		case AnimationFalling:
			if(aFrame < TOTAL_FALL_FRAMES) 
			{
				sf = [fallingFrames objectAtIndex:aFrame];
				[sprite setDisplayFrame:sf];
				aFrame+=1;
			}
			break;
			*/
	
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

- (int) mode
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
