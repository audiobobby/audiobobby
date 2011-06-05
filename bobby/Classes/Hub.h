//
//  Hub.h
//  Balloons
//
//  Created by Mehayhe on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define TOTAL_INSTANCES 10

@class Button;
@class Actor;
//@class ControlArea;

typedef struct {
	UITouch *touch;
	int mode;
	BOOL active; 
	CGPoint location;
} TouchInstance;

@interface Hub : CCLayer {
	id <GameDelegate> delegate;
	id <GameDelegate> worldDelegate;
	TouchInstance touchInstance[TOTAL_INSTANCES];
	CCLabelBMFont *scoreLabel;
	CCLabelBMFont *infoLabel;
	NSNumberFormatter *numFormatter;
	NSMutableArray *lifeArray;
	Button *pauseButton;
	CCSprite *leftBtn, *rightBtn, *jumpBtn;
	int lives;
	CGPoint e1, e2;
	float lifeMaxWidth, lifeWidth;
	float step;
	Actor *actor;
	int lastAction;
	//ControlArea *controlArea;
	UITouch *touchLeft, *touchRight, *touchUp;
	
}

@property (nonatomic, assign) id <GameDelegate> delegate;
@property (nonatomic, assign) id <GameDelegate> worldDelegate;

- (void) setScore:(int)val;
- (void) setLevel:(int)val;
- (void) setInfo:(NSString *)info;
- (void) setLife:(int)val;
- (void) reset;
- (void) hide;
- (void) show;

@end
