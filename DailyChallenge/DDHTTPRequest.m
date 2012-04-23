//
//  DDHTTPRequest.m
//  NSURLReqTests
//
//  Created by Dave Durazzani on 1/23/12.
//  Copyright (c) 2012 Dave Durazzani. All rights reserved.
//

#import "DDHTTPRequest.h"
#import "JSONKit.h"     //      fastest option for now.



//  Custom settings
#define     CONTENT_TYPE            @"Content-Type"
#define     MAX_CONCURRENT          4u
#define     TMP_DOWNLOADS_PATH      @"DDHTTPReqTmpDownloads"
#define     DOWNLOADS_PATH          @"DDHTTPReqDownloads"
#define     DEBUG_DDHTTP_REQ        1




const NSUInteger HTTPStatusNone                = 0;
const NSUInteger HTTPStatusOK                  = 200;
const NSUInteger HTTPStatusBadRequest          = 400;
const NSUInteger HTTPStatusUnauthorized        = 401;
const NSUInteger HTTPStatusNotFound            = 404;
const NSUInteger HTTPStatusInternalServerError = 500;


/**
 Content-types
 */
NSString * const DDHTTPRequestContentTypeOctetStream    =       @"application/octet-stream";
NSString * const DDHTTPRequestConentTypeJSON            =       @"application/json";
NSString * const DDHTTPRequestContentTypeForm           =       @"application/x-www-form-urlencoded";
/**
 * When creating post requests this is the default content-type
 * If you need to set a different content type, then set the 
 * content type right after creating the DDHTTPRequest object.
 */
NSString * const DDHTTPRequestConentTypeDefault         =       @"application/json";



/**  
 * the minimum timeout interval for POST is 240 seconds
 * If we want this interval to affect POST requests when
 * less than 240, then we need to simply have a timer and
 * cancel the post request once over time.
 */
const NSTimeInterval DDHTTPRequestTimeoutInterval = 30.0f;

NSString * const kDefaultTempDownloadsDirectory = TMP_DOWNLOADS_PATH;
NSString * const kDefaultDownloadsDirectory = DOWNLOADS_PATH;

NSString * const HTTPGetMethod    =     @"GET";
NSString * const HTTPPostMethod   =     @"POST";
NSString * const HTTPPutMethod    =     @"PUT";
NSString * const HTTPDeleteMethod =     @"DELETE";  //  not implemented yet


NSString * const DDHTTPRequestFileStreamDomain = @"com.DDHTTPRequest.file_stream";

NSString * const DDHTTPRequestStatusCodeDomain = @"com.DDHTTPRequest.response_statuscode";




@interface DDHTTPRequest() {
@private
    BOOL _executing;
    BOOL _finished;
    BOOL _cancelled;
    NSOutputStream * _fileStream;
}

@property(readwrite, nonatomic, strong) NSMutableURLRequest * request;
@property(readwrite, strong) NSHTTPURLResponse * response;
@property(readwrite, strong) NSError * error;
@property(readwrite, nonatomic, strong) NSURLConnection * connection;
@property(readwrite, strong) NSMutableData * responseData;
@property(readwrite, strong) NSNumber * fileSize;
@property(readwrite, strong) NSNumber * statusCode;
@property(nonatomic, strong) NSThread * requestThread;
@property(nonatomic, assign) BOOL executing;
@property(nonatomic, assign) BOOL finished;
@property(readwrite, assign) CGFloat progress;
@property(nonatomic, strong) NSFileManager * fm;
@property(nonatomic, strong) NSOutputStream * fileStream;
@property(readwrite, assign) NSUInteger bytesWritten;

- (id)initWithURL:(NSURL *)url;
- (void)httpMethod:(NSString*)method contentType:(NSString*)ct;
- (void)triggerConnection;
- (void)reportFailureWithError:(NSError *)error;
- (void)reportFailureWithDomain:(NSString *)code code:(NSInteger)code;
- (void)finish;
- (void)handleDownloadToDiskForData:(NSData *)data;
- (NSError *)removeTmpPath:(NSString *)path;
- (BOOL)validateTempDownloadDirectory;
- (NSString*)fileNameFromTmpDownloadPath;
- (BOOL)closeFileStream;
 
