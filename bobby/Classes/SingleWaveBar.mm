//
//  SingleWaveBar.m
//  bobby
//
//  Created by Omid Mikhchi on 6/4/11.
//

#import "SingleWaveBar.h"

#define lowerBarHeight 60
#define maxHeight 81+60
#define spaceBetweenBar 30
#define leftPadding 50
#define starToBarTopSpacing 4

@implementation SingleWaveBar

@synthesize barSprite = _barSprite;
//@synthesize starSprite = _starSprite;
@synthesize tempWaveDirection;

- (id)initWithColumn:(int)column
{
    self = [super init];
    
    if (self) {
        // used only for demo purposes right now
        tempWaveDirection = 1;
        
        _barSprite = [[CCSprite spriteWithFile:@"meter.png"] retain];
        
        float calculatedXPosition = leftPadding+(column*spaceBetweenBar)+(column*_barSprite.contentSize.width) +(_barSprite.contentSize.width/2);
        
        _barSprite.position = ccp(calculatedXPosition, 0);
        
        [self setBarHeight:0.25];
        
        //_starSprite = [[CCSprite spriteWithFile:@"star.png"] retain];
        
    }
    
    return self;
}

- (id)init
{
    return [self initWithColumn:0];
}

/*
- (SoundStar *)dropStar
{
    
}
*/

- (float)getBarHeight
{
    return _height;
}

- (void)setBarHeight:(float)height
{    
    _height = height;
    
    float difference = (_barSprite.contentSize.height/2)+lowerBarHeight + 21;
    
    _barSprite.position = ccp(_barSprite.position.x, difference*height-21);
    
    //_starSprite.position = ccp(_barSprite.position.x, _barSprite.position.y+_barSprite.contentSize.height/2+starToBarTopSpacing+_starSprite.contentSize.height/2);
}

@end
