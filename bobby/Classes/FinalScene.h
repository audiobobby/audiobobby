//
//  FinalScene.h
//  bobby
//
//  Created by Jonathan Dalrymple on 04/06/2011.
//  Copyright 2011 Float:Right Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface FinalScene : CCLayer <GKLeaderboardViewControllerDelegate> {
		
	UIViewController *modalWrapper_;
}

+ (id) scene;

@end
