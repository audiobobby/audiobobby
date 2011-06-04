//
//  Popup.m
//  Balloons
//
//  Created by Mehayhe on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Popup.h"

@implementation Popup

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.center = [[Properties sharedProperties] getNewPopupLocation];
	self.view.alpha = 1;
	//TRACE(@"%f %f", self.view.center.x, self.view.center.y);
	if(targetHTML != nil)
	{
		NSString *filePath = [[NSBundle mainBundle] pathForResource:targetHTML ofType:@"html"];
		NSError *error = nil;
		NSString *content = [NSString stringWithContentsOfFile:filePath 
																									encoding:NSStringEncodingConversionAllowLossy 
																										 error:&error];
		[webView loadHTMLString:content baseURL:nil];
		[webView setOpaque:NO];
		[loadingView startAnimating];
	}
	else if(targetURL != nil)
	{
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:targetURL]
																						 cachePolicy:NSURLRequestUseProtocolCachePolicy
																				 timeoutInterval:30];
		[webView loadRequest:request];	
		[webView setOpaque:NO];
		[loadingView startAnimating];
	}
	else {
		[loadingView stopAnimating];
		[self.view addSubview:targetController.view];
		CGRect frame = targetController.view.frame;
		targetController.view.frame = CGRectMake(40, 55, frame.size.width, frame.size.height);
	}
	
	webView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	webView.hidden = YES;
	//headerLabel.text = self.title;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (id) initContentFromController:(UIViewController *)controller header:(NSString *)header
{
	if ((self = [super initWithNibName:XIB(@"Popup") bundle:nil])) 
	{
		self.title = header;
		targetController = controller;
		
	}
	return self;
}

- (id) initContentFromURL:(NSString *)_url header:(NSString *)header
{
	if ((self = [super initWithNibName:XIB(@"Popup") bundle:nil])) 
	{
		self.title = header;
		targetURL = _url;
	}
	return self;
}

- (id) initContentFromHTML:(NSString *)_file header:(NSString *)header
{
	if ((self = [super initWithNibName:XIB(@"Popup") bundle:nil])) 
	{
		self.title = header;
		targetHTML = _file;
	}
	return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
	[loadingView stopAnimating];
	webView.hidden = NO;
}

- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error
{
	[loadingView stopAnimating];
	[webView loadHTMLString:@"<html><body>Unable to process request. Please try again later.</body></html>" baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if(navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		/*
		NSRange range = [[request.URL absoluteString] rangeOfString:@"/info?"];
		if(range.location != NSNotFound) {

		}
		return YES;*/
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	else {
		return YES;
	}
}


- (void)dropAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{	
	[self.view removeFromSuperview];
	[self release];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePopup" object:nil];
}


- (void) goBack:(id)sender
{
	[webView stopLoading];
	webView.delegate = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TouchButton" object:nil];	
	if(1) //[[Properties sharedProperties] isIPad] == YES)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dropAnimationDidStop:finished:context:)];
		[UIView setAnimationDuration:OPEN_CLOSE_DURATION];
		self.view.alpha = 0;
		[UIView commitAnimations];
	} 
	else 
	{
		[UIView animateWithDuration:OPEN_CLOSE_DURATION
										 animations:^{ 
											 self.view.alpha = 0;
										 }
										 completion:^(BOOL finished){ 
											 [self.view removeFromSuperview];
											 [self release];
											 [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePopup" object:nil];
										 }];
	}
}


- (void) onDone
{
	TRACE(@"popup done");
	[self goBack:nil];
}

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
	TRACE(@"dealloc popup");
	if(targetController != nil) [targetController release];
	[loadingView release];
	//[headerLabel release];
	if(webView != nil) {
		[webView stopLoading];
		webView.delegate = nil;
	}
	[webView release];
	[panel release];
    [super dealloc];
}


@end
