//
//  Path.m
//  Unicorn
//
//  Created by Mehayhe on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Path.h"

@implementation Path

@synthesize fixture, body;
@synthesize delegate;

-(id) init
{
	if( (self=[super init])) 
	{	
		
	}
	return self;
}


- (void) destroy:(b2World *)world
{
	//TRACE(@"destroy path");
	world->DestroyBody(body);
	body = nil;
	fixture = nil;
}

- (void) dealloc
{
	//TRACE(@"dealloc path");
	[super dealloc];
}

@end
