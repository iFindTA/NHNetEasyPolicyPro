//
//  JSONModelHTTPClient.m
//
//  @version 0.9.0
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012-2013 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "JSONHTTPClient.h"
#import <UIKit/UIKit.h>

#pragma mark - constants
NSString* const kHTTPMethodGET = @"GET";
NSString* const kHTTPMethodPOST = @"POST";

NSString* const kContentTypeAutomatic    = @"jsonmodel/automatic";
NSString* const kContentTypeJSON         = @"application/json";
NSString* const kContentTypeWWWEncoded   = @"application/x-www-form-urlencoded";

#pragma mark - static variables

/**
 * Defaults for HTTP requests
 */
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
static int defaultTextEncoding = NSUTF8StringEncoding;
static int defaultCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
#else
static long defaultTextEncoding = NSUTF8StringEncoding;
static long defaultCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
#endif

static int defaultTimeoutInSeconds = 60;

/**
 * Whether the iPhone net indicator automatically shows when making requests
 */
static BOOL doesControlIndicator = YES;

/**
 * Custom HTTP headers to send over with *each* request
 */
static NSMutableDictionary* requestHeaders = nil;

/**
 * Default request content type
 */
static NSString* requestContentType = nil;

#pragma mark - implementation
@implementation JSONHTTPClient

#pragma mark - initialization
+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        requestHeaders = [NSMutableDictionary dictionary];
        requestContentType = kContentTypeAutomatic;
    });
}

#pragma mark - configuration methods
+(NSMutableDictionary*)requestHeaders
{
    return requestHeaders;
}

+(void)setDefaultTextEncoding:(NSStringEncoding)encoding
{
    defaultTextEncoding = encoding;
}

+(void)setCachingPolicy:(NSURLRequestCachePolicy)policy
{
    defaultCachePolicy = policy;
}

+(void)setTimeoutInSeconds:(int)seconds
{
    defaultTimeoutInSeconds = seconds;
}

+(void)setControlsNetworkIndicator:(BOOL)does
{
    doesControlIndicator = does;
}

+(void)setRequestContentType:(NSString*)contentTypeString
{
    requestContentType = contentTypeString;
}

#pragma mark - helper methods
+(NSString*)contentTypeForRequestString:(NSString*)requestString
{
    //fetch the charset name from the default string encoding
    NSString* contentType = requestContentType;

    if ([contentType isEqualToString:kContentTypeAutomatic]) {
        //check for "eventual" JSON array or dictionary
        NSString* firstAndLastChar = [NSString stringWithFormat:@"%@%@",
                                      [requestString substringToIndex:1],
                                      [requestString substringFromIndex: requestString.length -1]
                                      ];
        
        if ([firstAndLastChar isEqualToString:@"{}"] || [firstAndLastChar isEqualToString:@"[]"]) {
            //guessing for a JSON request
            contentType = kContentTypeJSON;
        } else {
            //fallback to www form encoded params
            contentType = kContentTypeWWWEncoded;
        }
    }

    //type is set, just add charset
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return [NSString stringWithFormat:@"%@; charset=%@", contentType, charset];
}

+(NSString*)urlEncode:(NSString*)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

