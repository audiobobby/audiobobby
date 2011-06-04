//
//  Popup.h
//  Balloons
//
//  Created by Mehayhe on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Popup : UIViewController <UIWebViewDelegate, GameDelegate>
{
	IBOutlet UIButton *backButton;
	IBOutlet UILabel *headerLabel;
	IBOutlet UIWebView *webView;
	IBOutlet UIImageView *panel;
	IBOutlet UIActivityIndicatorView *loadingView;
	NSString *targetHTML;
	NSString *targetURL;
	UIViewController *targetController;
}

- (void) goBack:(id)sender;
- (id) initContentFromHTML:(NSString *)_file header:(NSString *)header;
- (id) initContentFromURL:(NSString *)_url header:(NSString *)header;
- (id) initContentFromController:(UIViewController *)controller header:(NSString *)header;

@end
