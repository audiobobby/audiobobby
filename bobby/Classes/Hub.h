//
//  Hub.h
//  Balloons
//
//  Created by Mehayhe on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Button;
@class Actor;

@interface Hub : CCLayer {
	id <GameDelegate> delegate;
	id <GameDelegate> worldDelegate;
	CCLabelBMFont *scoreLabel;
	CCLabelBMFont *infoLabel;
	NSNumberFormatter *numFormatter;
	NSMutableArray *lifeArray;
	Button *pauseButton, *leftBtn, *rightBtn, *jumpBtn;
	int lives;
	CGPoint e1, e2;
	float lifeMaxWidth, lifeWidth;
	float step;
	Actor *actor;
	int lastAction;
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
