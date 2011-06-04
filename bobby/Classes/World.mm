//
//  SkyView.m
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "World.h"
#import "Actor.h"
#import "SimpleAudioEngine.h"
#import "Path.h"

#define SHIELD_ALPHA_STOP 0.2
#define SHIELD_ALPHA_STEP 0.016

#if DEBUG_MODE
	#define GOD_MODE 0
	#define DEBUG_PHYSIC 0
	#define LEVEL_DURATION 25
#else
	#define GOD_MODE 0
	#define DEBUG_PHYSIC 0
	#define LEVEL_DURATION 45
#endif

@interface World (internal)
- (void) startRun;
- (void) updateElements;
- (void) createGround;
- (void) removeShield;
- (void) initShotTable:(int[])table;
- (void) shuffle;
- (void) showactorAtLocation:(float)pos;
- (void) createGround:(int)gid;
@end

@implementation World

@synthesize delegate;


-(id) init
{
	if( (self=[super init])) 
	{	
		firstRun = YES;
		winSize = [CCDirector sharedDirector].winSize;
		cloudSpeedRatio = ([[Properties sharedProperties] isLowRes]) ? 10 : 5;
		speedStep = 0.04;
		
		startTime = [[NSDate date] retain];
		
		b2Vec2 gravity;
		if([[Properties sharedProperties] isLowResIPhone] == NO) {
			gravity.Set(0.0f, -6.0f);
		} else {
			gravity.Set(0.0f, -3.0f);
		}
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		contactListener = new MyContactListener();
		world->SetContactListener(contactListener);

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
		
	}
	return self;
}

- (void) restoreShield
{
	[self unschedule:@selector(restoreShield)];
	if(shieldCounter > 0) {
		shieldCounter = 1;
	}
}

- (void) createShieldPath:(CGPoint)p1 to:(CGPoint)p2
{
	p1.x = p1.x - self.position.x;
	p2.x = p2.x - self.position.x;
	//TRACE(@"create path:%f %f, %f %f", p1.x, p1.y, p2.x, p2.y);
	Path *path = [Path node];
	b2BodyDef bodyDef;
	bodyDef.userData = path;
	path.body = world->CreateBody(&bodyDef);
	b2PolygonShape pathShape;
	pathShape.SetAsEdge(b2Vec2(p1.x/PTM_RATIO, p1.y/PTM_RATIO), b2Vec2(p2.x/PTM_RATIO, p2.y/PTM_RATIO));
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &pathShape;
	fixtureDef.filter.groupIndex = 2;
	fixtureDef.filter.categoryBits = PATH_BIT;
	fixtureDef.filter.maskBits = BULLET_BIT;
	fixtureDef.userData = path;
	path.fixture = path.body->CreateFixture(&fixtureDef);
	[shieldPaths addObject:path];
}

- (void) drawShield:(CGPoint [])points total:(int)total fade:(float)fade
{
	float newTimestamp = [startTime timeIntervalSinceNow]; 
	float diff = fabs(newTimestamp - timestamp);
	
	//NSLog(@"%f, diff:%f", fade, diff);
	if(diff < shieldDiff)
	{
		shieldCounter++;
		if(shieldCounter > shieldCounterMax) shieldCounter = shieldCounterMax;
	}
	else 
	{
		shieldCounter--;
		if(shieldCounter < 0) shieldCounter = 0;
	}
	
	timestamp = newTimestamp;
	
	TRACE(@"add shield");
	
	if(shieldCounter >= shieldCounterMax) {
		[delegate showMessage:@"Slow down or you'll get overheated!" offset:0];
		//[delegate addPoints:-100];
		return;
	}
	
	if([shieldPaths count] > 0) {
		[self removeShield];
	}
	trailTotal = total;
	trail[0] = CGPointMake(points[0].x - self.position.x, points[0].y);
	for (int i = 1; i < total; i++) {
		[self createShieldPath:points[i-1] to:points[i]];
		trail[i] = CGPointMake(points[i].x - self.position.x, points[i].y);
	}	
	
	shieldActive = YES;
	lineAlpha = fade;
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"shield.caf" pitch:1 pan:0 gain:0.5];
	[delegate addPoints:-20];
}

