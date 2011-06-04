//
//  BalloonsAppDelegate.h
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoundEffect;
@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> 
{
	UIWindow *window;
	int alertType;
	RootViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
