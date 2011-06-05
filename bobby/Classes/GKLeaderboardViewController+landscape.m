//
//  GKLeaderboardViewController+Landscape.m
//  RainbowBlocks
//
//  Created by Nick Lockwood on 05/10/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//

#import "GKLeaderboardViewController+Landscape.h"


@implementation GKLeaderboardViewController(Landscape)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end