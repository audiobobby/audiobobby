//
//  SingleWaveBar.h
//  bobby
//
//  Created by Omid Mikhchi on 6/4/11.
//

#import "cocos2d.h"
#import "SoundStar.h"

@interface SingleWaveBar : CCNode {
    CCSprite *_barSprite;
    
    //CCSprite *_starSprite;
    SoundStar *_soundStar;
    
    float _height;
    int tempWaveDirection;
}

@property (nonatomic, retain) CCSprite *barSprite;
//@property (nonatomic, retain) SoundStar *soundStar;
//@property (nonatomic, retain) CCSprite *starSprite;
@property (nonatomic, readwrite) int tempWaveDirection;

- (id)initWithColumn:(int)column;

- (void)setBarHeight:(float)height;
- (float)getBarHeight;

//- (SoundStar *)dropStar;

@end
