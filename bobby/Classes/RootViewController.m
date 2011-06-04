//
//  RootViewController.m
//  Messenger
//
//  Created by Mehayhe on 1/2/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "GameConfig.h"
#import "Popup.h"
#import "DataFeed.h"
#import "PromptController.h"
#import "MusicPlayer.h"
#import "TipsView.h"

#define kLeaderboardHighScore @"highscore"
#define kAchievementPrefix @"com.h2indie.bobby"


@interface RootViewController (Internal)
- (void) onSubmitScore:(NSNotification *)notif;
@end

@implementation RootViewController

@synthesize gameCenterManager;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)init 
{
	if ((self = [super init])) 
	{
		TRACE(@"init rootview");
	 	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowInfo:) name:@"ShowInfo" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowLeaderboards:) name:@"ShowLeaderboards" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowAchievements:) name:@"ShowAchievements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemovePopup:) name:@"RemovePopup" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowPausePanel:) name:@"ShowPausePanel" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowPromptPanel:) name:@"PromptSubmit" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPromptRating:) name:@"PromptRating" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSubmitScore:) name:@"SubmitScore" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSubmitAchievement:) name:@"SubmitAchievement" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowTips:) name:@"ShowTips" object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowBanner:) name:@"ShowBanner" object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHideBanner:) name:@"HideBanner" object:nil];
		
#if !defined(LITE_APP)
		if([GameCenterManager isGameCenterAvailable])
		{
			TRACE(@"authenticating...");
			self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
			[self.gameCenterManager setDelegate: self];
			[self.gameCenterManager authenticateLocalUser];
			[Properties sharedProperties].gamecenter = YES;
		}
#endif
	
	}
	return self;
}
 

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	[super viewDidLoad];
	 TRACE(@"here2");
	 //	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowInfo:) name:@"ShowInfo" object:nil];
 }*/

/*
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	TRACE(@"Banner view is beginning an ad action");
	BOOL shouldExecuteAction = YES; // your application implements this method
	if (!willLeave && shouldExecuteAction)
	{
		// insert code here to suspend any services that might conflict with the advertisement
	}
	return shouldExecuteAction;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)_banner
{
	if (!bannerIsVisible)
	{
		
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		// Assumes the banner view is just off the bottom of the screen.
		//
		_banner.frame = CGRectOffset(_banner.frame, 0, 0);
		[UIView commitAnimations];
		bannerIsVisible = YES;
	}
}

- (void) removeBanner
{
	if(banner != nil) {
		banner.delegate = nil;
		[banner removeFromSuperview];
		[banner release];
		banner = nil;
	}
	bannerIsVisible = NO;
}

- (void)bannerView:(ADBannerView *)_banner didFailToReceiveAdWithError:(NSError *)error
{
	if (bannerIsVisible)
	{
		[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// Assumes the banner view is placed at the bottom of the screen.
		_banner.frame = CGRectOffset(_banner.frame, 0, -_banner.frame.size.height);
		[UIView commitAnimations];
		[self removeBanner];
	}
}


- (void) onShowBanner:(NSNotification *)notif
{
	[self removeBanner];
	TRACE(@"show banner");
	banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
	banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
	banner.delegate = self;
	int height = ([[Properties sharedProperties] isIPad]) ? 66 : 32;
	int width = ([[Properties sharedProperties] isIPad]) ? 1024 : 480;
	banner.frame = CGRectMake(0, 0, width, -height);
	TRACE(@"bw:%f, %f", width, height);
	[self.view addSubview:banner];
}

- (void) onHideBanner:(NSNotification *)notif
{
	TRACE(@"hide banner");
	[self removeBanner];
}

 */


