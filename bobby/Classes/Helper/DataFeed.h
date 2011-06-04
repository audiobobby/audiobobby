//
//  FeedCentral.h
//  Poetry
//
//  Created by Mehayhe on 6/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ERROR_MESG @"Unable to process request.\nPlease try again later."

@interface DataFeed : NSObject 
{
	NSMutableData *receivedData;
	NSString *callback;
	NSString *sessionID;
	NSDictionary *dataDict;
	NSURLConnection *con;
	BOOL loading;
	BOOL binary;
	BOOL connectable;
	long dataLength;
}

- (NSData *) addFormBoundary;
- (NSData *) addFormData:(NSString *)_name withString:(NSString *)_value;
- (NSData *) addFormData:(NSString *)_name withFloat:(float)_value;
- (NSData *) addFormData:(NSString *)_name withInt:(int)_value;
- (NSData *) addFormData:(NSString *)_name filename:(NSString *)_filename withData:(NSData *)_data;
- (NSDictionary *) getResponse;
- (void) postData:(NSMutableData *)_body withAction:(NSString *)_action binary:(BOOL)_binary;
- (void) postData:(NSMutableData *)_body withAction:(NSString *)_action;
- (void) loadDataWithURL:(NSString *)_url;
- (void) parseData;
- (void) stopProcess;
- (NSString *) getSession;
+ (BOOL) hasInternetConnectionOrShowAlert;
+ (BOOL) hasInternetConnectionWithAlert:(BOOL)alert;
- (void) onResult:(id)data;
- (void) onFault:(id)data;
- (void) onBinaryResult:(NSData *)data;
- (NSMutableData *) initContentBody;
- (void) onProgress:(float)progress;

@end

