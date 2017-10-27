//
//  ASGraphQLClient.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQLClient.h"
//#import <AFNetworking/AFNetworking.h>
#import <AnobiKit/AKConfig.h>
#import "ASGraphQueryPrivate.h"

@implementation ASGraphQLClient

//static AFHTTPSessionManager *manager;
static NSURLSession *session;
static NSURLSessionConfiguration *sessionConfig;

static NSURL *_APIURL;
+ (NSURL *)APIURL {
    return _APIURL;
}
+ (void)setAPIURL:(NSURL *)APIURL {
    _APIURL = APIURL;
}
+ (void)setAPIURLString:(NSString *)APIURLString {
    self.APIURL = [NSURL URLWithString:APIURLString];
}

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

+ (void)initialize {
    [super initialize];
   
//    manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    @try {
        self.APIURLString = [AKConfig<NSDictionary *> configWithName:self.class.description][@"APIURL"];
        self.defaultTimeoutNumber = [AKConfig<NSDictionary *> configWithName:self.class.description][@"defaultTimeout"];
    } @catch (NSException *exception) {
        NSLog(@"[NOTICE] Exception: %@", exception);
    }
    
    sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableDictionary *HTTPAdditionalHeaders = sessionConfig.HTTPAdditionalHeaders.mutableCopy;
    HTTPAdditionalHeaders[@"Content-Type"] = @"application/x-www-form-urlencoded; charset=UTF-8";
    HTTPAdditionalHeaders[@"Accept-Encoding"] = @"gzip, deflate";
    if (self.defaultTimeout) {
        sessionConfig.timeoutIntervalForRequest = self.defaultTimeout;
    }    
//    sessionConfig.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    session = [NSURLSession sessionWithConfiguration:sessionConfig];


}



+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    return [self query:query timeout:0 fetchBlock:fetchBlock];
}

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    
    if (!self.APIURL) @throw [NSException exceptionWithName:NSUndefinedKeyException
                                                     reason:@"APIURL undefined"
                                                   userInfo:@{NSLocalizedRecoverySuggestionErrorKey : @"Check ASGraphQLClient.plist or define APIURL with one of available methods"}];
    
    NSMutableURLRequest *request = timeout ? [NSMutableURLRequest requestWithURL:self.APIURL cachePolicy:0 timeoutInterval:timeout] : [NSMutableURLRequest requestWithURL:self.APIURL];
    request.HTTPMethod = @"POST";
    NSError *serializationError;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:query.representation options:0 error:&serializationError];
    NSURLSessionDataTask *task = nil;
    if (serializationError) {
        NSLog(@"[ERROR] %@", serializationError);
    } else {
        task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *deserializationError;
            id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&deserializationError];
            if (deserializationError) {
                NSLog(@"[ERROR] %@", deserializationError);
            }
            if (JSONObject) {
                NSDictionary *data = JSONObject[@"data"];
                NSDictionary *errorInfo = JSONObject[@"error"];
                NSError *error = nil;
                if (errorInfo) error = [NSError errorWithDomain:@"ASGraphQLClient" code:0 userInfo:errorInfo];
                fetchBlock(data, error);
            } else {
                fetchBlock(nil, error);
            }
        }];
        [task resume];
    }

    
//    NSURLSessionDataTask *task = [manager POST:APIURLString parameters:query.representation progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//        NSDictionary *data = responseObject[@"data"];
//        NSDictionary *errorInfo = responseObject[@"error"];
//        NSError *error = nil;
//        if (errorInfo) error = [NSError errorWithDomain:@"ASGraphQL" code:0 userInfo:errorInfo];
//        fetchBlock(data, error);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        fetchBlock(nil, error);
//    }];
    
    return task;
}


@end