- (void) processGameCenterAuth: (NSError*) error
{
	if(error == NULL)
	{
		authenticated = YES;
		TRACE(@"authenticated %@", [GKLocalPlayer localPlayer].alias);
		if([Properties sharedProperties].username == nil) {
			if([GKLocalPlayer localPlayer].alias != nil)
			{
				[Properties sharedProperties].username = [GKLocalPlayer localPlayer].alias;
				[[NSUserDefaults standardUserDefaults] setValue:[GKLocalPlayer localPlayer].alias forKey:@"username"];
			}
		}
	}
}

- (void) onPromptRating:(NSNotification *)notif
{
//#if !DEBUG_MODE	
		if([DataFeed hasInternetConnectionWithAlert:NO] == YES)
		{
			NSString *message = ([[Properties sharedProperties] isLowRes]) ? @"Would you like to rate this game?" : @"Would you like to rate this game?\nWe'd appreciate your feedback!";
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:nil
																												message:message 
																											 delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate Now", @"Remind Me Later", nil];
			[myAlert show];
			[myAlert release];
			alertMode = AlertTypeRating;
			//[Properties sharedProperties].ratingPrompted = YES;
			//[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ratingPrompted"];
		}
//#endif
}

- (void) onSubmitAchievement:(NSNotification *)notif
{
	if(authenticated == YES)
	{
		NSString *uid = [NSString stringWithFormat:@"%@.level%@", kAchievementPrefix, [notif object]];
		TRACE(@"submit achievement: %@", uid);
		[self.gameCenterManager submitAchievement:uid percentComplete:100.0];
	}
}

- (void) onSubmitScore:(NSNotification *)notif
{
	if([Properties sharedProperties].lastScore <= 0) return;
	TRACE(@"submit score, %d", [Properties sharedProperties].lastScore);
	if(authenticated == YES)
	{
		[self.gameCenterManager reportScore:[Properties sharedProperties].lastScore forCategory:kLeaderboardHighScore];
	}	
}

- (void) scoreReported: (NSError*) error
{
	if(error == NULL)
	{
		TRACE(@"Score Reported!");
	}
	else
	{
		TRACE(@"Score Report Failed! %@", [error localizedDescription]);
	}
}

- (void) submitScoreCompleted:(NSDictionary *)dict
{
	//NSLog(@"dict: %@", dict);
}

- (void) onShowInfo:(NSNotification *)notif
{	
	popup = [[Popup alloc] initContentFromHTML:@"how_to_play" header:@"How to Play"];
	[self.view addSubview:popup.view];
}

- (void) onShowTips:(NSNotification *)notif
{
	if(tips != nil) return;
	tips = [[TipsView alloc] initWithNibName:XIB(@"TipsView") bundle:nil];
	[self.view addSubview:tips.view];
}

- (void) showGamecenterError
{
	UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
																										message:@"Game Center has been disabled. Please sign in using the Game Center app to enable this feature."
																									 delegate:self 
																					cancelButtonTitle:@"Ok" 
																					otherButtonTitles:nil];
	[myAlert show];
	[myAlert release];	
	alertMode = AlertTypeOther;
}

- (void) onShowAchievements:(NSNotification *)notif
{	
	if([GameCenterManager isGameCenterAvailable])
	{
		if(authenticated == YES)
		{
			GKAchievementViewController *controller = [[GKAchievementViewController alloc] init];
			if (controller != NULL) 
			{
				controller.achievementDelegate = self; 
				[self presentModalViewController:controller animated: YES];
			}
		}
		else 
		{
			[self showGamecenterError];
		}
	}
	else 
	{
		UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
																											message:@"This feature requires Game Center."
																										 delegate:self 
																						cancelButtonTitle:@"Ok" 
																						otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];	
		alertMode = AlertTypeOther;
	}	
}


