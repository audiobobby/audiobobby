//
//  Balloon.h
//  Balloons
//
//  Created by Mehayhe on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface Actor : CCNode 
{
	CCSprite *sprite;
	int num;
	CGRect frame;
	id <GameDelegate> delegate;
	NSMutableArray *runningFrames;
	NSMutableArray *jumpingFrames;
	NSMutableArray *landingFrames;
	NSMutableArray *fallingFrames;
	int aFrame;
	int mode;
	BOOL justLanded;
	float radius;
	float rotate;
	b2Fixture *fixture;
	b2Body *body;
}

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) int aFrame;
@property (nonatomic, assign) BOOL justLanded;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float rotate;
@property (nonatomic, assign) b2Fixture *fixture;
@property (nonatomic, assign) b2Body *body;

- (void) setMode:(int)val;
- (int) getMode;

@end
