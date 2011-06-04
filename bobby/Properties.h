//
//  Settings.h
//  TopMovies
//
//  Created by Mehayhe on 2/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//
#import <Foundation/Foundation.h>


#if TARGET_IPHONE_SIMULATOR
	#define DEBUG_MODE 1
	#define APP_SERVER @"http://localhost:8083"
	#define FLURRY 0
#else
#define DEBUG_MODE 0
#define APP_SERVER @"http://localhost:8083"
	#define FLURRY 0
#endif

#define API_FORMAT @"%@/%@/%@?%@"
#define WEB_SERVICES @"bobby"

#if !defined(DEBUG_MODE) || DEBUG_MODE == 0
#define TRACE(...) do {} while (0)
#else
#define TRACE(...) NSLog(__VA_ARGS__)
#endif

#define OPEN_CLOSE_DURATION 0.5
#define MAX_LIVES 5

#define PTM_RATIO 32

#define PNG(file) (([[Properties sharedProperties] isIPad]) ? [NSString stringWithFormat:@"%@-ipad.png", file] : [NSString stringWithFormat:@"%@.png", file])
#define TMX(file) (([[Properties sharedProperties] isIPad]) ? [NSString stringWithFormat:@"%@-ipad.tmx", file] : [NSString stringWithFormat:@"%@.tmx", file])
#define XIB(file) (([[Properties sharedProperties] isIPad]) ? [NSString stringWithFormat:@"%@-ipad", file] : file)

#define HD_PNG(file) (([[Properties sharedProperties] isIPad]) ? [NSString stringWithFormat:@"%@-hd.png", file] : [NSString stringWithFormat:@"%@.png", file])
#define HD_TMX(file) (([[Properties sharedProperties] isLowResIPhone]) ? [NSString stringWithFormat:@"%@_low.tmx", file] : [NSString stringWithFormat:@"%@_hd.tmx", file])

#define PROP(name) [[[Properties sharedProperties] getPropForKey:name] intValue]
#define PROPF(name) [[[Properties sharedProperties] getPropForKey:name] floatValue]
#define PROPS(name) [[Properties sharedProperties] getPropForKey:name]

#define ACTOR_BIT 0x0001
#define GROUND_BIT 0x0002
#define BULLET_BIT 0x0004
#define HITAREA_BIT 0x0005
#define PATH_BIT 0x0010

typedef enum {
	FontTypeDefault,
	FontTypeScore
} FontType;

typedef enum {
	OperationSplashHidden,
	OperationHubHidden,
	OperationRemoveTips
} Operation;

typedef enum {
	MessageTypeStartInstructions,
	MessageTypeSteepPath,
	MessageTypeTryAgain
} MessageType;

typedef enum {
	ObjectTypePlatform,
	ObjectTypeUnicorn,
	ObjectTypeArrow,
	ObjectTypeCannonball,
	ObjectTypeFireball,
	ObjectTypePellet,
	ObjectTypeSpear,
	ObjectTypeIceball,
	ObjectTypeSpitball,
	ObjectTypeInactive,
	ObjectTypeRemoving,
} ObjectType;


typedef enum {
	ModeRunning,
	ModeJumping,
	ModePrelanding,
	ModeLanding,
	ModeFalling,
	ModeIdle
} Mode;

@interface Properties : NSObject 
{
	BOOL tilt;
	int totalScore;
	int highScore;
	int averageScore;
	int lastScore;
	int totalGames;
	int percentage;
	int totalSessions;
	int counter;
	BOOL hint;
	BOOL audio;
	BOOL music;
	BOOL submit;
	BOOL newHigh;
	BOOL prompted;
	BOOL ratingPrompted;
	BOOL gamecenter;
	BOOL tips;
	BOOL resetLevel;
	NSString *username;
	float scale;
	float effectVolume;
	float musicVolume;
	NSDictionary *coordinateDict;
	NSArray *songList;
	BOOL paused;
	int level;
	BOOL ready;
}

@property (nonatomic, assign) int totalSessions;
@property (nonatomic, assign) int totalScore;
@property (nonatomic, assign) int highScore;
@property (nonatomic, assign) int lastScore;
@property (nonatomic, assign) int averageScore;
@property (nonatomic, assign) int totalGames;
@property (nonatomic, assign) int percentage;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int counter;
@property (nonatomic, assign) BOOL resetLevel;
@property (nonatomic, assign) BOOL tips;
@property (nonatomic, assign) BOOL audio;
@property (nonatomic, assign) BOOL music;
@property (nonatomic, assign) BOOL submit;
@property (nonatomic, assign) BOOL newHigh;
@property (nonatomic, assign) BOOL prompted;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL ratingPrompted;
@property (nonatomic, assign) BOOL gamecenter;
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) float musicVolume;
@property (nonatomic, assign) float effectVolume;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, assign) float scale;
@property (nonatomic, retain) NSDictionary *coordinateDict;
@property (nonatomic, retain) NSArray *songList;

+ (Properties *) sharedProperties;

- (void) save;
- (void) load;
- (BOOL) isLowRes;
- (BOOL) isLowResIPhone;
- (int) getOffset:(NSString *)key;
- (CGPoint) getNewPopupLocation;
- (BOOL) isIPad;
- (BOOL) isHighRes;
- (NSString *) getPropForKey:(NSString *)key;
- (NSString *) formattedScore:(int)score;
- (NSString *) fontNameForType:(int)type;
@end


@protocol GameDelegate 
@optional
- (void) endGame;
- (void) pauseGame;
- (void) onDone;
- (void) showInfo:(NSString *)info;
- (void) setBackgroundSpeed:(float)val;
- (void) startGame;
- (void) restartGame;
- (void) showTips;
- (int) hit;
- (int) currentLevel;
- (int) nextLevel;
- (void) operationCompleted:(int)operation;
- (void) hideMessage;
- (void) addPoints:(int)points;
- (void) showMessage:(NSString *)mesg offset:(int)offset;
@end

