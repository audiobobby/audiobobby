//
//  PromptController.h
//  Virtuoso
//
//  Created by Mehayhe on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptController : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
	UIAlertView *promptView;
	UITextField *nameField;
	NSMutableString *username;
	int alertMode;
}

@end