@end




@implementation DDHTTPRequest

@synthesize request       = _request;
@synthesize response      = _response;
@synthesize connection    = _connection;
@synthesize error         = _error;
@synthesize requestThread = _requestThread;
@synthesize fileSize      = _fileSize;


// NSMutableRequest Parameters / status
@synthesize responseData = _responseData;
@synthesize contentType = _contentType;
@synthesize statusCode = _statusCode;
@synthesize progress = _progress;


// NSOperation
@synthesize executing = _executing;
@synthesize finished  = _finished;


// Callback Blocks
@synthesize requestStartedBlock = _requestStartedBlock;
@synthesize dataHandlerBlock    = _dataHandlerBlock;
@synthesize completion          = _completion;
@synthesize failure             = _failure;


// Downloads
@synthesize fm = _fm;
@synthesize tmpDownloadPath = _tmpDownloadPath;
@synthesize downloadPath = _downloadPath;
@synthesize fileStream      = _fileStream;
@synthesize bytesWritten    = _bytesWritten;



#pragma NSOperationQueue
const NSUInteger kDefaultMaxConcurrentRequests = MAX_CONCURRENT;

+ (NSOperationQueue*)requestsOperationQueue {
    static NSOperationQueue* _requestsOperationQueue = nil;
    
    static dispatch_once_t ot;
    dispatch_once(&ot, ^{
        if(!_requestsOperationQueue) {
            _requestsOperationQueue = [NSOperationQueue new];
            [_requestsOperationQueue setMaxConcurrentOperationCount:kDefaultMaxConcurrentRequests];
        }
    });

    return _requestsOperationQueue;
}


#pragma NSOperation - NSURLConnection - RunLoop - Thread
+ (NSThread *)requestThread {
    
    static NSThread * _requestThread = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _requestThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(runLoopForRequestThread)
                                                   object:nil];
        [_requestThread start];
    });
    
    return _requestThread;
}

+ (void)runLoopForRequestThread {
    //  Keep run loop alive at all times. This is a
    //  shared run loop on which all requests will run.
    while (YES) [[NSRunLoop currentRunLoop] run];
}


#pragma - Class Initializers
+ (DDHTTPRequest *)getRequestForURL:(NSURL *)url {
    DDHTTPRequest * req = [[DDHTTPRequest alloc] initWithURL:url];
    [req httpMethod:HTTPGetMethod contentType:nil];
    return req;
}

+ (DDHTTPRequest *)postRequestForURL:(NSURL *)url {
    DDHTTPRequest * req = [[DDHTTPRequest alloc] initWithURL:url];
    [req httpMethod:HTTPPostMethod contentType:nil];
    return req;
}

+ (DDHTTPRequest *)postRequestForURL:(NSURL *)url contentType:(NSString*)ct {
    DDHTTPRequest * req = [[DDHTTPRequest alloc] initWithURL:url];
    [req httpMethod:HTTPPostMethod contentType:ct];
    return req;
}

+ (DDHTTPRequest *)putRequestForURL:(NSURL *)url contentType:(NSString*)ct {
    DDHTTPRequest * req = [[DDHTTPRequest alloc] initWithURL:url];
    [req httpMethod:HTTPPutMethod contentType:ct];
    return req;
}


#pragma mark - DDHTTPRequest Init
- (id)initWithURL:(NSURL *)url {
    
    if(self = [super init]) {
        self.fm = [NSFileManager new];
        self.request = [[NSMutableURLRequest alloc] initWithURL:url];
//        [self.request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];    //  TODO: implement caching.
        [self.request setTimeoutInterval:DDHTTPRequestTimeoutInterval];
    } 
    
    return self;
}

