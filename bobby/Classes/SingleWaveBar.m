//
//  SingleWaveBar.m
//  bobby
//
//  Created by Omid Mikhchi on 6/4/11.
//  Copyright 2011 Style Page Inc. All rights reserved.
//

#import "SingleWaveBar.h"

#define lowerBarHeight 60
#define maxHeight 81+60
#define spaceBetweenBar 30
#define leftPadding 50
#define starToBarTopSpacing 4

@implementation SingleWaveBar

@synthesize barSprite = _barSprite;
@synthesize starSprite = _starSprite;
@synthesize tempWaveDirection;

- (id)initWithColumn:(int)column
{
    self = [super init];
    
    if (self) {
        tempWaveDirection = 1;
        
        _barSprite = [[CCSprite spriteWithFile:@"meter.png"] retain];
        
        float calculatedXPosition = leftPadding+(column*spaceBetweenBar)+(column*_barSprite.contentSize.width) +(_barSprite.contentSize.width/2);
        
        NSLog(@"calculatedXPosition %f", calculatedXPosition);
        
        //_barSprite.position = ccp(calculatedXPosition, (_barSprite.contentSize.height/2)+60);
        _barSprite.position = ccp(calculatedXPosition, 0);
        
        NSLog(@"bar location x:%f y:%f", _barSprite.position.x, _barSprite.position.y);
        
        [self setBarHeight:0.250];
        
        _starSprite = [[CCSprite spriteWithFile:@"star.png"] retain];
        
        //_starSprite.position = ccp(_barSprite.position.x, _barSprite.position.y+_barSprite.contentSize.height/2+starToBarTopSpacing+_starSprite.contentSize.height/2);
    }
    
    return self;
}

- (id)init
{
    return [self initWithColumn:0];
}

- (void)setBarHeight:(float)height
{    
    
    
    float difference = (_barSprite.contentSize.height/2)+lowerBarHeight + 21;
    
    NSLog(@"new y:%f from height:%f ", difference*height-21, height);
    
    _barSprite.position = ccp(_barSprite.position.x, difference*height-21);
    
    _starSprite.position = ccp(_barSprite.position.x, _barSprite.position.y+_barSprite.contentSize.height/2+starToBarTopSpacing+_starSprite.contentSize.height/2);
    
    NSLog(@"new bar location x:%f y:%f", _barSprite.position.x, _barSprite.position.y);
}

@end