- (void) removeShield
{
	TRACE(@"remove shield, %d", [shieldPaths count]);
	//[self unschedule:@selector(removeShield)];
	for(Path *path in shieldPaths)
	{
		[path destroy:world];
	}
	[shieldPaths removeAllObjects];
	shieldActive = NO;
}


- (void) shuffle
{
	shieldCounterMax = 3;
	shieldDiff = 0.4;
	currentShot = 0;
	int level = [delegate currentLevel];
	TRACE(@"CHANGE LEVEL: %d", level);
/*
#if DEBUG_MODE
	delayOffset = 1.0;
	concurrent = 2;
	//int table1[] = {ObjectTypeSpear, 50, ObjectTypeCannonball, 50, ObjectTypeFireball, 50, ObjectTypePellet, 50, ObjectTypeArrow, 50, ObjectTypeIceball, 50, ObjectTypeSpitball, 50};
	int table1[] = {ObjectTypeSpear, 5, ObjectTypeCannonball, 5, ObjectTypeFireball, 5, ObjectTypePellet, 0, ObjectTypeArrow, 0, ObjectTypeIceball, 50, ObjectTypeSpitball, 50};
	[self initShotTable:table1];
	return;
#endif
	*/
		
}

- (void) initShotTable:(int[])table
{
	int len = 14;
	int n = 0;
	for (int i = 0; i < len; i=i+2) 
	{
		int cnt = table[i+1];
		int weapon = table[i];
		for (int j = 0; j < cnt; j++) 
		{
			shotTable[n] = weapon;
			n++;
		}
	}
	
	totalShots = n;
	
	/*
#if DEBUG_MODE
	for(int i = 0; i < totalShots; i++)
	{
		TRACE(@"%d %d", i, shotTable[i]);
	}
	TRACE(@"===============");
#endif
	*/
	
	int total = (arc4random() % 5)+1;
	for(int j = 0; j < total; j++)
	{
		for(int i = 1; i < totalShots; i++)
		{
			int n = arc4random() % 2;
			if(n != 1) continue;
			int t = shotTable[i-1];
			shotTable[i-1] = shotTable[i];
			shotTable[i] = t;
		}
		for(int i = 1; i < totalShots; i++)
		{
			int n = arc4random() % (totalShots);
			int t = shotTable[n];
			shotTable[n] = shotTable[i];
			shotTable[i] = t;
		}
	}
	
	/*
#if DEBUG_MODE
	 for(int i = 0; i < totalShots; i++)
	 {
		 TRACE(@"%d %d", i, shotTable[i]);
	 }
#endif
	*/
}

- (void) gotoNextLevel
{
#if defined(LITE_APP)
	if([delegate currentLevel] < MAX_LEVELS-1)
	{
		[delegate nextLevel];
	}
	else 
	{
		[self stopFollow];
	}
#else
	[delegate nextLevel];
#endif
	reshuffle = YES;
}


//- (void) attack
//{
//	[self unschedule:@selector(attack)];
//	float delay = delayOffset + ((arc4random() % 100)/100.0) * 1.0;
//	TRACE(@"delay: %f", delay);
//	if(reshuffle == YES) {
//		[self shuffle];
//		reshuffle = NO;
//	}
//	for(int i = 0; i < concurrent; i++)
//	{
//		[self shoot];
//	}
//	[self schedule:@selector(attack) interval:delay];
//}


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

