//
//  ASGraphQLClient.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQLClient.h"
#import <AnobiKit/AKConfig.h>
#import "ASGraphQueryPrivate.h"
#import "ASGraphQLClientDataTaskQueue.h"

NSString * const ASGraphQLClientErrorDomain = @"ASGraphQLClient";

@implementation ASGraphQLClient

static NSURLSession *session;
static NSURLSessionConfiguration *sessionConfig;
static ASGraphQLClientDataTaskQueue *taskQueue;
static NSException * AKUndefinedAPIURLException;

#pragma mark -
#pragma mark - UIDelegate

+ (id<ASGraphQLClientServerReachabilityUIDelegate>)UIDelegate {
    return taskQueue.UIDelegate;
}
+ (void)setUIDelegate:(id<ASGraphQLClientServerReachabilityUIDelegate>)UIDelegate {
    if (taskQueue) taskQueue.UIDelegate = UIDelegate;
    else @throw AKUndefinedAPIURLException;
}

#pragma mark -
#pragma mark - APIURL Properties

static NSURL *_APIURL;
static NSString *_APIURLString;
+ (NSURL *)APIURL {
    return _APIURL;
}
+ (NSString *)APIURLString {
    return _APIURLString;
}
+ (void)setAPIURL:(NSURL *)APIURL {
    _APIURL = APIURL;
    _APIURLString = [APIURL absoluteString];
    taskQueue = [ASGraphQLClientDataTaskQueue instantiateWithAPIURL:_APIURL];
}
+ (void)setAPIURLString:(NSString *)APIURLString {    
    _APIURL = [NSURL URLWithString:APIURLString];
    _APIURLString = APIURLString;
    taskQueue = [ASGraphQLClientDataTaskQueue instantiateWithAPIURL:_APIURL];
}

#pragma mark -
#pragma mark - DefaultTimeout Property

static NSTimeInterval _defaultTimeout;
+ (NSTimeInterval)defaultTimeout {
    return _defaultTimeout;
}
+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
    _defaultTimeout = defaultTimeout;
}
+ (void)setDefaultTimeoutNumber:(NSNumber *)number {
    self.defaultTimeout = [number doubleValue];
}

#pragma mark -
#pragma mark - Initialization

+ (void)initialize {
    [super initialize];
    AKUndefinedAPIURLException = [NSException exceptionWithName: NSUndefinedKeyException
                                                         reason: @"APIURL undefined"
                                                       userInfo: @{ NSLocalizedRecoverySuggestionErrorKey : @"Check ASGraphQLClient.plist or define APIURL with one of available methods:\n  \
                                                                        +setAPIURL:\n  \
                                                                        +setAPIURLString:" } ];
    @try {
        self.APIURLString = [AKConfig<NSDictionary *> configWithName:self.class.description][@"APIURL"];
        self.defaultTimeoutNumber = [AKConfig<NSDictionary *> configWithName:self.class.description][@"defaultTimeout"];
    } @catch (NSException *exception) {
        NSLog(@"[NOTICE] Exception: %@", exception);
    }

    sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSMutableDictionary *mutableHTTPAdditionalHeaders = sessionConfig.HTTPAdditionalHeaders.mutableCopy;
    mutableHTTPAdditionalHeaders[@"Content-Type"] = @"application/x-www-form-urlencoded; charset=UTF-8";
    mutableHTTPAdditionalHeaders[@"Accept-Encoding"] = @"gzip, deflate";
    sessionConfig.HTTPAdditionalHeaders = mutableHTTPAdditionalHeaders;
    
    if (self.defaultTimeout) {
        sessionConfig.timeoutIntervalForRequest = self.defaultTimeout;
    }
    
    session = [NSURLSession sessionWithConfiguration:sessionConfig];

}

#pragma mark -
#pragma mark - Request

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    return [self query:query timeout:0 fetchBlock:fetchBlock];
}

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    
    if (!self.APIURL) @throw AKUndefinedAPIURLException;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.APIURL];
    if (timeout) request.timeoutInterval = timeout;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query representationData];
    NSURLSessionDataTask *task = nil;
    task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        if (error) NSLog(@"[ERROR] dataTaskWithRequest completed with error: %@", error);
        if (httpResp.statusCode == 200) {
            NSError *deserializationError;
            id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
            if (deserializationError) NSLog(@"[ERROR] NSJSONSerialization error: %@", deserializationError);
            if (JSONObject) {
                NSDictionary *data = JSONObject[@"data"];
                NSDictionary *errorInfo = JSONObject[@"error"];
                NSError *graphQLError = nil;
                if (errorInfo) graphQLError = [NSError errorWithDomain:ASGraphQLClientErrorDomain code:0x0001 userInfo:@{NSLocalizedFailureReasonErrorKey: errorInfo}];
                fetchBlock(data, graphQLError ?: deserializationError ?: error);
            } else {
                fetchBlock(nil, deserializationError ?: error);
            }
        } else {
            if (error) {
                fetchBlock(nil, error);
            } else {
                NSError *unexpectedStatusError = [NSError errorWithDomain:ASGraphQLClientErrorDomain code:0x0002 userInfo:@{NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"Unexpected status code: %ld\n%@", (long)httpResp.statusCode, httpResp.allHeaderFields] } ];
                fetchBlock(nil, unexpectedStatusError);
            }
        }
    }];
    
    [taskQueue enqueueTask:task];
    
    return task;
}


@end
