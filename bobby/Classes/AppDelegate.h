//
//  BalloonsAppDelegate.h
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGKMediaSelector.h"
#import "AGKMediaSession.h"

@class SoundEffect;
@class RootViewController;

@interface AppDelegate : NSObject <AGKMediaSelectorDelegate,UIApplicationDelegate, UIAlertViewDelegate> 
{
	UIWindow *window;
	int alertType;
	RootViewController *viewController;
    AGKMediaSelector *mediaSelector;
	AGKMediaSession *session;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) AGKMediaSession *session;

- (void)showMusicPicker;
@end
