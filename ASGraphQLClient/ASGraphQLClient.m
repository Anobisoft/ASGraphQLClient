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

NSString * const ASGraphQLClientErrorDomain = @"com.anobisoft.graphQL.client";
NSString * const OAuthHeaderKey = @"Authorization";

@interface ASGraphQLClient()

@property (nonatomic) NSURLSessionConfiguration *sessionConfig;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) ASGraphQLClientDataTaskQueue *taskQueue;

@end


@implementation ASGraphQLClient

+ (instancetype)clientWithURL:(NSURL *)URL {
    if (!URL) return nil;
    return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        _APIURL = URL;
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:_sessionConfig];
        _taskQueue = [ASGraphQLClientDataTaskQueue instantiateWithURL:_APIURL];
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

- (void)setAuthHeaderValue:(NSString *)authValue {
    NSMutableDictionary *headers = self.sessionConfig.HTTPAdditionalHeaders.mutableCopy ?: [NSMutableDictionary new];
    headers[OAuthHeaderKey] = authValue;
    self.sessionConfig.HTTPAdditionalHeaders = headers;
    self.session = [NSURLSession sessionWithConfiguration:_sessionConfig];
}

- (NSString *)authHeaderValue {
    return self.sessionConfig.HTTPAdditionalHeaders[OAuthHeaderKey];
}

#pragma mark -
#pragma mark - Request

- (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError * _Nullable error))fetchBlock {
    
    return [self query:query timeout:0 fetchBlock:fetchBlock];
}

- (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError * _Nullable error))fetchBlock {
   
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.APIURL];
    if (timeout) {
        request.timeoutInterval = timeout;
    }
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.APIType == ASGraphQLAPITypeQuery ? query.representationData : [query representationJSONData];
    NSURLSessionDataTask *task = nil;
    task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[ERROR] dataTaskWithRequest completed with error: %@", error);
        }
        if (response) {
            [self handleResponse:(NSHTTPURLResponse *)response data:data withFetchBlock:fetchBlock];
        } else {
            fetchBlock(nil, error);
        }
    }];
    
    [self.taskQueue enqueueTask:task];
    
    return task;
}

- (void)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data withFetchBlock:(void (^)(NSDictionary * _Nullable data, NSError * _Nullable error))fetchBlock {
    
    id JSONObject = nil;
    if ([response.MIMEType isEqualToString:@"application/json"]) {
        NSError *deserializationError;
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
        if (deserializationError) {
            NSLog(@"[ERROR] NSJSONSerialization error: %@", deserializationError);
        }
        NSDictionary *JSONData = JSONObject[@"data"];
        NSDictionary *errorInfo = JSONObject[@"error"];
        NSError *graphQLError = nil;
        if (errorInfo) {
            graphQLError = [NSError errorWithDomain:ASGraphQLClientErrorDomain code:0x0001 userInfo:@{ NSLocalizedFailureReasonErrorKey: errorInfo}];
        }
        
        if (JSONData || graphQLError || deserializationError) {
            fetchBlock(JSONData, graphQLError ?: deserializationError);
            return;
        } else if (response.statusCode == 200) {
            NSError *error = [NSError errorWithDomain:ASGraphQLClientErrorDomain code:0x0983 userInfo:@{ NSLocalizedDescriptionKey : @"Empty response data" } ];
            fetchBlock(nil, error);
            return;
        }
    }
    
    if (response.statusCode != 200) {
        NSString *description = [NSString stringWithFormat:@"Unexpected status code: %ld", (long)response.statusCode];
        NSMutableDictionary *info = @{ @"HTTPHeaders" : response.allHeaderFields }.mutableCopy;
        info[@"JSONObject"] = JSONObject;
        info[@"Data"] = data;
        if (data) {
            info[@"Data"] = [NSString stringWithUTF8String:data.bytes];
        }
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
                                    NSLocalizedFailureReasonErrorKey : info, };
        NSError *unexpectedStatusError = [NSError errorWithDomain:ASGraphQLClientErrorDomain code:0x0002 userInfo:userInfo];
        fetchBlock(JSONObject, unexpectedStatusError);
    }
}

@end
