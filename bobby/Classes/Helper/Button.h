//
//  Button.h
//  Basket
//
//  Created by Mehayhe on 6/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface Button : CCMenu {
}
+ (id)buttonWithText:(NSString*)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn atPosition:(CGPoint)position target:(id)target selector:(SEL)selector rapid:(BOOL)rapid;
+ (id)buttonWithToggle:(BOOL)toggle offImage:(NSString*)buttonOff onImage:(NSString*)buttonOn atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
@end

@interface ButtonItem : CCMenuItem {
	CCSprite *back;
	CCSprite *backPressed;
	BOOL _selected;
	BOOL toggleMode;
	BOOL rapid;
}

@property (nonatomic, assign) BOOL _selected;
@property (nonatomic, assign) BOOL rapid;

+ (id)buttonWithText:(NSString*)text target:(id)target selector:(SEL)selector;
+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector;
+ (id)buttonWithToggle:(BOOL)toggle offImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector;
- (id)initWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector;
- (id)initWithToggle:(BOOL)toggle offImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector;
@end
