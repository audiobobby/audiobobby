//
//  SkyView.h
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

#define MAX_SHOT 1000
#define TOTAL_WEAPONS 6
#define TRAIL_TOTAL 10

@class Actor;
@class SoundEffect;

@interface World : CCLayer <GameDelegate>
{
	NSMutableArray *bullets;
	NSMutableArray *shieldPaths;
	NSMutableArray *groundAngles;
	
	b2World *world;

	int groundBodyIndex;
	int groundCounter;
	float groundWidth;
	
	
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
	
	float speedStep;
	BOOL galloping;
	uint gallopId;
	BOOL destroyed;
	float newPosition;

	float gravityRatio;
	BOOL shieldActive;
	int trailTotal;
	CGPoint trail[TRAIL_TOTAL];
	CGPoint pa, pc;
	float lineWidthRatio;
	float lineAlpha;
	
	int shotTable[MAX_SHOT];
	int totalShots;
	int currentShot;
	float delayOffset;
	int concurrent;
	BOOL reshuffle;
	BOOL following;
	BOOL firstRun;
	int shieldCounter, shieldCounterMax;
	float shieldDiff;
	float timestamp;
	NSDate *startTime;
}

@property (nonatomic, assign) id <GameDelegate> delegate;
//@property (nonatomic, assign) float speed;

- (void) initRun;
- (void) endRun;
- (void) stopFollow;
- (void) destroy;

@end
