//
//  Path.m
//  Unicorn
//
//  Created by Mehayhe on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundStar.h"

@implementation SoundStar

@synthesize fixture, body;
@synthesize delegate;

-(id) init
{
	if( (self=[super init])) 
	{	
		self.tag = ObjectTypeStar;
		_sprite = [CCSprite spriteWithFile:@"star.png"];
		[self addChild:_sprite];
	}
	return self;
}

- (void) addToWorld:(b2World *)world location:(CGPoint)pos
{
	self.position = pos;

	TRACE(@"soundstar: %f, %f", pos.x, pos.y);
	
    b2BodyDef bodyDef;
	
    bodyDef.type = b2_dynamicBody;
	
    bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	
	bodyDef.userData = self;
    
	self.body = world->CreateBody(&bodyDef);
	
	b2PolygonShape shape;
	shape.SetAsBox(_sprite.contentSize.width*0.5/PTM_RATIO, _sprite.contentSize.height*0.5/PTM_RATIO);

	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
    fixtureDef.filter.groupIndex = 3;
	fixtureDef.filter.categoryBits = SOUNDSTAR_BIT;
	fixtureDef.filter.maskBits = GROUND_BIT^ACTOR_BIT;
    fixtureDef.userData = self;
	self.fixture = self.body->CreateFixture(&fixtureDef);
}

- (void) destroy:(b2World *)world
{
	//TRACE(@"destroy path");
	world->DestroyBody(body);
	body = nil;
	fixture = nil;
}

- (void) update:(ccTime)dt
{
    NSLog(@"OMID!");
}

- (void) dealloc
{
	//TRACE(@"dealloc path omid");
	[super dealloc];
}

@end
