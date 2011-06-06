//
//  SkyView.m
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SingleWaveBar.h"


#import "World.h"
#import "Actor.h"
#import "SimpleAudioEngine.h"
#import "Path.h"

#if DEBUG_MODE
	#define DEBUG_PHYSIC 1
#else
	#define DEBUG_PHYSIC 0
#endif

@interface World (internal)
- (void) startRun;
- (void) updateElements;
- (void) createGround;
- (void) showActorAtLocation:(CGPoint)pos;
@end

@implementation World

@synthesize delegate, actor;

- (void)omidUpdate2
{
    for (SingleWaveBar *bar in bars) {
 
        if ([bar getBarHeight] <= 0.0) {
            bar.tempWaveDirection = 1;
        } else if ([bar getBarHeight] >= 1.0) {
            bar.tempWaveDirection = -1;
            SoundStar *star = [SoundStar node];
            
            [star addToWorld:world location:ccp( bar.barSprite.position.x , bar.barSprite.position.y+bar.barSprite.contentSize.height/2+4+star.sprite.contentSize.height/2)];
            
            [self addChild:star];
            star.delegate = self;
            
            
            [stars addObject:star];
        }
        
        float oldBarHeight = [bar getBarHeight];
        
        [bar setBarHeight:oldBarHeight+0.05*bar.tempWaveDirection];
    }
}

-(id) init
{
	if( (self=[super init])) 
	{	
		firstRun = YES;
		winSize = [CCDirector sharedDirector].winSize;
		cloudSpeedRatio = ([[Properties sharedProperties] isLowRes]) ? 10 : 5;
		
		startTime = [[NSDate date] retain];
		
		b2Vec2 gravity;
		if([[Properties sharedProperties] isLowResIPhone] == NO) {
			gravity.Set(0.0f, -20.0f);
		} else {
			gravity.Set(0.0f, -10.0f);
		}
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		contactListener = new MyContactListener();
		world->SetContactListener(contactListener);

        bars = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 10; i++) {
            [bars addObject:[[SingleWaveBar alloc] initWithColumn:i]];
            [[bars objectAtIndex:i] setBarHeight:(float)i/10.0];
            
            [self addChild:[[bars objectAtIndex:i] barSprite]];
        }
        
        stars = [[NSMutableArray alloc] init];   
        
        CCSprite *lowerBar = [[CCSprite spriteWithFile:@"lowerBar.png"] retain];
        
        lowerBar.position = ccp(winSize.width/2, lowerBar.contentSize.height/2);
        [self addChild:lowerBar];
        
#if DEBUG_PHYSIC
		// Debug Draw functions

		m_debugDraw = new GLESDebugDraw(PTM_RATIO);
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
				flags += b2DebugDraw::e_jointBit;
		//		flags += b2DebugDraw::e_aabbBit;
		//		flags += b2DebugDraw::e_pairBit;
		//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
#endif
		
		[self createGround];
	}
	return self;
}


- (void) createGround
{
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); 

	b2FixtureDef fixtureDef;
	fixtureDef.filter.groupIndex = 2;
	fixtureDef.filter.categoryBits = GROUND_BIT;
	fixtureDef.filter.maskBits = ACTOR_BIT^SOUNDSTAR_BIT;
	
	b2Body* groundBody = world->CreateBody(&groundBodyDef);

	b2PolygonShape groundBox;		
	
	float leftX = 0; 
	
	
	groundNode = [[Path node] retain];
	
	// left
	groundBox.SetAsEdge(b2Vec2(leftX, winSize.height/PTM_RATIO), b2Vec2(leftX,0));
	fixtureDef.shape = &groundBox;	
	wallFixture = groundBody->CreateFixture(&fixtureDef);
	
	// right
	groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
	fixtureDef.shape = &groundBox;
	groundBody->CreateFixture(&fixtureDef);
	
	// top
	groundBox.SetAsEdge(b2Vec2(leftX, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height));
	fixtureDef.shape = &groundBox;
	groundBody->CreateFixture(&fixtureDef);
	
	// bottom
	groundBox.SetAsEdge(b2Vec2(leftX, 60.0/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 60.0/PTM_RATIO));
	fixtureDef.shape = &groundBox;
	fixtureDef.userData = groundNode;
	groundFixture = groundBody->CreateFixture(&fixtureDef);	
}

///////////////


- (float) angleFrom:(b2Vec2)p1 to:(b2Vec2)p2
{
	float offsetX = (p2.x - p1.x);
	float offsetY = (p2.y - p1.y);
	float angleRadians = atanf(offsetY / offsetX);
	return CC_RADIANS_TO_DEGREES(angleRadians);
}

