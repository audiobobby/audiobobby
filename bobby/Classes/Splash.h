//
//  Splash.h
//  Unicorn
//
//  Created by Mehayhe on 10/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
	SplashViewTitle,
	SplashViewMenu,
	SplashViewOther
} SplashView;

@class Button;

@interface Splash : CCLayer {
	CCSprite *back;
	CCSprite *title;
	Button *menuButton;
	CCLabelBMFont *menuLabel;
	id <GameDelegate> delegate;
	int view;
	CGSize winSize;
	CCMenu *menu;
	float bottomLine;
}

@property (nonatomic, assign) id <GameDelegate> delegate;


- (void) hide;
- (void) showTitle;
- (void) showMenu;
- (void) showScore:(int)score;
- (void) showUpgrade;

@end
