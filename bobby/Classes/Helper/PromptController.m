    //
//  PromptController.m
//  Virtuoso
//
//  Created by Mehayhe on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PromptController.h"

@implementation PromptController

- (void) showAlertBox
{
	if(nameField != nil) 
	{
		[nameField removeFromSuperview];
		[nameField release];
		nameField = nil;
	}
	if(promptView != nil)
	{
		[promptView release];
		promptView = nil;
	}
	
	alertMode = 0;
	
	promptView = [[UIAlertView alloc] initWithTitle:@"What is your name?" message:@" " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
	[promptView show];
	
	nameField = [[UITextField alloc] initWithFrame:CGRectMake(14, 45, 255, 28)];
	nameField.borderStyle = UITextBorderStyleBezel;
	nameField.textColor = [UIColor blackColor];
	nameField.textAlignment = UITextAlignmentLeft;
	nameField.font = [UIFont systemFontOfSize:14.0];
	nameField.placeholder = @"<name to display on leaderboards>";
	nameField.backgroundColor = [UIColor whiteColor];
	nameField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	nameField.returnKeyType = UIReturnKeyDone;
	nameField.delegate = self;
	nameField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	[promptView addSubview:nameField];
	
}
	
- (id) init
{
	if((self = [super init])) {
		TRACE(@"init prompt controller");
		[self showAlertBox];
		username = [[NSMutableString alloc] init];
	}
	return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
	[_textField resignFirstResponder];
	[promptView dismissWithClickedButtonIndex:promptView.cancelButtonIndex+1 animated:YES];
	return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)_textField
{
	[_textField resignFirstResponder];
	return YES;
}


- (void) submit
{
	
	BOOL error = NO;
	NSString *mesg;
	
	
	NSDictionary *bannedWordDict = [NSPropertyListSerialization
																	propertyListFromData:[[NSFileManager defaultManager] 
																												contentsAtPath: [[NSBundle mainBundle] 
																																				 pathForResource:@"BannedWords" 
																																				 ofType:@"plist"]]
																	mutabilityOption:NSPropertyListImmutable
																	format:nil errorDescription:nil];
	//NSLog(@"%@", bannedWordDict);
	//TRACE(@"count %@, %@, %d", [_textField.text lowercaseString], 
	//								[bannedWordDict objectForKey:[_textField.text lowercaseString]],
	//								[[[_textField.text lowercaseString] componentsSeparatedByString:@"fuck"] count]);
	
	if(username == nil)
	{
		mesg = @"Please enter something first.";
		error = YES;
	}
	else if([username length] == 0)
	{
		mesg = @"Please enter something first.";
		error = YES;
	}
	else if([username length] < 3)
	{
		mesg = @"Name is too short.";
		error = YES;
	}
	else if([bannedWordDict objectForKey:[username lowercaseString]] != nil || 
					[[[username lowercaseString] componentsSeparatedByString:@"fuck"] count] > 1)
	{
		mesg = @"Name is not allowed.";
		error = YES;
	}
	
	
	if(error == YES)
	{
		alertMode = 1;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
																										message:mesg
																									 delegate:self 
																					cancelButtonTitle:@"Ok" 
																					otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		
		[Properties sharedProperties].username = [username retain]; 
		[[NSUserDefaults standardUserDefaults] setValue:[Properties sharedProperties].username forKey:@"username"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SubmitScore" object:nil];	
		[self release];
		self = nil;
	}
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertMode == 0)
	{
		if(buttonIndex == alertView.cancelButtonIndex)
		{
			TRACE(@"cancel");
			[self release];
			self = nil;
		}
		else 
		{
			[self submit];
		}
	}
	else 
	{
		[self showAlertBox];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	TRACE(@"dismissing alert %d", buttonIndex);
	if(alertMode == 0)
	{
		if(nameField.text != nil) [username setString:nameField.text];
		[nameField resignFirstResponder];
	}
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



- (void)dealloc {
		TRACE(@"dealloc prompt controller");	
	[promptView release];
	[nameField release];
	[username release];
    [super dealloc];
}


@end