- (void)httpMethod:(NSString*)method contentType:(NSString*)ct {
    
    [self.request setHTTPMethod:method];
    
    // POST
    if([self.request.HTTPMethod.uppercaseString isEqualToString:HTTPPostMethod]) {
        self.contentType = [ct copy];
        
        if(self.contentType == nil) { 
            self.contentType = DDHTTPRequestConentTypeDefault;
            [self.request addValue:self.contentType forHTTPHeaderField:CONTENT_TYPE];
        }
        else {
            [self.request addValue:self.contentType forHTTPHeaderField:CONTENT_TYPE];
        }
    }
    
    //  PUT
    if([self.request.HTTPMethod.uppercaseString isEqualToString:HTTPPutMethod]) {
        self.contentType = [ct copy];
        if(self.contentType == nil) {
            self.contentType = DDHTTPRequestConentTypeDefault;
            [self.request addValue:self.contentType forHTTPHeaderField:CONTENT_TYPE];
        } else {
            [self.request addValue:self.contentType forHTTPHeaderField:CONTENT_TYPE];
        }
        
    }
}


#pragma mark - Triggers
- (void)sendAsyncWithCallback:(void(^)(DDHTTPRequest * request))block {

    [[DDHTTPRequest requestsOperationQueue] addOperation:self];
    
    self.completion = block;
    self.failure = block;
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] start %@ --> %@, to path: %@", self.request.HTTPMethod, self.request.URL, self.tmpDownloadPath);
    if(self.request.allHTTPHeaderFields)
        if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] %@: %@", NSLocalizedString(@"Request Content-Type set to: ", @"DDHTTPRequest Content-Type logging"),
              self.request.allHTTPHeaderFields);
    if(self.request.HTTPBody)
        if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] %@: %@", NSLocalizedString(@"Body set to: ", @"DDHTTPRequest body logging"), self.request.HTTPBody);
}


#pragma mark - NSMutableURLRequest Additional Setup
- (void)preparePostBodyFromDictionary:(NSDictionary *)dict {
    //  application/json case:
    if([self.contentType.lowercaseString isEqualToString:@"application/json"]) {
        [self.request setHTTPBody:[dict JSONData]];
        return;
    }
    
    NSAssert(0, @"Handle preparePostBodyFromDictionary for non-application/json cases!");
}

- (void)preparePutBodyFromDictionary:(NSDictionary *)dict {
    //  application/json case:
    if([self.contentType.lowercaseString isEqualToString:@"application/json"]) {
        [self.request setHTTPBody:[dict JSONData]];
        return;
    }
    
    NSAssert(0, @"Handle preparePutBodyFromDictionary for non-application/json cases!");
}

- (void)preparePostBodyFromData:(NSData*)pData {
    [self.request setHTTPBody:pData];
}

- (void)preparePutBodyFromData:(NSData*)pData {
    [self.request setHTTPBody:pData];
}

- (void)prepareRequestHeadersFromDictionary:(NSDictionary*)hDict {
    [self.request setAllHTTPHeaderFields:hDict];
    if(DEBUG_DDHTTP_REQ)  NSLog(@"[DEBUG_DDHTTP_REQ] Request headers set to: %@", hDict);
}


#pragma mark - NSOperation
- (BOOL)isConcurrent {
    //  (YES) prevents NSOperationQueue from creating a new
    //  thread for each NSOperation added onto it.
    return YES;
}

- (BOOL)isReady {
    return [super isReady];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (void)start {
    if([self isCancelled]) {
        [self performSelector:@selector(triggerConnection) 
                     onThread:[[self class] requestThread]
                   withObject:nil 
                waitUntilDone:NO 
                        modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        return;
    }
    
    if([self isReady]) {
        
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self performSelector:@selector(triggerConnection) 
                     onThread:[[self class] requestThread]
                   withObject:nil 
                waitUntilDone:NO 
                        modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}

- (void)triggerConnection {
    if([self isCancelled]) {
        [self finish];
    } 
    else {
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                          delegate:self
                                                  startImmediately:NO];
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] 
                                   forMode:NSRunLoopCommonModes];
        [self.connection start];
    }
}

- (void)finish {
    [self closeFileStream]; //  close file stream if one is found
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] REQUEST FINISHED - %@", self.request.URL);
}