- (void) showActorAtLocation:(float)pos
{
	//TRACE(@"show actor start at:%f, %f, %f", pos, self.position.x, pos - self.position.x);
	
	speed = ([[Properties sharedProperties] isIPad]) ? 10 : 5;
	
	actor = [Actor node];
	actor.delegate = self;
	actor.position = ccp(pos, winSize.height*0.25);
	[self addChild:actor z:9];
	[actor setMode:ModeLanding];
		
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set((actor.position.x + (actor.radius/2.0))/PTM_RATIO, actor.position.y/PTM_RATIO);
	bodyDef.userData = actor;
	actor.body = world->CreateBody(&bodyDef);
	
	b2CircleShape shape;
	shape.m_radius = actor.radius/PTM_RATIO;
	//shape.m_p = b2Vec2(0, -(actor.radius*0.3)/PTM_RATIO);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = actor.contentSize.width*0.5;
	fixtureDef.filter.groupIndex = 1;
	fixtureDef.filter.categoryBits = ACTOR_BIT;
	fixtureDef.filter.maskBits = GROUND_BIT;
	fixtureDef.userData = actor;
	actor.fixture = actor.body->CreateFixture(&fixtureDef);
	
	b2PolygonShape poly;
	//row 1, col 1
	//int num = 7;
	
	float scale_ratio = ([[Properties sharedProperties] isLowResIPhone] == NO) ? PTM_RATIO : 2*PTM_RATIO;
	
	b2Vec2 hverts[] = {
		b2Vec2(-49.0f / scale_ratio, 1.5f / scale_ratio),
		b2Vec2(-44.0f / scale_ratio, -29.5f / scale_ratio),
		b2Vec2(28.0f / scale_ratio, -22.5f / scale_ratio),
		b2Vec2(41.0f / scale_ratio, 10.5f / scale_ratio),
		b2Vec2(61.0f / scale_ratio, 5.5f / scale_ratio),
		b2Vec2(46.0f / scale_ratio, 31.5f / scale_ratio)
	};	
	poly.Set(hverts, 6);
	//shape.m_radius = (actor.radius*0.7)/PTM_RATIO;
	fixtureDef.shape = &poly;
	fixtureDef.filter.categoryBits = HITAREA_BIT;
	fixtureDef.filter.maskBits = BULLET_BIT;
	actor.body->CreateFixture(&fixtureDef);
	
	/////////////
	
	b2Vec2 rverts[] = {
    b2Vec2(-12.0f / scale_ratio, 19.5f / scale_ratio),
    b2Vec2(-10.0f / scale_ratio, -16.5f / scale_ratio),
    b2Vec2(3.0f / scale_ratio, 3.5f / scale_ratio),
    b2Vec2(22.0f / scale_ratio, 38.5f / scale_ratio),
    b2Vec2(17.0f / scale_ratio, 45.5f / scale_ratio)
	};
	poly.Set(rverts, 5);
	fixtureDef.shape = &poly;
	fixtureDef.filter.categoryBits = HITAREA_BIT;
	fixtureDef.filter.maskBits = BULLET_BIT;
	actor.body->CreateFixture(&fixtureDef);
	
	//////////////////
	
	[self unscheduleUpdate];
	[self scheduleUpdate];
	[self schedule:@selector(updateElements) interval:0.5];	
	[self updateElements];
	
	//[delegate startGame];
		
	active = YES;
	following = NO;
	moving = YES;
	
	[self shuffle];
	

	actor.body->SetLinearVelocity(b2Vec2(speed, 0));
	[actor setMode:ModeRunning];
	
	
}

	
- (void) removeActor
{
	TRACE(@"remove actor");
	world->DestroyBody(actor.body);
	actor.body = nil;
	actor.fixture = nil;
#if defined(USE_EMITTER)	
	[self removeChild:emitter cleanup:YES];
	emitter = nil;
#endif
	[self removeChild:actor cleanup:YES];
	actor = nil;
}

- (void) startRun
{
	TRACE(@"[start run]");
	[delegate setBackgroundSpeed:speed/10.0];
	CCAction *action = [CCFollow actionWithTarget:actor];
	action.tag = 111;
	[self runAction:action];
	following = YES;
	[self schedule:@selector(attack) interval:1];
	float length = ([delegate currentLevel] <= [Properties sharedProperties].level) ? LEVEL_DURATION : LEVEL_DURATION/2.0;
	[self schedule:@selector(gotoNextLevel) interval:length];
	shieldCounter = 0;

}

- (void) endRun
{
	TRACE(@"[endrun]");
	//[self unschedule:@selector(updateElements)];
	//[self unschedule:@selector(gotoNextLevel)];
	
	[self unscheduleAllSelectors];
	[self stopAllActions];
	[self removeActor];
	
	firstPath = YES;
	moving = NO;
	active = NO;
	dying = NO;
	[delegate setBackgroundSpeed:0];
	following = NO;
}

- (void) stopFollow
{
	[self unschedule:@selector(attack)];
	[delegate setBackgroundSpeed:0];
	[self stopActionByTag:111];
	[self schedule:@selector(stopRun) interval:3];
}

