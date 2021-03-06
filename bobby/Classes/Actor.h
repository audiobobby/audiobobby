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


typedef enum {
	AnimationRunning,
	AnimationJumping,
	AnimationFalling,
	AnimationIdle
} Animation;

typedef enum {
	MoveActionIdle,
	MoveActionLeft,
	MoveActionRight,
	MoveActionJump
} MoveAction;

@interface Actor : CCNode <GameDelegate>
{
	CCSprite *sprite;
	int num;
	CGRect frame;
	id <GameDelegate> delegate;
	NSMutableArray *allFrames, *animationFrames;
	int aFrame;
	int mode;
	BOOL justLanded;
	float radius;
	float rotate;
	float speed;
	b2Fixture *fixture;
	b2Body *body;
	int lastAction;
	int jumpCount;
	BOOL grounded;
	int totalFrames;
}

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) int aFrame;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float rotate;
@property (nonatomic, assign) b2Fixture *fixture;
@property (nonatomic, assign) b2Body *body;
@property (nonatomic, assign) int mode;
@property (nonatomic, assign) BOOL grounded;

- (void) addToWorld:(b2World *)world location:(CGPoint)pos;

@end