- (void) onShowLeaderboards:(NSNotification *)notif
{	
	if([GameCenterManager isGameCenterAvailable])
	{
		if(authenticated == YES)
		{
			GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
			if (leaderboardController != NULL) 
			{
				leaderboardController.category = kLeaderboardHighScore; 
				leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
				leaderboardController.leaderboardDelegate = self; 
				[self presentModalViewController: leaderboardController animated: YES];
			}
		}
		else 
		{
			[self showGamecenterError];
		}
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}

- (void) onShowPausePanel:(NSNotification *)notif
{
	[NSTimer scheduledTimerWithTimeInterval: 0.5
																	 target: self
																 selector: @selector(showPausePanelNow:)
																 userInfo: nil
																	repeats: NO
	 ];
}

- (void) showPausePanelNow:(NSTimer *)timer
{
	UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:nil
																										message:nil
																									 delegate:self 
																					cancelButtonTitle:@"Quit Game" 
																					otherButtonTitles:@"Resume Game", @"Instructions", nil];
	myAlert.cancelButtonIndex = 0;
	[myAlert show];
	[myAlert release];
	alertMode = AlertTypePaused;
}

- (void) onShowPromptPanel:(NSNotification *)notif
{
	alertMode = AlertTypeSubmit;
	[Properties sharedProperties].prompted = YES;
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"prompted"];
	UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
																										message:@"Do you want to submit your score\nto our server to determine your\nranking on the leaderboard?"
																									 delegate:self 
																					cancelButtonTitle:@"No" 
																					otherButtonTitles:@"Yes", nil];
	myAlert.cancelButtonIndex = 0;
	[myAlert show];
	[myAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	TRACE(@"index:%d, %d", buttonIndex, alertMode);
	
	if(alertMode == AlertTypePaused)
	{
		if(buttonIndex == 1)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeGame" object:nil];	
		}	
		else if(buttonIndex == 2)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTips" object:nil];	
		}
		else 
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"EndGame" object:nil];
		}
	}
	else if(alertMode == AlertTypeSubmit)
	{
		if(buttonIndex == 1)
		{
			if([Properties sharedProperties].username == nil)
			{
				[NSTimer scheduledTimerWithTimeInterval: 0.5
																			 target: self
																		 selector: @selector(onPromptUsername:)
																		 userInfo: nil
																			repeats: NO
				 ];
			}
			else 
			{
				[self onSubmitScore:nil];
			}

			[Properties sharedProperties].submit = YES;
		}
		else 
		{
			[Properties sharedProperties].submit = NO;
		}
		[[NSUserDefaults standardUserDefaults] setBool:[Properties sharedProperties].submit forKey:@"submit"];
	}
	else if(alertMode == AlertTypeRating)
	{
		if(buttonIndex == 1)
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.com/apps/audiobobby"]];	
			[Properties sharedProperties].counter = + [Properties sharedProperties].totalGames + 3000;
		}
		else if(buttonIndex == 2)
		{
			[Properties sharedProperties].counter = [Properties sharedProperties].totalGames + 10;
		}
		else {
			[Properties sharedProperties].counter = [Properties sharedProperties].totalGames + 100;
		}
		TRACE(@"next counter:%d", [Properties sharedProperties].counter);
		[[NSUserDefaults standardUserDefaults] setInteger:[Properties sharedProperties].counter forKey:@"counter"];
	}
	//alertMode = AlertTypeNone;
}


- (void) onRemovePopup:(NSNotification *)notif
{
	if(popup != nil) {
		[popup.view removeFromSuperview];
		[popup release];
		popup = nil;
	}
	if(tips != nil) {
		[tips.view removeFromSuperview];
		[tips release];
		tips = nil;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeGame" object:nil];	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated.
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	//
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in landscpe mode
	//
	// return YES for the supported orientations
	
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION
	
	
	// Shold not happen
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// Assuming that the main window has the size of the screen
	// BUG: This won't work if the EAGLView is not fullscreen
	///
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect rect;
	
	if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
		rect = screenRect;
	
	else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
	
	CCDirector *director = [CCDirector sharedDirector];
	EAGLView *glView = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	//[self removeBanner];
	
	if(popup != nil) {
		[popup.view removeFromSuperview];
		[popup release];
	}
	if(prompt != nil) {
		[prompt release];
	}
	
    [super dealloc];
}


@end