- (void) stopRun
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUpgrade" object:nil];
	[delegate endGame];
}

////////////////


void drawArrow(CGPoint p1, CGPoint p2, int width, CGPoint *pa, CGPoint *pc)
{	
	float r = atan2( p2.y - p1.y , p2.x - p1.x );
	float bx = p1.x;
	float by = p1.y;
	r += M_PI_2; // perpendicular to path
	float ax = p2.x + cos( r ) * width;
	float ay = p2.y + sin( r ) * width;
	float cx = p2.x - cos( r ) * width;
	float cy = p2.y - sin( r ) * width;
	
	CGPoint vertices[] = { ccp(ax, ay), ccp(bx,by), ccp(cx,cy) };
	
	glLineWidth(1.0f);
	ccDrawPoly( vertices, 3, YES);
	
	*pa = ccp(ax, ay);
	*pc = ccp(cx, cy);
}

void drawPoly(CGPoint p1, CGPoint p2, int width, CGPoint *pa, CGPoint *pc)
{	
	CGPoint a1 = *pa;
	CGPoint c1 = *pc;
	float r = atan2( p2.y - p1.y , p2.x - p1.x );
	float dx = p2.x; //p1.x + cos( r ) * head;
	float dy = p2.y; //p1.y + sin( r ) * head;
	r += M_PI_2; // perpendicular to path
	
	float a2x = dx + cos( r ) * width;
	float a2y = dy + sin( r ) * width;
	float c2x = dx - cos( r ) * width;
	float c2y = dy - sin( r ) * width;
	
	CGPoint vertices[] = { a1, c1, ccp(c2x,c2y), ccp(a2x,a2y) };
	
	glLineWidth(1.0f);
	ccDrawPoly( vertices, 4, YES);
	*pa = ccp(a2x, a2y);
	*pc = ccp(c2x, c2y);
}

////////////////

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	
#if DEBUG_PHYSIC		
	world->DrawDebugData();
#endif
	
	/*
	if(shieldActive == YES)
	{
		glEnable(GL_LINE_SMOOTH);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		
		int count = 0;
		float lineWidth = trailTotal/TRAIL_WIDTH;
		float step = lineWidth / ((trailTotal+1)*1.0);// * TRAIL_WIDTH_RATIO;
		//for (int i = trailTotal-1; i > 0; i--) 
		for (int i = 1; i < trailTotal; i++) 
		{
			int n = i - 1;
			glColor4ub(0,0,0,(int)255*lineAlpha);
			glLineWidth(lineWidth);
			if(n == 0)
			{
				if(trailTotal > 2) {
					drawArrow(trail[n], trail[i], lineWidth, &pa, &pc);
				} else {
					glLineWidth(1.0f);
					ccDrawLine(trail[n], trail[i]);
				}
			}	else {
				drawPoly(trail[n], trail[i], lineWidth, &pa, &pc);
			}
			//lineWidth *= TRAIL_DECREMENT;
			lineWidth -= step;
			if(lineWidth < 1) lineWidth = 1;
			count++;
		}
		
		glDisable(GL_LINE_SMOOTH);
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
		
	 lineAlpha -= SHIELD_ALPHA_STEP;
	 if(lineAlpha <= SHIELD_ALPHA_STOP) {
		 shieldActive = NO;
		 [self removeShield];
	 }
	}
	 */

	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
}

