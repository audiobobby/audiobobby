//
//  FeedCentral.m
//  Poetry
//
//  Created by Mehayhe on 6/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataFeed.h"
#import "Reachability.h"
#import "CJSONDeserializer.h"

/////////////////////


static NSString *boundary = @"---------------------------147378274664144922";

@implementation DataFeed

///////////////////////////////

- (NSMutableData *) initContentBody
{
	NSMutableData *body = [NSMutableData data];
	[body appendData:[self addFormData:@"uid" withString:[[UIDevice currentDevice] uniqueIdentifier]]];
	return body;
}


//////////////////////////

- (NSData *) addFormBoundary
{
	return [[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding];
}

//////////////////////////////////////////


- (NSData *) addFormData:(NSString *)_name withInt:(int)_value
{
	return [self addFormData:_name withString:[[NSNumber numberWithInt:_value] stringValue]];
}


- (NSData *) addFormData:(NSString *)_name withFloat:(float)_value
{
	return [self addFormData:_name withString:[[NSNumber numberWithFloat:_value] stringValue]];
}


- (NSData *) addFormData:(NSString *)_name withString:(NSString *)_value
{
	NSMutableData *body = [NSMutableData data];
	[body appendData:[self addFormBoundary]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";\r\n\r\n%@", _name, _value] dataUsingEncoding:NSUTF8StringEncoding]];	
	return body;
}

- (NSData *) addFormData:(NSString *)_name filename:(NSString *)_filename withData:(NSData *)_data
{
	NSMutableData *body = [NSMutableData data];
	[body appendData:[self addFormBoundary]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", _name, _filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/zip\r\n"] dataUsingEncoding:NSUTF8StringEncoding]]; 
	[body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:_data];	
	return body;
}

/////////////////////////////////////////////////
	 
- (NSString *) getSession
{
	if(sessionID == nil)
	{
		return @"";
	}
	else
	{
		return [NSString stringWithFormat:@"PHPSESSID=%@", sessionID];
	}
}
	 
	 
//////////////////////////////////////////////////


- (void) postData:(NSMutableData *)_body withAction:(NSString *)_action
{
	[self postData:_body withAction:_action binary:NO];
}

- (void) postData:(NSMutableData *)_body withAction:(NSString *)_action binary:(BOOL)_binary
{
	[self stopProcess];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoading" object:nil];
	
	binary = _binary;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString *url = [NSString stringWithFormat:API_FORMAT, APP_SERVER, WEB_SERVICES, _action, [self getSession]];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	
	TRACE(@"url: %@", url);
	
	if(_body != nil)
	{
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
		[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
		[request setHTTPBody:_body];
	}
	
	//con = [NSURLConnection connectionWithRequest:request delegate:self];
	
	con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (con) 
	{
		dataDict = nil;
    receivedData = [[NSMutableData data] retain];
		loading = YES;
	}
	
}


//////////////////////////////////////////////////


- (void) stopProcess
{
	if(loading == YES)
	{
		@try {
			[con cancel];
			//NSLog(@"Process stopped");
		}
		@catch (NSException * e) {
			//
		}
	}
}


//////////////////////////////////////////////////



- (void) loadDataWithURL:(NSString *)_url
{
	TRACE(@"loading: %@", _url);
	
	if(_url == nil) return;
	
	[self stopProcess];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]
																					 cachePolicy:NSURLRequestUseProtocolCachePolicy
																			 timeoutInterval:30];

	con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
	if (con) 
	{
		dataDict = nil;
    receivedData = [[NSMutableData data] retain];
		loading = YES;
	}
}

	 
//////////////////////////////////////////////////

- (void) onProgress:(float)progress
{
	

}
	 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	dataLength = [response expectedContentLength];
	[receivedData setLength:0];
}

	 
	 //////////////////////////////////////////////////
	 
	 
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
	float progress = -1.0;
	if(dataLength != NSURLResponseUnknownLength)
	{
		progress = [receivedData length]/(dataLength * 1.0);
		if(progress < 0.0) progress = 0;
		else if(progress > 1.0) progress = 1;
	}
	[self onProgress:progress];
	//TRACE(@"progress:%f", progress);
}

	 
	 //////////////////////////////////////////////////
	 
	 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if(connection != nil) [connection release];
	if(receivedData != nil) [receivedData release];
	loading = NO;
	[self onFault:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoading" object:nil];
}

	 
/////////////////////////////////////////////////
/////////////////////////////////////////////////
	 
	 
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(connection != nil) [connection release];
	loading = NO;
	TRACE(@"Succeeded! Received %d bytes of data, %d",[receivedData length], binary);
	if(binary == NO)
	{
		//[self parseData];
		dataDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:receivedData error:nil];
		TRACE(@"JSON: %@", dataDict);

		if(dataDict == nil)
		{
#if DEBUG_MODE
			NSString* theString = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
			NSLog(@"%@", theString);
			[theString release];
#endif
			[self onFault:nil];
		}
		else if([dataDict objectForKey:@"error"] != nil)
		{
			[self onFault:dataDict];
		}
		else if([dataDict objectForKey:@"success"] != nil)
		{
			[self onResult:dataDict];
		}
		else if([dataDict objectForKey:@"expired"] != nil)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpiredSession" object:nil];
		}
		else
		{
			[self onFault:nil];
		}
	}
	else
	{	
		[self onBinaryResult:receivedData];
		//[[NSNotificationCenter defaultCenter] postNotificationName:callback object:[self getRawData]];
	}
	
	[receivedData release];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoading" object:nil];
}



- (void) onBinaryResult:(NSData *)data
{
	
}

- (void) onResult:(id)data
{
	
}


- (void) onFault:(id)data
{
	
}



///////////////////////////////////


- (NSDictionary *) getResponse
{
	[self parseData];
	return dataDict;
}


///////////////////////////////////


- (void) parseData
{
	if(dataDict == nil)
	{
		//NSData *jsonData = [receivedData dataUsingEncoding:NSUTF32BigEndianStringEncoding];
		
		//TRACE(@"JSON: %@", jsonData);
		dataDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:receivedData error:nil];
		[receivedData release];
	}
}


///////////////////////////////////

+ (BOOL) hasInternetConnectionOrShowAlert
{
	return [self hasInternetConnectionWithAlert:YES];
}

+ (BOOL) hasInternetConnectionWithAlert:(BOOL)alert
{
	//if(connectable == YES) return connectable;

	Reachability *r = [Reachability reachabilityWithHostName:@"apple.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
	{
		if(alert == YES)
		{
			UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" 
																											message:@"You device needs to be connected to the internet via WiFi or cellular network to view this content." 
																										 delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[myAlert show];
			[myAlert release];
		}
		//connectable = NO;
		return NO;
	}
	else 
	{
		//connectable = YES;
		return YES;
	}
}


- (void)dealloc 
{
	[super dealloc];
}

@end
