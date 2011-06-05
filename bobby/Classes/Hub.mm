//
//  Hub.m
//  Balloons
//
//  Created by Mehayhe on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Hub.h"
#import "Button.h"
#import "Actor.h"

#define HILITE_ALPHA 125;

@implementation Hub

@synthesize delegate, worldDelegate;


-(id) init
{
	if( (self=[super init])) 
	{	
		TRACE(@"init hub");
		self.isTouchEnabled = YES;
		self.anchorPoint = ccp(0, 0);
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		numFormatter = [[NSNumberFormatter alloc] init];
		[numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];	
				
		//lifeArray = [[NSMutableArray alloc] initWithCapacity:MAX_LIVES];
		
		int padding = ([[Properties sharedProperties] isIPad]) ? 60 : 30;
		int buttonWidth = 40;
		int xpad = winSize.width * 0.15;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onActorCreated:) name:@"ActorCreated" object:nil];
		
//#if defined(MULTI_LIVES)
//		int x = hubTopPadding;
//		for (int i = 0; i < MAX_LIVES; i++) 
//		{
//			CCSprite *heart = [CCSprite spriteWithFile:@"heart.png"];
//			heart.position = ccp(x, winSize.height - hubTopPadding);
//			[self addChild:heart];
//			[lifeArray addObject:heart];
//			x += heart.contentSize.width * 1.2;
//		}
//#else
//		e1 = ccp(hubTopPadding*0.75, winSize.height - hubTopPadding*0.75);
//		e2 = ccp(e1.x + winSize.width / 5.0, e1.y - hubTopPadding*0.5);
//		lifeMaxWidth = e2.x - e1.x;
//		lifeWidth = lifeMaxWidth;
//		step = ([[Properties sharedProperties] isHighRes]) ? 2.0 : 1.0;
//#endif
		
		scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:[[Properties sharedProperties] fontNameForType:FontTypeScore]];
		scoreLabel.anchorPoint = ccp(0, 0.5);
		scoreLabel.position = ccp(padding, winSize.height - padding);
		[self addChild:scoreLabel];
				
		CGPoint location = ccp(winSize.width - padding, winSize.height - padding);
		pauseButton = [Button buttonWithImage:PNG(@"btnPause") onImage:PNG(@"btnPause") atPosition:location target:self selector:@selector(onPause:)];
		pauseButton.anchorPoint = ccp(0, 0);
		[self addChild:pauseButton];
		
//		leftBtn = [Button buttonWithImage:PNG(@"btn_Left") onImage:PNG(@"btn_LeftHit") 
//													 atPosition:ccp(int(xpad + padding), padding) target:self selector:@selector(moveLeft:) rapid:YES];
//		[self addChild:leftBtn];
//
//		rightBtn = [Button buttonWithImage:PNG(@"btn_Right") onImage:PNG(@"btn_RightHit") 
//														atPosition:ccp((int)(xpad + padding + buttonWidth*2), padding) target:self selector:@selector(moveRight:) rapid:YES];
//		[self addChild:rightBtn];
//		
//		jumpBtn = [Button buttonWithImage:PNG(@"btn_Up") onImage:PNG(@"btn_UpHit") 
//													 atPosition:ccp((int)winSize.width-padding - xpad, padding) target:self selector:@selector(moveUp:) rapid:YES];
//		[self addChild:jumpBtn];
		
		leftBtn = [CCSprite spriteWithFile:PNG(@"btn_Left")];
		leftBtn.position = ccp(int(xpad + padding), padding);
		[self addChild:leftBtn];
		
		rightBtn = [CCSprite spriteWithFile:PNG(@"btn_Right")];
		rightBtn.position = ccp((int)(xpad + padding + buttonWidth*2), padding);
		[self addChild:rightBtn];
		
		jumpBtn = [CCSprite spriteWithFile:PNG(@"btn_Up")];
		jumpBtn.position = ccp((int)winSize.width-padding - xpad, padding);
		[self addChild:jumpBtn];
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

		//controlArea = [ControlArea node];
		//[self addChild:controlArea];
		
		//self.position = ccp(0, winSize.height + winSize.height/10.0);
	}
	return self;
}

- (void) onActorCreated:(NSNotification *)notif
{
	actor = [notif object];
}

- (void) moveLeft:(Button *)button
{
	//[actor move:MoveActionLeft];
}

- (void) moveRight:(Button *)button
{
	//[actor move:MoveActionRight];
}

- (void) moveUp:(Button *)button
{
	//[actor move:MoveActionJump];
}

