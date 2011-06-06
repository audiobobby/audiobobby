//
//  BalloonsAppDelegate.m
//  Balloons
//
//  Created by Mehayhe on 7/17/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "SoundEffect.h"
#import "MusicPlayer.h"
#import "IntroScene.h"
#import "RootViewController.h"
#import "FlurryAPI.h"
#import "MainScene.h"


@implementation AppDelegate

@synthesize window;

+ (void)initialize
{
	if ([self class] == [AppDelegate class]) 
	{
		
		NSDictionary *dict = [NSPropertyListSerialization
													propertyListFromData:[[NSFileManager defaultManager] 
																								contentsAtPath: [[NSBundle mainBundle] 
																																 pathForResource:@"Properties" 
																																 ofType:@"plist"]]
													mutabilityOption:NSPropertyListImmutable
													format:nil errorDescription:nil];
		//TRACE(@"INIT: %@", dict);
		[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
		 
	}	
}


- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
		CC_ENABLE_DEFAULT_GL_STATES();
		CCDirector *director = [CCDirector sharedDirector];
		CGSize size = [director winSize];
		CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
		sprite.position = ccp(size.width/2, size.height/2);
		sprite.rotation = -90;
		[sprite visit];
		[[director openGLView] swapBuffers];
		CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}


- (void) showMusicPicker { 
    if (!mediaSelector)
    {
        mediaSelector = [[AGKMediaSelector alloc] initWithNibName:nil bundle:nil];
        mediaSelector.delegate = self;
    }
    
    [viewController presentModalViewController:mediaSelector animated:YES];
   
}


- (void) mediaSelector:(AGKMediaSelector *)selector didSelectMediaSession:(AGKMediaSession *) session {
    [viewController dismissModalViewControllerAnimated:YES];
    [session retain];
    [session play];
    
}

- (void) mediaSelectorDidCancel:(AGKMediaSelector *)selector {
    [viewController dismissModalViewControllerAnimated:YES];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	TRACE(@"[start]");
#if FLURRY
	[FlurryAPI startSession:@"DSXLGGF2VE9TM4JN1XEU"];
#endif
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[Properties sharedProperties].scale = 1.0;
	} else {
		UIScreen *screen = [UIScreen mainScreen];
		[Properties sharedProperties].scale = ([screen respondsToSelector:@selector(scale)]) ? screen.scale : 1.0;
		TRACE(@"SCALE: %f", [Properties sharedProperties].scale);
	}
	
	[[Properties sharedProperties] load];

	//[[SimpleAudioEngine sharedEngine] preloadEffect:@"spear_fly.caf"];
	
	if([Properties sharedProperties].audio == NO) {
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
	} else {
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:[Properties sharedProperties].effectVolume];
	}
	
	//[[MusicPlayer sharedMusicPlayer] selectSong:@"main"];
	
	////////////////
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	CCDirector *director = [CCDirector sharedDirector];

	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
																 pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
																 depthFormat:0						// GL_DEPTH_COMPONENT16_OES
											];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if([[Properties sharedProperties] isIPad] == NO)
	{
		if( ! [director enableRetinaDisplay:YES] )
			CCLOG(@"Retina Display Not supported");
	}
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
#if DEBUG_MODE
	//[director setDisplayFPS:YES];
#endif
	
	
	viewController = [[RootViewController alloc] init]; //initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	[window addSubview:viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	
	// Removes the startup flicker
	//[self removeStartupFlicker];
	
	//[window addSubview:mainView.view];
	
	
	// and run it!
#if !DEBUG_MODE
	[director runWithScene: [MainScene scene]];
#else
	[director runWithScene: [MainScene scene]];
	//[director runWithScene: [GameScene scene]];
#endif
	

	EAGLView *view = [director openGLView];
	[view setMultipleTouchEnabled:YES];
	[self showMusicPicker];
	
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
	[[MusicPlayer sharedMusicPlayer] pause];
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	TRACE(@"[active]");
	if([Properties sharedProperties].paused == NO)
	{
		TRACE(@"[resume]");
		[[CCDirector sharedDirector] resume];
		[[MusicPlayer sharedMusicPlayer] resume];
	}
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	if([Properties sharedProperties].ready == YES) {
		[[CCDirector sharedDirector] purgeCachedData];
	}
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	TRACE(@"[enter background]");
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	TRACE(@"[applicationWillEnterForeground]");
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	TRACE(@"[terminate]");
	[[NSUserDefaults standardUserDefaults] setFloat:[Properties sharedProperties].musicVolume forKey:@"musicVolume"];
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[viewController release];
	//[window release];
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


- (void) onTouchButtonBack:(NSNotification *)notif
{	
	//[popSound play];
}

- (void) onTouchButton:(NSNotification *)notif
{	
	//[popSound play];
}






/////////////////////////////

- (void)dealloc 
{
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