- (void)cancel {
    if(![self isFinished] && ![self isCancelled]) {
        [super cancel];
        if(self.connection) {
            [self.connection cancel];
            //  TODO: If the operation is cancelled we should report an error.
            //  the operation should simply abort and do nothing. Is this going
            //  to cause problems for requests callbacks in services? Tested. Seems
            //  good for now.
//            [self reportFailureWithDomain:NSURLErrorDomain 
//                                     code:NSURLErrorCancelled];
            if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] cancelled %@ --> %@, to path: %@", self.request.HTTPMethod, self.request.URL, self.tmpDownloadPath);
        }
    }
}


#pragma mark - Stream
- (BOOL)closeFileStream {
    if(self.fileStream) {
        [self.fileStream close];
        
        if([self.fileStream streamStatus] != NSStreamStatusClosed) {
            if(DEBUG_DDHTTP_REQ)  NSLog(@"[DEBUG_DDHTTP_REQ] Could not close download file streamt! Filestream status: %d",[self.fileStream streamStatus]);
            return NO;
        }
        
        if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] %@", NSLocalizedString(@"Closed download file stream", @"DDHTTPRequest closing stream logging"));
        return YES;
    }
    return YES;
}


#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
        if(self.requestStartedBlock)
        self.requestStartedBlock(self);
    
    self.response = (NSHTTPURLResponse *)response;
    self.statusCode = [NSNumber numberWithInt:[self.response statusCode]];
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] Connection RESPONSE HEADER FIELDS: %@", [self.response allHeaderFields]);
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] %@: %@", NSLocalizedString(@"RESPONSE CODE", "Response code logging"), self.statusCode);
    
    if([self.statusCode intValue] != HTTPStatusOK) {
        [self reportFailureWithDomain:DDHTTPRequestStatusCodeDomain
                                 code:DDHTTPRequestErrorStatusCode];
        return;
    }
    
    self.fileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
    self.responseData = [NSMutableData data];
    [self.responseData setLength:0];
    self.progress = 0.0;
    self.bytesWritten = 0;
    
    //  If a temp download path is set then clean up path if already found on disk.
    //  We do not want to append data to an already existing path through the stream.
    if(self.tmpDownloadPath) {
        NSError * removeError = [self removeTmpPath:self.tmpDownloadPath];
 
        if(removeError) 
            [self reportFailureWithError:removeError];
    }
    
    if(![self validateTempDownloadDirectory]) {
        if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] Cannot use download path!");
        [self reportFailureWithDomain:DDHTTPRequestStatusCodeDomain
                                 code:DDHTTPRequestErrorStatusInvalidDownloadPath];
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if(self.tmpDownloadPath != nil && [self.tmpDownloadPath length] !=0 ) {
        // Write directly to file!
        [self handleDownloadToDiskForData:data];
    }
    else {
        [self.responseData appendData:data];
        self.bytesWritten = [self.responseData length];
    }
    
    self.progress = (CGFloat)[self bytesWritten] / [self.fileSize doubleValue];
    
    //  Report progress only if feature is enabled
    if(self.dataHandlerBlock) self.dataHandlerBlock(self);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self reportFailureWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] completed %@ --> %@, to path: %@", self.request.HTTPMethod, self.request.URL, self.tmpDownloadPath);
    
    [self closeFileStream]; //  close file stream if one is found
    
    //  move downloaded file to downloadsPath
    if(![self moveTmpDownloadedFileToDownloads]) {
        if(self.failure) self.failure(self);
        [self finish];
        return;
    }

    if(self.completion)  self.completion(self);
    
    [self finish];
}


#pragma mark - State Handling
- (void)reportFailureWithError:(NSError *)error {
    
    self.error = error;
    self.progress = 0.0;
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] Will report Error in DDHTTPRequest! <%@>", self.error);
    
    self.completion = nil;
    self.dataHandlerBlock = nil;
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] failed %@ --> %@, to path: %@", self.request.HTTPMethod, self.request.URL, self.tmpDownloadPath);
    if(self.failure) self.failure(self);
    self.failure = nil;
    
    [self finish];    
}

- (void)reportFailureWithDomain:(NSString *)domain code:(NSInteger)code {
    NSError * error = [[NSError alloc] initWithDomain:domain 
                                                 code:code 
                                             userInfo:nil];
    [self reportFailureWithError:error];
}


#pragma mark - response
- (id)responseJSON {
    id object = [self.responseData objectFromJSONData];
    return object;
}

