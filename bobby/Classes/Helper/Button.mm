//
//  Button.m
//  Basket
//
//  Created by Mehayhe on 6/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Button.h"


@implementation Button
+ (id)buttonWithText:(NSString*)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector {
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithText:text target:target selector:selector], nil];
	menu.position = position;
	return menu;
}

+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn atPosition:(CGPoint)position target:(id)target selector:(SEL)selector {
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithImage:buttonOff onImage:buttonOn target:target selector:selector], nil];
	menu.position = position;
	return menu;
}

+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn atPosition:(CGPoint)position target:(id)target selector:(SEL)selector rapid:(BOOL)rapid{
	ButtonItem *buttonItem = [ButtonItem buttonWithImage:buttonOff onImage:buttonOn target:target selector:selector];
	buttonItem.rapid = rapid;
	CCMenu *menu = [CCMenu menuWithItems:buttonItem, nil];
	menu.position = position;
	return menu;
}

+ (id)buttonWithToggle:(BOOL)toggle offImage:(NSString*)buttonOff onImage:(NSString*)buttonOn atPosition:(CGPoint)position target:(id)target selector:(SEL)selector {
	CCMenu *menu = [CCMenu menuWithItems:[ButtonItem buttonWithToggle:toggle offImage:buttonOff onImage:buttonOn target:target selector:selector], nil];
	menu.position = position;
	return menu;
}

@end


@implementation ButtonItem

@synthesize _selected, rapid;

+ (id)buttonWithText:(NSString*)text target:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithText:text target:target selector:selector] autorelease];
}

+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithImage:buttonOff onImage:buttonOn target:target selector:selector] autorelease];
}

+ (id)buttonWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector rapid:(BOOL)rapid
{
	return [[[self alloc] initWithImage:buttonOff onImage:buttonOn target:target selector:selector] autorelease];
}

+ (id)buttonWithToggle:(BOOL)toggle offImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithToggle:(BOOL)toggle offImage:buttonOff onImage:buttonOn target:target selector:selector] autorelease];
}

- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector {
	if((self = [super initWithTarget:target selector:selector])) {
		back = [[CCSprite spriteWithFile:@"button.png"] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:@"button_p.png"] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
		
		//CCLabelTTF* textLabel = [CCLabelTTF labelWithString:text fontName:@"take_out_the_garbage" fontSize:22];
		CCLabelBMFont *textLabel = [CCLabelBMFont labelWithString:text fntFile:PROPS(@"ButtonFont")];
		textLabel.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
		textLabel.anchorPoint = ccp(0.5, 0.3);
		[self addChild:textLabel z:1];
	}
	return self;
}
/*
- (id)initWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector {
	return [self initWithImage:buttonOff onImage:buttonOn target:target selector:selector];
		*/
- (id)initWithImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector {
	if((self = [super initWithTarget:target selector:selector])) {
		
		back = [[CCSprite spriteWithFile:buttonOff] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:buttonOn] retain];
		backPressed.anchorPoint = ccp(0,0);
		[self addChild:back];
		
		self.contentSize = back.contentSize;
		/*
		CCSprite* image = [CCSprite spriteWithFile:buttonOn];
		[self addChild:image z:1];
		image.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);*/
	}
	return self;
}

- (id)initWithToggle:(BOOL)toggle offImage:(NSString*)buttonOff onImage:(NSString*)buttonOn target:(id)target selector:(SEL)selector {
	if((self = [super initWithTarget:target selector:selector])) {
		
		back = [[CCSprite spriteWithFile:buttonOff] retain];
		back.anchorPoint = ccp(0,0);
		backPressed = [[CCSprite spriteWithFile:buttonOn] retain];
		backPressed.anchorPoint = ccp(0,0);
		//[self addChild:back];
		//[self addChild:backPressed];
		if(toggle == NO) {
			[self addChild:back];
			//back.visible = YES;
			//backPressed.visible = NO;
		} else {
			//back.visible = NO;
			//backPressed.visible = YES;
			[self addChild:backPressed];
		}
		_selected = toggle;
		toggleMode = YES;
		self.contentSize = back.contentSize;
	}
	return self;
}

-(void) selected {
	if(toggleMode == NO)
	{
		[self removeChild:back cleanup:NO];
		[self addChild:backPressed];
		//back.visible = YES;
		//backPressed.visible = NO;
	}
	else
	{
		if(_selected == YES)
		{
			_selected = NO;
			[self removeChild:backPressed cleanup:NO];
			[self addChild:back];
			//back.visible = YES;
			//backPressed.visible = NO;
		}
		else 
		{
			_selected = YES;
			[self removeChild:back cleanup:NO];
			[self addChild:backPressed];
			//back.visible = NO;
			//backPressed.visible = YES;
		}
	}
	[super selected];
}

-(void) unselected {
	if(toggleMode == NO)
	{
		//TRACE(@"=%@", back);
		[self removeChild:backPressed cleanup:NO];
		if(back.parent == nil) {
			[self addChild:back];
		}
		//back.visible = YES;
		//backPressed.visible = NO;
	}
	[super unselected];
}

// this prevents double taps
- (void)activate {
	[super activate];
	if(rapid == NO)
	{
		[self setIsEnabled:NO];
		[self schedule:@selector(resetButton:) interval:0.1];
	}
}

- (void)resetButton:(ccTime)dt {
	[self unschedule:@selector(resetButton:)];
	[self setIsEnabled:YES];
}

- (void)dealloc {
	[back release];
	[backPressed release];
	[super dealloc];
}

@end