- (void) show 
{
	self.visible = YES;
	id action1 = [CCMoveTo actionWithDuration: 1 position:ccp(0, 0)];
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(showCompleted:)]; 
	id seq = [CCSequence actions:[CCEaseOut actionWithAction:action1 rate:2], action2, nil];
	//id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];	
	
	[self schedule:@selector(updateBar) interval:1/30.0];
}

- (void) hide
{
	id action1 = [CCMoveTo actionWithDuration: 0.5 position:ccp(0, [CCDirector sharedDirector].winSize.height + [CCDirector sharedDirector].winSize.height/10.0)]; 
	id action2 = [CCCallFuncN actionWithTarget:self selector:@selector(hideCompleted:)]; 
	id seq = [CCSequence actions:[CCEaseIn actionWithAction:action1 rate:2], action2, nil];
	//id seq = [CCSequence actions:action1, action2, nil];
	[self runAction:seq];	
	[self unschedule:@selector(updateBar)];
}


- (void) showCompleted:(id)node
{

}

- (void) hideCompleted:(id)node
{
	self.visible = YES;	
}

- (void) reset
{
	lifeWidth = lifeMaxWidth;
	lives = MAX_LIVES;
}

/*
- (void) updateBar
{
	float width = (lifeMaxWidth * (lives/(float)MAX_LIVES)); 
	
	if(width < lifeWidth) {
		lifeWidth = lifeWidth - step;
		//TRACE(@"%f, %f", width, lifeWidth);
		if(width > lifeWidth) lifeWidth = width;
		//TRACE(@"==%f, %f", width, lifeWidth);
	} else if(width > lifeWidth) {
		lifeWidth = lifeWidth + step;
		if(width < lifeWidth) lifeWidth = width;
	} 
}

- (void) drawRectP1:(CGPoint)p1 p2:(CGPoint)p2 close:(BOOL)close
{
	CGPoint vert[] = { ccp(p1.x, p1.y), ccp(p2.x, p1.y), ccp(p2.x, p2.y), ccp(p1.x, p2.y) };
	ccDrawPoly(vert, 4, close);
}
	
-(void) draw
{
	glEnable(GL_LINE_SMOOTH);
	glDisableClientState(GL_COLOR_ARRAY);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glColor4ub(0, 0, 0, 100);
	glLineWidth(1);
	[self drawRectP1:e1 p2:e2 close:YES];
	
	glColor4ub(255, 0, 0, 255);
	[self drawRectP1:e1 p2:ccp(e1.x + lifeWidth, e2.y) close:YES];
	
	glColor4ub(255, 255, 255, 255);
	glLineWidth(2);
	[self drawRectP1:e1 p2:e2 close:NO];
	ccDrawLine(ccp(e1.x, e1.y), ccp(e1.x, e2.y));
											 
	glDisable(GL_LINE_SMOOTH);
	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	glEnableClientState(GL_COLOR_ARRAY);
}
*/

- (void) onPause:(ButtonItem *)button
{
	[delegate pauseGame];
}

- (void) setScore:(int)val
{
	[scoreLabel setString:[numFormatter stringForObjectValue: [NSNumber numberWithInt:val]]];
}

- (void) setLevel:(int)val
{
	[scoreLabel setString:[numFormatter stringForObjectValue: [NSNumber numberWithInt:val]]];
}

- (void) setLife:(int)val
{
	TRACE(@"set life:%d", val);
	lives = val;
	//lifeWidth = (lifeMaxWidth * (lives/(float)MAX_LIVES)); 
	/*
	for(int i = 0; i < MAX_LIVES; i++)
	{
		CCSprite *heart = [lifeArray objectAtIndex:i];
		[heart setOpacity:(val >= i+1) ? 255 : 70];
	}*/
}

- (void) setInfo:(NSString *)info
{
	//[infoLabel setString:info];
}

-(int) getTouchIdByPoint:(CGPoint) location
{
	int n = -1;
	for(int i = 0; i < TOTAL_INSTANCES; i++)
	{
		if(touchInstance[i].active == NO) continue;
		if(CGPointEqualToPoint(location, touchInstance[i].location) == 1)
		{
			n = i;
			break;
		}
	}
	return n;
}

-(int) getAvailableTouchInstances
{
	int n = -1;
	for(int i = 0; i < TOTAL_INSTANCES; i++)
	{
		if(touchInstance[i].active == NO) {
			n = i;
			break;
		}
	}
	if(n == -1) {
		TRACE(@"random");
			n = arc4random() % TOTAL_INSTANCES;
	}
	return n;
}