- (NSString *)responseStringValueUTF8Encoding {
    //  This can be used for example to read non-JSON-like responses
    return [[NSString alloc] initWithData:self.responseData 
                                 encoding:NSUTF8StringEncoding];
}

- (UIImage *)responseDataToImage {
    return [UIImage imageWithData:self.responseData];
}


#pragma mark - Download To disk
- (BOOL)validateTempDownloadDirectory {

    // make sure we can write to the specified path:
    if(![self.fm fileExistsAtPath:[DDHTTPRequest tmpDownloadsPath]]) {
        NSError* error;
        BOOL created = [self.fm createDirectoryAtPath:[DDHTTPRequest tmpDownloadsPath]
                     withIntermediateDirectories:YES attributes:nil error:&error];
        if(!created) {
            NSAssert(created, @"[DEBUG_DDHTTP_REQ] Unable to create tmpDownloadsPath! This should not happen. FIX");
            if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] Could not crate tmpDownloadsPath!");
            return NO;
        }
    }
    
    return YES;
}

- (void)handleDownloadToDiskForData:(NSData *)data {
    
    NSOutputStream * fileStream = [self fileStream];
    NSStreamStatus status = [fileStream streamStatus];
    
    if(status == NSStreamStatusNotOpen) {
        [self reportFailureWithDomain:DDHTTPRequestFileStreamDomain 
                                 code:DDHTTPRequestErrorOpenStreamFailure];
        return;
    }
    else if(status == NSStreamStatusError) {
        [self reportFailureWithDomain:DDHTTPRequestFileStreamDomain 
                                 code:DDHTTPRequestErrorStreamError];
        return;
    }
    
    if(![fileStream hasSpaceAvailable]) {
        [self reportFailureWithDomain:DDHTTPRequestFileStreamDomain
                                 code:DDHTTPRequestErrorStreamHasNoSpace];
        return;
    }
    
    self.bytesWritten += [fileStream write:[data bytes] 
                                 maxLength:[data length]];
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] Bytes written!: %d, Filestream status: %d", self.bytesWritten,[self.fileStream streamStatus]);
}


#pragma mark - Paths
+ (NSString*)documentsPath {
    NSString* docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                              NSUserDomainMask, 
                                                              YES) objectAtIndex:0] copy];
    if(DEBUG_DDHTTP_REQ) NSLog(@"[DEBUG_DDHTTP_REQ] %@: %@", NSLocalizedString(@"Documents path: ", @"Application documents path logging"), docPath);
    return docPath;
}

+ (NSString *)tmpDownloadsPath {
    
    NSString* dTmpPath = [[DDHTTPRequest documentsPath] stringByAppendingPathComponent:kDefaultTempDownloadsDirectory];
    NSFileManager* fMngr = [[NSFileManager alloc] init];
    //  Make sure we have a usable temp download path
    if(![fMngr fileExistsAtPath:dTmpPath isDirectory:NO]) {
        //  Create the path!
        NSError* createError;
        if(![fMngr createDirectoryAtPath:dTmpPath withIntermediateDirectories:YES attributes:nil error:&createError]) {
            if(DEBUG_DDHTTP_REQ) NSLog(@"Error trying to create download path in DDHTTPRequest! <%@>", createError);
            return nil;
        }
    }
    return dTmpPath;
    
}

+ (NSString *)downloadsPath {
    NSString* dPath = [[DDHTTPRequest documentsPath] stringByAppendingPathComponent:kDefaultDownloadsDirectory];
    NSFileManager* fMngr = [[NSFileManager alloc] init];
    //  Make sure we have a usable downloadpath
    if(![fMngr fileExistsAtPath:dPath isDirectory:NO]) {
        //  Create the path!
        NSError* createError;
        if(![fMngr createDirectoryAtPath:dPath withIntermediateDirectories:YES attributes:nil error:&createError]) {
            if(DEBUG_DDHTTP_REQ) NSLog(@"Error trying to create download path in DDHTTPRequest! <%@>", createError);
            return nil;
        }
    }
    
    return dPath;
}

