//
//  BalloonsAppDelegate.h
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGKMediaSelector.h"

@class SoundEffect;
@class RootViewController;

@interface AppDelegate : NSObject <AGKMediaSelectorDelegate,UIApplicationDelegate, UIAlertViewDelegate> 
{
	UIWindow *window;
	int alertType;
	RootViewController *viewController;
    AGKMediaSelector *mediaSelector;
}

@property (nonatomic, retain) UIWindow *window;

- (void)showMusicPicker;

@end
