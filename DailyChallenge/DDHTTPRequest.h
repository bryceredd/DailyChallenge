//
//  DDHTTPRequest.h
//  NSURLReqTests
//
//  Created by Dave Durazzani on 1/23/12.
//  Copyright (c) 2012 Dave Durazzani. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HTTPGetMethod;
extern NSString * const HTTPPostMethod;
extern NSString * const HTTPPutMethod;
extern NSString * const HTTPDeleteMethod;  //  not implemented yet

enum {
    DDHTTPRequestErrorNone = 0,    
    DDHTTPRequestErrorOpenStreamFailure = 1,
    DDHTTPRequestErrorStreamError = 2,
    DDHTTPRequestErrorStreamHasNoSpace = 3,
    DDHTTPRequestErrorStreamClose = 4,
    DDHTTPRequestErrorStatusCode = 5,
    DDHTTPRequestErrorStatusInvalidDownloadPath = 6,
    DDHTTPRequestErrorStatusMoveToDownloadPath = 7
};
typedef NSUInteger DDHTTPRequestError;

extern const NSUInteger HTTPStatusNone;
extern const NSUInteger HTTPStatusOK;
extern const NSUInteger HTTPStatusBadRequest;
extern const NSUInteger HTTPStatusUnauthorized;
extern const NSUInteger HTTPStatusNotFound;
extern const NSUInteger HTTPStatusInternalServerError;

extern NSString * const DDHTTPRequestFileStreamDomain;
extern NSString * const DDHTTPRequestStatusCodeDomain;
extern NSString * const DDHTTPRequestContentTypeForm;


#pragma - Content-Types
extern NSString* const DDHTTPRequestContentTypeOctetStream;
extern NSString* const DDHTTPRequestConentTypeJSON;


@interface DDHTTPRequest : NSOperation <NSURLConnectionDelegate,NSStreamDelegate>

@property(readonly, nonatomic, strong) NSMutableURLRequest * request;


#pragma - NSMutableURLRequest Paramaters
@property(readonly, strong) NSHTTPURLResponse * response;
@property(readonly, strong) NSError * error;
@property(readonly, strong) NSMutableData * responseData;
@property(readonly, strong) NSNumber * fileSize;
@property(readonly, strong) NSNumber * statusCode;
@property(nonatomic, copy) NSString * contentType;


#pragma - State
@property(readonly, assign) NSUInteger bytesWritten;
@property(readonly, assign) CGFloat progress;


#pragma - CallBack Blocks
@property(nonatomic, copy) void(^requestStartedBlock)(DDHTTPRequest * request);
@property(nonatomic, copy) void(^dataHandlerBlock)(DDHTTPRequest * request);

/**
 For now these two block are always assigned to the same completion
 block passed in to the sendAsyncWithCallback call.
 */
@property(nonatomic, copy) void(^failure)(DDHTTPRequest * request);
@property(nonatomic, copy) void(^completion)(DDHTTPRequest * request);


#pragma - Download to File
@property(nonatomic, copy) NSString * tmpDownloadPath;
@property(nonatomic, copy) NSString * downloadPath;


+ (NSOperationQueue*)requestsOperationQueue;

#pragma - Class Initializer

+ (DDHTTPRequest *)getRequestForURL:(NSURL *)url;

/**
 POST
 * Will setup a standard post request with Content-Type set to application/json
 * If content type needs be different just set it before calling sendAsync on
 * DDHTTPRequest objects.
 */
+ (DDHTTPRequest *)postRequestForURL:(NSURL *)url;
+ (DDHTTPRequest *)postRequestForURL:(NSURL *)url contentType:(NSString*)ct;

/**
 PUT
 If contentType is nil it will be set to DDHTTPRequestDefaultConentType
 */
+ (DDHTTPRequest *)putRequestForURL:(NSURL *)url contentType:(NSString*)ct;

+ (NSString *)documentsPath;
+ (NSString *)tmpDownloadsPath;
+ (NSString *)downloadsPath;
+ (NSString *)tmpDownloadPathForFileName:(NSString*)filename;
+ (NSString *)downloadPathForFileName:(NSString*)filename;

#pragma - Configure Request
- (void)sendAsyncWithCallback:(void(^)(DDHTTPRequest * request))block;


#pragma - Request Setup
- (void)preparePostBodyFromDictionary:(NSDictionary *)dict;
- (void)preparePutBodyFromDictionary:(NSDictionary *)dict;
- (void)preparePostBodyFromData:(NSData*)pData;
- (void)preparePutBodyFromData:(NSData*)pData;
- (void)prepareRequestHeadersFromDictionary:(NSDictionary*)hDict;


#pragma - Response

- (id)responseJSON;
- (NSString *)responseStringValueUTF8Encoding;
- (UIImage *)responseDataToImage;

@end
