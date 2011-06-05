//
//  RootViewController.h
//  Messenger
//
//  Created by Mehayhe on 1/2/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
//#import <iAd/iAd.h>
#import "GameCenterManager.h"

typedef enum {
	AlertTypeNone,
	AlertTypePaused,
	AlertTypeSubmit,
	AlertTypeRating,
	AlertTypeOther
} AlertType;

@class Popup;
@class PromptController;
@class PauseView;

@interface RootViewController : UIViewController <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate>
{
	GameCenterManager* gameCenterManager;
	Popup *popup;
	PauseView *pauseView;
	int alertMode;
	PromptController *prompt;
	BOOL authenticated;
	BOOL bannerIsVisible;
	//ADBannerView *banner;
}

@property (nonatomic, retain) GameCenterManager *gameCenterManager;

@end
