//
//  Path.h
//  Unicorn
//
//  Created by Mehayhe on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface SoundStar : CCNode 
{
    CCSprite *_sprite;
    
	b2Fixture *fixture;
	b2Body *body;
	id <GameDelegate> delegate;
    BOOL didHitActor;
}
@property (nonatomic, retain) CCSprite *sprite;

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) b2Fixture *fixture;
@property (nonatomic, assign) b2Body *body;

@property (nonatomic, readwrite) BOOL didHitActor;

- (void) addToWorld:(b2World *)world location:(CGPoint)pos;
- (void) destroy;

@end
