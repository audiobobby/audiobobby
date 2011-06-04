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

@interface Path : CCNode 
{
	b2Fixture *fixture;
	b2Body *body;
	id <GameDelegate> delegate;
}

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) b2Fixture *fixture;
@property (nonatomic, assign) b2Body *body;

- (void) destroy:(b2World *)world;

@end
