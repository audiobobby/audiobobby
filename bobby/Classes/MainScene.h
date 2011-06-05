//
//  IntroScene.h
//  Unicorn
//
//  Created by Mehayhe on 10/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"
#import "cocos2d.h"

@interface MainScene : CCLayer<GKLeaderboardViewControllerDelegate>
{
	
	UIViewController	*modalWrapper_;
}

+ (id) scene;

@end