#pragma mark - networking worker methods
+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method requestBody:(NSString*)bodyString headers:(NSDictionary*)headers etag:(NSString**)etag error:(NSError**)err
{
    //turn on network indicator
    if (doesControlIndicator) dispatch_async(dispatch_get_main_queue(), ^{[self setNetworkIndicatorVisible:YES];});

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url
                                                                cachePolicy: defaultCachePolicy
                                                            timeoutInterval: defaultTimeoutInSeconds];
	[request setHTTPMethod:method];

    if ([requestContentType isEqualToString:kContentTypeAutomatic]) {
        //automatic content type
        if (bodyString) {
            [request addValue: [self contentTypeForRequestString: bodyString] forHTTPHeaderField:@"Content-type"];
        }
    } else {
        //user set content type
        [request addValue: requestContentType forHTTPHeaderField:@"Content-type"];
    }
    
    //add all the custom headers defined
    for (NSString* key in [requestHeaders allKeys]) {
        [request addValue:requestHeaders[key] forHTTPHeaderField:key];
    }
    
    //add the custom headers
    for (NSString* key in [headers allKeys]) {
        [request addValue:headers[key] forHTTPHeaderField:key];
    }
    
    if (bodyString) {
        //BODY params
        NSData* bodyData = [bodyString dataUsingEncoding:defaultTextEncoding];
        
        [request setHTTPBody: bodyData];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
#else
        [request addValue:[NSString stringWithFormat:@"%ld", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
#endif
        
    }
    
    //prepare output
	NSHTTPURLResponse* response = nil;
    
    //fire the request
	NSData *responseData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: err];
    //turn off network indicator
    if (doesControlIndicator) dispatch_async(dispatch_get_main_queue(), ^{[self setNetworkIndicatorVisible:NO];});
    
    //check for successful status
	if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
    } else {
        //error, for now just return nil
        return nil;
    }
}

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method params:(NSDictionary*)params headers:(NSDictionary*)headers etag:(NSString**)etag error:(NSError**)err
{
    //create the request body
    NSMutableString* paramsString = nil;

    if (params) {
        //build a simple url encoded param string
        paramsString = [NSMutableString stringWithString:@""];
        for (NSString* key in [[params allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            [paramsString appendFormat:@"%@=%@&", key, [self urlEncode:params[key]] ];
        }
        if ([paramsString hasSuffix:@"&"]) {
            paramsString = [[NSMutableString alloc] initWithString: [paramsString substringToIndex: paramsString.length-1]];
        }
    }
    
    //set the request params
    if ([method isEqualToString:kHTTPMethodGET] && params) {

        //add GET params to the query string
        url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@%@",
                                    [url absoluteString],
                                    [url query] ? @"&" : @"?",
                                    paramsString
                                    ]];
    }
    
    //call the more general synq request method
    return [self syncRequestDataFromURL: url
                                 method: method
                            requestBody: [method isEqualToString:kHTTPMethodPOST]?paramsString:nil
                                headers: headers
                                   etag: etag
                                  error: err];
}

#pragma mark - Async network request
+(void)JSONFromURLWithString:(NSString*)urlString method:(NSString*)method params:(NSDictionary*)params orBodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    NSDictionary* customHeaders = nil;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary* jsonObject = nil;
        JSONModelError* error = nil;
        NSData* responseData = nil;
        NSString* etag = nil;
        
        @try {
            if (bodyString) {
                responseData = [self syncRequestDataFromURL: [NSURL URLWithString:urlString]
                                                     method: method
                                                requestBody: bodyString
                                                    headers: customHeaders
                                                       etag: &etag
                                                      error: &error];
            } else {
                responseData = [self syncRequestDataFromURL: [NSURL URLWithString:urlString]
                                                     method: method
                                                     params: params
                                                    headers: customHeaders
                                                       etag: &etag
                                                      error: &error];
            }
        }
        @catch (NSException *exception) {
            error = [JSONModelError errorBadResponse];
        }
        
        //step 3: if there's no response so far, return a basic error
        if (!responseData && !jsonObject) {
            //check for false response, but no network error
            error = [JSONModelError errorBadResponse];
        }

        //step 4: if there's a response at this and no errors, convert to object
        if (error==nil && jsonObject==nil) {
            //convert to an object
            NSLog(@"use server response");
            jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        }
        
        //step 5: invoke the complete block
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(jsonObject, error);
            }
        });
    });
}

#pragma mark - request aliases
+(void)getJSONFromURLWithString:(NSString*)urlString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodGET
                         params:nil
                   orBodyString:nil completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodGET
                         params:params
                   orBodyString:nil completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:params
                   orBodyString:nil completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];

}

+(void)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:nil
                   orBodyString:bodyString completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)postJSONFromURLWithString:(NSString*)urlString bodyData:(NSData*)bodyData completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:nil
                   orBodyString:[[NSString alloc] initWithData:bodyData encoding:defaultTextEncoding]
                                 completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

#pragma mark - iOS UI helper
+(void)setNetworkIndicatorVisible:(BOOL)isVisible
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isVisible];
#endif
}

@end
