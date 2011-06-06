//
//  TipsView.m
//  Messenger
//
//  Created by Mehayhe on 1/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PauseView.h"


@implementation PauseView

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	soundBtn.selected = [Properties sharedProperties].audio;
	moonwalkBtn.selected = [Properties sharedProperties].moonwalk;
	
	[soundBtn addTarget:self action:@selector(updatePref:) forControlEvents:UIControlEventTouchDown];
	[moonwalkBtn addTarget:self action:@selector(updatePref:) forControlEvents:UIControlEventTouchDown];
}

- (void) updatePref:(id)sender
{
	if(soundBtn == sender)
	{
		soundBtn.selected = !soundBtn.selected;
		[Properties sharedProperties].audio = soundBtn.selected;
		[[NSUserDefaults standardUserDefaults] setBool:soundBtn.selected forKey:@"audio"];
	}
	else if(moonwalkBtn == sender)
	{
		moonwalkBtn.selected = !moonwalkBtn.selected;
		[Properties sharedProperties].moonwalk = moonwalkBtn.selected;
		[[NSUserDefaults standardUserDefaults] setBool:moonwalkBtn.selected forKey:@"moonwalk"];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) endGame:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EndGame" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePopup" object:nil];
}

- (IBAction) resume:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeGame" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePopup" object:nil];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