+ (NSString *)tmpDownloadPathForFileName:(NSString*)filename {
    return [[DDHTTPRequest tmpDownloadsPath] stringByAppendingPathComponent:filename];
}

+ (NSString *)downloadPathForFileName:(NSString*)filename {
    return [[DDHTTPRequest downloadsPath] stringByAppendingPathComponent:filename];
}

- (NSString *)downloadPath {
    if(_downloadPath) return _downloadPath;
    NSString* downloadDirectoryPath = [DDHTTPRequest downloadsPath];
    _downloadPath = [downloadDirectoryPath stringByAppendingPathComponent:[self fileNameFromTmpDownloadPath]];
    return _downloadPath;
}

- (NSError *)removeTmpPath:(NSString *)path {
    
    // remove file found at path in case there is one!
    if([self.fm fileExistsAtPath:self.tmpDownloadPath]) {
        NSError * removeError = nil;    
        if(![self.fm removeItemAtPath:self.tmpDownloadPath error:&removeError]) {
            if(DEBUG_DDHTTP_REQ) NSLog(@"Error trying to remove tmpDownload path in DDHTTPRequest! <%@>", removeError);
            return removeError;
        }
    }
    
    return nil;
}

- (NSString*)fileNameFromTmpDownloadPath {
    if(_tmpDownloadPath == nil) return nil;
    
    NSString* filename = [_tmpDownloadPath lastPathComponent];
    if([filename isEqualToString:kDefaultTempDownloadsDirectory]) {
        //  no file name was attached to temp download path
        return nil;
    }
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"filename from tmp downloads path: %@", filename);
    
    return filename;
}

- (BOOL)moveTmpDownloadedFileToDownloads {
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"Will try to move temp file: <%@> to download destination: <%@>", _tmpDownloadPath, self.downloadPath);    
    
    //  If download path already exists remove it
    // remove file found at path in case there is one!
    if([self.fm fileExistsAtPath:self.downloadPath]) {
        NSError * removeError = nil;    
        if(![self.fm removeItemAtPath:self.downloadPath error:&removeError]) {
            if(DEBUG_DDHTTP_REQ) NSLog(@"Error trying to remove downloadPath in DDHTTPRequest! <%@>", removeError);
            return NO;
        }
    }
    
    if(!_tmpDownloadPath) return NO;
    
    NSError* moveError;
    if(![_fm moveItemAtPath:_tmpDownloadPath toPath:self.downloadPath error:&moveError]) {
        NSError * error = [[NSError alloc] initWithDomain:DDHTTPRequestStatusCodeDomain 
                                                     code:DDHTTPRequestErrorStatusMoveToDownloadPath 
                                                 userInfo:nil];
        self.error = error;
        if(_error)
        if(DEBUG_DDHTTP_REQ) NSLog(@"Could not move temp file: <%@> to download destination: <%@>", _tmpDownloadPath, _downloadPath);
        
        return NO;
    }
    
    if(DEBUG_DDHTTP_REQ) NSLog(@"Moved temp file: <%@> to download destination: <%@>", _tmpDownloadPath, _downloadPath);
    return YES;
    
}


#pragma mark - Misc. getters
- (NSOutputStream *)fileStream {
    
    //  NSLog(@"TMP FILE DOWNLOAD!: %@", self.tmpDownloadPath);
    //  can't open the file stream if the file path is not valid.
    if(self.tmpDownloadPath == nil || [self.tmpDownloadPath length] == 0) return nil;

    NSAssert(self.tmpDownloadPath, @"Cannot initialize file stream! Invalid tmpdowloadPath");
    if(!_fileStream) {
        _fileStream = [[NSOutputStream alloc] initToFileAtPath:self.tmpDownloadPath append:YES];
        [_fileStream open];
        
        if([_fileStream streamStatus] == 2)
            if(DEBUG_DDHTTP_REQ) NSLog(@"Filestream opened to tmp path: %@", _tmpDownloadPath);
    }
    
    return _fileStream;
}


#pragma mark - Cleanup   [JUST TESTING]
- (void)dealloc {
    //  Keep for debugging for now.
    if(DEBUG_DDHTTP_REQ) NSLog(@"%@ DEALLOCATED", [self class]);
}

@end