/*
- (void) createGround:(int)gid
{	
	//TRACE(@"GROUND COUNTER: %d,  INDEX: %d, %f %f", groundCounter, groundBodyIndex, groundMap[0].position.x, groundMap[1].position.x);
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set((gid * groundWidth)/PTM_RATIO, 0); 
	groundBody[gid] = world->CreateBody(&groundBodyDef);

	b2PolygonShape groundShape;		
	
	b2FixtureDef fixtureDef;
	fixtureDef.filter.groupIndex = 2;
	fixtureDef.filter.categoryBits = GROUND_BIT;
	fixtureDef.filter.maskBits = ACTOR_BIT ^ BULLET_BIT;
	//fixtureDef.restitution = 0.0;
	//fixtureDef.friction = 1.0;
	
	b2Vec2 vOff = b2Vec2((gid == 0) ? 5120 : 0, 22); //b2Vec2(groundWidth/2.0, 51);
	float ptm_ratio = ([[Properties sharedProperties] isIPad]) ? PTM_RATIO/2.0 : PTM_RATIO;
	
	//TRACE(@"vOFF: %f, %d, %f", vOff.x, groundCounter, groundMap[groundBodyIndex].position.x);
	int n = (gid == 0) ? 1 : 63;
	int total = (gid == 0) ? 64 : ground_coordinates_total;
	
	//TRACE(@"[GROUNDWIDTH: %f, %f, %d, %d, %d", groundWidth, vOff.x, n, total, gid);
	//TRACE(@"NEW GROUND COUNTER: %d,  INDEX: %d, %f %f", groundCounter, groundBodyIndex, groundMap[0].position.x, groundMap[1].position.x);
	
	for (int i = n; i < total; i++) 
	{
		b2Vec2 v1 = (ground_coordinates[i-1] + vOff);
		b2Vec2 v2 = (ground_coordinates[i] + vOff);
		fixtureDef.shape = &groundShape;
		NSNumber *angle = [[NSNumber numberWithFloat:([self angleFrom:v1 to:v2] * -1)] retain];
		[groundAngles addObject:angle];
		fixtureDef.userData = angle;
		groundShape.SetAsEdge(b2Vec2(v1.x/ptm_ratio, v1.y/ptm_ratio), b2Vec2(v2.x/ptm_ratio, v2.y/ptm_ratio));
		groundBody[gid]->CreateFixture(&fixtureDef);
		//TRACE(@"%f %f, %f %f", v1.x/ptm_ratio, v1.y/ptm_ratio, v2.x/ptm_ratio, v2.y/ptm_ratio);
	}	
}
*/

- (void) showActorAtLocation:(CGPoint)pos
{
	//TRACE(@"show actor start at:%f, %f, %f", pos, self.position.x, pos - self.position.x);
	
	//speed = ([[Properties sharedProperties] isIPad]) ? 10 : 5;
	
	actor = [Actor node];
	actor.delegate = self;
	[actor addToWorld:world location:pos];
	[self addChild:actor z:9];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ActorCreated" object:actor];	
	
	[self unscheduleUpdate];
	[self scheduleUpdate];
	[self schedule:@selector(updateElements) interval:0.5];	
	[self updateElements];
	
	active = YES;
	moving = YES;
}

	
- (void) removeActor
{
	TRACE(@"remove actor");
	world->DestroyBody(actor.body);
	actor.body = nil;
	actor.fixture = nil;
	[self removeChild:actor cleanup:YES];
	actor = nil;
}

- (void)removeStar:(SoundStar *)star
{
    TRACE(@"remove star");
	world->DestroyBody(star.body);
	star.body = nil;
	star.fixture = nil;
	[self removeChild:star cleanup:YES];
	star = nil;
}

- (void) startRun
{
	TRACE(@"[start run]");
	
	
}

- (void) endRun
{
	TRACE(@"[endrun]");
	//[self unschedule:@selector(updateElements)];
	//[self unschedule:@selector(gotoNextLevel)];
	
	[self unscheduleAllSelectors];
	[self stopAllActions];
	[self removeActor];
	
    for (SoundStar *star in stars) {
        [self removeStar:star];
    }
    
	firstPath = YES;
	moving = NO;
	active = NO;
	dying = NO;
}

- (void) stopRun
{
	[delegate endGame];
}

////////////////

#if DEBUG_PHYSIC	
-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
		
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
}

#endif



/*
- (void) targetHit:(Bullet *)bullet
{
#if GOD_MODE
	return;
#endif
	if(bullet.live == NO) return;
	TRACE(@"TARGET HIT");
	bullet.live = NO;
	[bullet disable];
	int hitTotal = [delegate hit];
	if(hitTotal >= MAX_LIVES)
	{
		if([actor getMode] != ModeFalling)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"dying.caf"];
			[[SimpleAudioEngine sharedEngine] playEffect:@"whinny.caf"];
			actor.tag = ObjectTypeRemoving;
			[actor setMode:ModeFalling];
			actor.body->SetLinearVelocity(b2Vec2(0, 0));
			//moving = NO;
			dying = YES;
			[self unschedule:@selector(attack)];
		}
	}
	else 
	{
		if(bullet.tag != ObjectTypeArrow) {
			int num = (arc4random() % 4)+1;
			[[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"grunt%d.caf", num]];
		} else {
			[[SimpleAudioEngine sharedEngine] playEffect:@"arrow_hit.caf"];
		}
	}

}
*/

