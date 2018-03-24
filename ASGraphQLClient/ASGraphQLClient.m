//
//  ASGraphQLClient.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQLClient.h"
#import "ASGraphQueryProtected.h"
#import "ASGraphQLClientDataTaskQueue.h"

NSString * const ASGraphQLClientErrorDomain = @"ASGraphQLClient";

@interface ASGraphQLClient()
@property (nonatomic) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) ASGraphQLClientDataTaskQueue *taskQueue;
@end

@implementation ASGraphQLClient {

}

+ (instancetype)clientWithURL:(NSURL *)URL {
    if (!URL) return nil;
    return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        _APIURL = URL;
        self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableDictionary *mutableHTTPAdditionalHeaders = self.sessionConfig.HTTPAdditionalHeaders.mutableCopy;
        mutableHTTPAdditionalHeaders[@"Content-Type"] = @"application/x-www-form-urlencoded; charset=UTF-8";
        mutableHTTPAdditionalHeaders[@"Accept-Encoding"] = @"gzip, deflate";
        self.sessionConfig.HTTPAdditionalHeaders = mutableHTTPAdditionalHeaders;
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfig];        
        self.taskQueue = [ASGraphQLClientDataTaskQueue instantiateWithURL:self.APIURL];
    }
    return self;
}


- (id<ASGraphQLClientUIDelegate>)UIDelegate {
    return self.taskQueue.UIDelegate;
}

- (void)setUIDelegate:(id<ASGraphQLClientUIDelegate>)UIDelegate {
    self.taskQueue.UIDelegate = UIDelegate;
}

- (NSTimeInterval)defaultTimeout {
    return self.sessionConfig.timeoutIntervalForRequest;
}

- (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
    self.sessionConfig.timeoutIntervalForRequest = self.defaultTimeout;
}

- (void)setAuthToken:(NSString *)authToken {
    NSMutableDictionary *headers = self.sessionConfig.HTTPAdditionalHeaders.mutableCopy;
    headers[@"Authorization"] = [NSString stringWithFormat:@"token %@", authToken];
    self.sessionConfig.HTTPAdditionalHeaders = headers;
}

#pragma mark -
#pragma mark - Request

- (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    return [self query:query timeout:0 fetchBlock:fetchBlock];
}

- (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
   
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.APIURL];
    if (timeout) request.timeoutInterval = timeout;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query representationData];
    NSURLSessionDataTask *task = nil;
    task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    
    [self.taskQueue enqueueTask:task];
    
    return task;
}


@end
