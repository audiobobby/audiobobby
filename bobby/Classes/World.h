//
//  SkyView.h
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundStar.h"

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

#define MAX_SHOT 1000
#define TOTAL_WEAPONS 6
#define TRAIL_TOTAL 10

@class Actor;
@class SoundEffect;
@class Path;

@interface World : CCLayer <GameDelegate>
{
    NSMutableArray *bars;
	//SoundStar *star;
    
    NSMutableArray *stars;
    
	NSMutableArray *bullets;
	NSMutableArray *shieldPaths;
	NSMutableArray *groundAngles;
	
	b2World *world;

	
	GLESDebugDraw *m_debugDraw;
	int counter;
	id <GameDelegate> delegate;

	Actor *actor;
	CGSize winSize;
	float speed;

	float elementVelocity;
	float jumpImpulse;
	float cloudSpeedRatio;
		
	MyContactListener *contactListener;
	BOOL firstPath;
	BOOL moving;
	BOOL active;
	BOOL terminating;
	BOOL started;
	BOOL dying;
	
	b2Fixture *groundFixture, *wallFixture;;
	BOOL destroyed;

	float gravityRatio;
	
	BOOL firstRun;
	float timestamp;
	NSDate *startTime;
	Path *groundNode;
}

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) Actor *actor;

- (void) initRun;
- (void) endRun;
- (void) destroy;

@end