-(void) update:(ccTime)dt
{
    [self omidUpdate2];
    
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			if(myActor.tag == ObjectTypeRemoving) continue;
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			if(myActor.tag != ObjectTypeActor)
			{
				myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			}
		}	
	}
	
		

	if(active == YES)
	{	
		if(actor.mode == AnimationIdle)
		{
			b2Vec2 velocity = actor.body->GetLinearVelocity();
			if(velocity.x > 0)
			{
				velocity.x *= 0.7;
			}
			else
			{
				velocity.x = 0;
			}
			actor.body->SetLinearVelocity(b2Vec2(velocity.x, velocity.y));
		}
		
		BOOL grounded = NO;
		std::vector<MyContact>::iterator pos;
		for(pos = contactListener->_contacts.begin(); pos != contactListener->_contacts.end(); ++pos) 
		{
			MyContact contact = *pos;
			id dataA = (id)contact.fixtureA->GetUserData();
			id dataB = (id)contact.fixtureB->GetUserData();
			//TRACE(@": %@, %@", dataA, dataB);
			if([dataA isKindOfClass:[Actor class]])
			{
				
				if([dataB isKindOfClass:[Path class]])	
				{
					//TRACE(@"grounded: %d, %d", grounded, actor.grounded);
					grounded = YES;
				} else if ([dataB isKindOfClass:[SoundStar class]])
                {
                    // actor collided with star
            
                    // star needs to be destroyed
                    [(SoundStar *)dataB destroy];
                    [(SoundStar *)dataB setDidHitActor:YES];
                    
                }
			}
			else if([dataA isKindOfClass:[Path class]])
			{
				if([dataB isKindOfClass:[Actor class]])	
				{
					//TRACE(@"grounded: %d, %d", grounded, actor.grounded);
					grounded = YES;
				} else if ([dataB isKindOfClass:[SoundStar class]])
                {
                    // path collided with star
                    
                    // star needs to be destroyed
                    [(SoundStar *)dataB destroy];
                }
			}
            else if([dataA isKindOfClass:[SoundStar class]])
			{
				if([dataB isKindOfClass:[Actor class]])	
				{
                    // star collided wtih actor
                    [(SoundStar *)dataA destroy];
                    [(SoundStar *)dataA setDidHitActor:YES];
					
				} else if ([dataB isKindOfClass:[Path class]])
                {
                    // star collided with path
                    
                    // star needs to be destroyed
                    [(SoundStar *)dataA destroy];
                }
			}
            
		}
		if(actor.grounded != grounded) {
			actor.grounded = grounded;
		}
		//TRACE(@"grounded: %d, %d", grounded, actor.grounded);
	}
	
}


- (void) updateElements
{		
	
	int total = [stars count];
	for (int i = total - 1; i >= 0; i--) 
	{
		SoundStar *thisStar = [stars objectAtIndex:i];
		if(thisStar.tag == ObjectTypeRemoving) {
            if (thisStar.didHitActor) {
                [delegate addPoints:1];
            }
			//[thisStar destroy:world];
            [self removeStar:thisStar];
			//[self removeChild:thisStar cleanup:YES];
			[stars removeObjectAtIndex:i];
		}
	}
	
	TRACE(@"total stars, %d", [stars count]);
//		
//	if(moving == YES)
//	{
//		if(dying == YES)
//		{
//			b2Vec2 velocity = actor.body->GetLinearVelocity();
//			speed = speed * 0.7;
//			actor.body->SetLinearVelocity(b2Vec2(speed, velocity.y));
//			[delegate setBackgroundSpeed:speed/cloudSpeedRatio];
//			if(speed < 0.4)
//			{
//				[delegate endGame];
//			}
//		}
//	}
	
}

- (void) initRun
{
	[self unschedule:@selector(initRun)];
	[self showActorAtLocation:ccp(winSize.width * 0.5, winSize.height * 0.25)];	
	firstRun = NO;
	timestamp = [startTime timeIntervalSinceNow]; 
	
//	SoundStar *star = [SoundStar node];
//    
//	[star addToWorld:world location:ccp(250, 250)];
//    
//	[self addChild:star];
//	star.delegate = self;
//	
//	
//	[stars addObject:star];
}

//- (void) removeBullet:(Bullet *)item
//{
//	TRACE(@"remove bullet");
//	if(item.body != nil) {
//		[item destroy:world];
//	}
//	[bullets removeObject:item];
//	[self removeChild:item cleanup:YES];		
//}


- (void) onExit
{
	[super onExit];
	TRACE(@"onExit world");
}

- (void) destroy
{
	destroyed = YES;
	TRACE(@"destroy");
	[self unscheduleAllSelectors];
	[self unscheduleUpdate];	
	
		
	if(actor != nil) [self removeActor];

	[self removeAllChildrenWithCleanup:YES];
}

- (void) dealloc 
{	
	TRACE(@"dealloc world");
	
	[self destroy];
	
	[groundNode release];
	
	delete contactListener;
	contactListener = nil;
	
	delete world;
	world = nil;
	
	[startTime release];
	[stars release];
	
	[super dealloc];
}

@end
