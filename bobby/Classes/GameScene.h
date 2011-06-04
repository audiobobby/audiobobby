//
//  GameScene.h
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class World;
@class Hub;
@class Splash;
@class Tips;

@interface GameScene : CCLayer <GameDelegate>
{
	World *world;
	Hub *hub;
	Splash *splash;
	Tips *tips;
	BOOL terminating;
	float speedOffset;
	float elapsed;
	float cloudSpeed;
	int totalShots;
	int totalMade;
	int score;
	int scoreIncremental;
	int lives;
	int level;
	BOOL started;
	NSMutableArray *backElements;
	BOOL exiting;
	BOOL upgradeVisible;
}

+(id) scene;


@end
