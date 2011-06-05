//
//  SingleWaveBar.h
//  bobby
//
//  Created by Omid Mikhchi on 6/4/11.
//  Copyright 2011 Style Page Inc. All rights reserved.
//

#import "cocos2d.h"


@interface SingleWaveBar : CCNode {
    CCSprite *_barSprite;
    CCSprite *_starSprite;
    float _height;
    int tempWaveDirection;
}

@property (nonatomic, retain) CCSprite *barSprite;
@property (nonatomic, retain) CCSprite *starSprite;
@property (nonatomic, readwrite) int tempWaveDirection;

- (id)initWithColumn:(int)column;

- (void)setBarHeight:(float)height;

@end