- (void) landed:(b2Fixture *)fixture
{
	
	NSNumber *num = (NSNumber *)fixture->GetUserData();
	
	if(num != nil) {
		float rotation = [num floatValue];
		if(actor.rotate != rotation)
		{
			actor.rotate = rotation;
			[actor stopAllActions];
			[actor runAction:[CCRotateTo actionWithDuration:0.2 angle:rotation]];
			//TRACE(@"angle:%f", rotation);
		}
	}
	
}

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
//			if(myActor.tag != ObjectTypeactor && myActor.tag != ObjectTypeFireball && myActor.tag != ObjectTypeIceball && myActor.tag != ObjectTypeSpitball) {
//				myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
//			}
		}	
	}
	
	/*
	if(moving == YES)
	{
		b2Vec2 velocity = actor.body->GetLinearVelocity();

		if(velocity.x < speed)
		{
			velocity.x += speedStep*2;
		}
		else if(velocity.x > speed)
		{
			velocity.x *= 0.9;
		}

		actor.body->SetLinearVelocity(b2Vec2(velocity.x, velocity.y));		
	}
	*/
		
	/////////////////
	/*
	if(active == YES)
	{		
		if(following == NO)
		{
			if(actor.position.x > winSize.width*0.85 - self.position.x) {
				[self startRun];
			}
		}
		BOOL landed = NO;
		std::vector<MyContact>::iterator pos;
		for(pos = contactListener->_contacts.begin(); pos != contactListener->_contacts.end(); ++pos) 
		{
			MyContact contact = *pos;
			id dataA = (id)contact.fixtureA->GetUserData();
			id dataB = (id)contact.fixtureB->GetUserData();
			
			if([dataA isKindOfClass:[Bullet class]])
			{
				Bullet *bullet = (Bullet *)dataA;
				[bullet explode];
				if([dataB isKindOfClass:[actor class]])	
				{
					[self targetHit:bullet];
				}	
				else if([dataB isKindOfClass:[Path class]])
				{
					if(bullet.points > 0) 
					{
						[bullet blocked];
						[delegate addPoints:bullet.points];
						bullet.points = 0;
					}
				}
				if(bullet.tag != ObjectTypeSpear && bullet.tag != ObjectTypeArrow) {
					bullet.live = NO;	
				}	
			}
			else if([dataB isKindOfClass:[Bullet class]])
			{
				Bullet *bullet = (Bullet *)dataB;
				[bullet explode];
				if([dataA isKindOfClass:[actor class]])	
				{
					[self targetHit:bullet];
				}	
				else if([dataA isKindOfClass:[Path class]])
				{
					if(bullet.points > 0) 
					{
						[bullet blocked];
						[delegate addPoints:bullet.points];
						bullet.points = 0;
					}
				}
				if(bullet.tag != ObjectTypeSpear && bullet.tag != ObjectTypeArrow) {
					bullet.live = NO;	
				}
			}
			
			else if(contact.fixtureA == actor.fixture)
			{
				[self landed:contact.fixtureB];
				landed = YES;
			}
			else if(contact.fixtureB == actor.fixture)
			{
				[self landed:contact.fixtureA];
				landed = YES;
			}
		}
		
	}
	 */
	
}


- (void) updateElements
{		
	/*
	int total = [bullets count];
	for (int i = total - 1; i >= 0; i--) 
	{
		Bullet *bullet = [bullets objectAtIndex:i];
		if(bullet.position.y < 0) {
			[bullet destroy:world];
			[self removeChild:bullet cleanup:YES];
			[bullets removeObjectAtIndex:i];
		}
	}
	*/
	
	//TRACE(@"total bullets, %d", [bullets count]);
		
	if(moving == YES)
	{
		if(dying == YES)
		{
			b2Vec2 velocity = actor.body->GetLinearVelocity();
			speed = speed * 0.7;
			actor.body->SetLinearVelocity(b2Vec2(speed, velocity.y));
			[delegate setBackgroundSpeed:speed/cloudSpeedRatio];
			if(speed < 0.4)
			{
				[delegate endGame];
			}
		}
	}
	
}

- (void) initRun
{
	[self unschedule:@selector(initRun)];
	float offset = (firstRun == YES) ? 1.08 : 1.3;
	newPosition = winSize.width - self.position.x - (winSize.width*offset);
	TRACE(@"[%f, %f, %f]", newPosition, self.position.x, actor.position.x);
	[self showactorAtLocation:newPosition];	
	firstRun = NO;
	timestamp = [startTime timeIntervalSinceNow]; 
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
	
	
	TRACE(@"remove bullets");
		
	if(actor != nil) [self removeActor];

	[self removeAllChildrenWithCleanup:YES];
}

- (void) dealloc 
{	
	TRACE(@"dealloc world");
	
	[self destroy];
	
	delete contactListener;
	contactListener = nil;
	
	delete world;
	world = nil;
	
	[startTime release];
	[bullets release];
	[shieldPaths release];
	[groundAngles release];
	
	[super dealloc];
}

@end