- (void) disableTouchInstanceWithId:(int)i
{
	touchInstance[i].active = NO;
	switch (touchInstance[i].mode) {
		case MoveActionLeft:
			[actor move:MoveActionIdle];
			leftBtn.opacity = 255;
			touchLeft = nil;
			break;
			
		case MoveActionRight:
			[actor move:MoveActionIdle];
			rightBtn.opacity = 255;
			touchRight = nil;
			break;
			
		case MoveActionJump:
			[actor move:MoveActionIdle];
			jumpBtn.opacity = 255;
			touchUp = nil;
			break;	
	}
}

- (int) checkTouch:(UITouch *)touch location:(CGPoint)location
{
	int mode = MoveActionIdle;
	if(location.y <= 60)
	{
		if(location.x > 55 && location.x <= 144) {
			if(touch != touchLeft) {
				touchLeft = touch;
				leftBtn.opacity = HILITE_ALPHA;
				[actor move:MoveActionLeft];
			}
			mode = MoveActionLeft;
		}
		else if(location.x > 144 && location.x <= 233) {
			if(touch != touchRight) {
				touchRight = touch;
				rightBtn.opacity = HILITE_ALPHA;
				[actor move:MoveActionRight];
			}
			mode = MoveActionRight;
		}
		else if(location.x > 328 && location.x <= 430) {
			if(touch != touchUp) {
				touchUp = touch;
				jumpBtn.opacity = HILITE_ALPHA;
				[actor move:MoveActionJump];
			}
			mode = MoveActionJump;
		}
	}
	return mode;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
	TRACE(@"location: %f, %f", location.x, location.y);

	//int i = [self getAvailableTouchInstances];
//	int mode = [self checkTouch:touch location:location];
//	TRACE(@"mode: %d", mode);
//	if(mode != 0)
//	{
//		touchInstance[i].touch = touch;
//		touchInstance[i].active = YES;
//		touchInstance[i].mode = mode;
//		touchInstance[i].location = location;
//		return YES;
//	}

	if(location.y <= 60)
	{
		if(location.x > 55 && location.x <= 144) {
			if(touch != touchLeft) {
				touchLeft = touch;
				leftBtn.opacity = HILITE_ALPHA;
				[actor move:MoveActionLeft];
			}
			//mode = MoveActionLeft;
		}
		else if(location.x > 144 && location.x <= 233) {
			if(touch != touchRight) {
				touchRight = touch;
				rightBtn.opacity = HILITE_ALPHA;
				[actor move:MoveActionRight];
			}
			//mode = MoveActionRight;
		}
		else if(location.x > 328 && location.x <= 430) {
			if(touch != touchUp) {
				touchUp = touch;
				jumpBtn.opacity = HILITE_ALPHA;
				[actor move:MoveActionJump];
			}
			//mode = MoveActionJump;
		}
	}
	
	return YES;
}
//
//- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	CGPoint location = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
//	CGPoint oldLocation = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
//	TRACE(@"location: %f, %f", location.x, location.y);
//	int i = [self getTouchIdByPoint:oldLocation];
//	if(i != -1)
//	{
//		int mode = [self checkTouch:touch location:location];
//		TRACE(@"mode: %d", mode);
//
//		
//		if(mode != 0) 
//		{
//			if(touchInstance[i].mode != mode)
//			{
//				[self disableTouchInstanceWithId:i];
//				touchInstance[i].touch = touch;
//				touchInstance[i].active = YES;
//				touchInstance[i].mode = [self checkTouch:touch location:location];
//			}
//			touchInstance[i].location = location;	
//		}
//		else
//		{
//			[self disableTouchInstanceWithId:i];
//		}
//	}
//}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
	CGPoint oldLocation = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
//	int i = [self getTouchIdByPoint:oldLocation];
//	if(i != -1)
//	{
//		[self disableTouchInstanceWithId:i];
//	}
	
	if(touch == touchLeft)
	{
		[actor move:MoveActionIdle];
		leftBtn.opacity = 255;
		touchLeft = nil;
	}
	else if(touch == touchRight)
	{
		[actor move:MoveActionIdle];
		rightBtn.opacity = 255;
		touchRight = nil;
	}
	else if(touch == touchUp)
	{
		[actor move:MoveActionIdle];
		jumpBtn.opacity = 255;
		touchUp = nil;
	}
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}


- (void) dealloc
{
	TRACE(@"dealloc hub");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
//	for(CCSprite *sprite in lifeArray)
//	{
//		[self removeChild:sprite cleanup:YES];
//	}
	[self removeAllChildrenWithCleanup:YES];
	[numFormatter release];
	//[lifeArray release];
	[super dealloc];
}

@end
