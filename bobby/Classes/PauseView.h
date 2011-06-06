//
//  TipsView.h
//  Messenger
//
//  Created by Mehayhe on 1/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PauseView : UIViewController {
	IBOutlet UIButton *soundBtn, *moonwalkBtn;
}

- (IBAction) endGame:(id)sender;
- (IBAction) resume:(id)sender;

@end
