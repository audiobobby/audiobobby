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

@interface Tips : CCLayer {
	id <GameDelegate> delegate;
	CCSprite *back;
}

@property (nonatomic, assign) id <GameDelegate> delegate;

- (void) hide;

@end
