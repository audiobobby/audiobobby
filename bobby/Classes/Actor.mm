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

@synthesize aFrame, radius;
@synthesize delegate, rotate;
@synthesize body, fixture;

-(id) init
{
	if( (self=[super init])) 
	{	
		self.tag = ObjectTypeActor;
		
		CCSpriteBatchNode *sheet4 = [CCSpriteBatchNode batchNodeWithFile:@"bobby.png" capacity:10];
		[self addChild:sheet4];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bobby.plist"];
		
		sprite = [CCSprite spriteWithSpriteFrameName:@"rb_0001.png"];
		[self addChild:sprite];
		sprite.scale = ([[Properties sharedProperties] isLowResIPhone] == NO) ? 0.8 : 0.4;
		radius = (sprite.contentSize.height * 0.5) * sprite.scale;
		
		animationFrames = [[NSMutableArray alloc] initWithCapacity:10];
		allFrames = [[NSMutableArray alloc] initWithCapacity:10];
		for(int i = 1; i <= 9; i++)
		{
			CCSpriteFrame *sf = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"rb_%04d.png",i]];
			[allFrames addObject:sf];
			
		}
	
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
	TRACE(@"MOVE: %d, %d", move, MoveActionJump);
	if(move == lastAction && move != MoveActionJump) {
		move = MoveActionIdle;
	}
	lastAction = move;
	switch (move) {
		case MoveActionJump:
			{
				if(jumpCount % 2 == 0 && jumpCount < 3)
				{
					TRACE(@"jump count: %d", jumpCount);
					b2Vec2 center = self.body->GetWorldCenter();
					float impulse = (grounded == YES) ? self.radius * 27 : self.radius * 15;
					self.body->ApplyLinearImpulse(b2Vec2(0.0, impulse), center);
					[[SimpleAudioEngine sharedEngine] playEffect:@"jump.caf"];
					self.mode = AnimationJumping;
				}
				jumpCount++;
			}
			break;
			
		case MoveActionLeft:
			self.body->SetLinearVelocity(b2Vec2(speed*-1, 0));
			self.mode = AnimationRunning;
			sprite.flipX = YES;
			break;
			
		case MoveActionRight:
			self.body->SetLinearVelocity(b2Vec2(speed, 0));
			self.mode = AnimationRunning;
			sprite.flipX = NO;
			break;
			
		case MoveActionIdle:
			TRACE(@"idle");
			//if(self.grounded) 
			{
				self.body->SetLinearVelocity(b2Vec2(0, 0));
				self.mode = AnimationIdle;
			}
			break;	
			
		default:
			TRACE(@"default");
			break;
	}
}

- (void) update:(ccTime)dt
{
	CCSpriteFrame *sf;
	switch (mode) {
		case AnimationRunning:
		case AnimationJumping:
			if(aFrame >= totalFrames) aFrame = 0;
			sf = [animationFrames objectAtIndex:aFrame];
			[sprite setDisplayFrame:sf];
			aFrame++;
			break;
	
	}
}

- (void) setMode:(int)val
{
	[self unschedule:@selector(update:)];
	aFrame = 0;
	mode = val;
	[animationFrames removeAllObjects];
	switch (mode) {
		case AnimationRunning:
			for (int i = 7; i <= 8; i++) {
				[animationFrames addObject:[allFrames objectAtIndex:i-1]];
			}
			break;
			
		case AnimationJumping:
			for (int i = 2; i <= 6; i++) {
				[animationFrames addObject:[allFrames objectAtIndex:i-1]];
			}
			break;
			
		case AnimationIdle:
			[sprite setDisplayFrame:[allFrames objectAtIndex:0]];
			break;	
	}
	totalFrames = [animationFrames count];
	TRACE(@"frames: %d, %@", totalFrames, animationFrames);
	if(mode != AnimationIdle) {
		[self schedule:@selector(update:) interval:1/15.0];
	}
}

- (int) mode
{
	return mode;
}

- (void) setGrounded:(BOOL)val
{
	if(val == YES && grounded == NO) {
		jumpCount = 0;
		self.mode = AnimationIdle;
		TRACE(@"GROUNDED");
	}
	grounded = val;
	
}

- (BOOL) grounded
{
	return grounded;
}

- (void) dealloc
{
	TRACE(@"dealloc actor");
	[self unscheduleAllSelectors];
	[self removeChild:sprite cleanup:YES];
	[animationFrames release];
	[allFrames release];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[super dealloc];
}

	
@end
