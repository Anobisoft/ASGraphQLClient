//
//  ASGraphQLClient.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQLClient.h"
#import <AFNetworking/AFNetworking.h>
#import <AnobiKit/AKConfig.h>

@implementation ASGraphQLClient

static AFHTTPSessionManager *manager;
static NSString *APIURLString;

+ (void)initialize {
    [super initialize];
   
    manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    @try {
        APIURLString = [AKConfig<NSDictionary *> configWithName:self.class.description][@"APIURL"];
    } @catch (NSException *exception) {
        NSLog(@"[ERROR] Exception: %@", exception);
    }
}

+ (void)setAPIURLString:(NSString *)APIURL {
    APIURLString = APIURL;
}

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    return [self query:query timeout:0 fetchBlock:fetchBlock];
}

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock {
    
    if (!APIURLString.length || !query.string.length) return nil;
    
    NSDictionary *parameters = @{@"query" : query.string};
    if (query.variables) {
        NSMutableDictionary *md = parameters.mutableCopy;
        md[@"variables"] = query.variables;
        parameters = md.copy;
    }
    
    manager.requestSerializer.timeoutInterval = timeout ?: 30;
    
    NSURLSessionDataTask *task = [manager POST:APIURLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        NSDictionary *data = responseObject[@"data"];
        NSDictionary *errorInfo = responseObject[@"error"];
        NSError *error = nil;
        if (errorInfo) error = [NSError errorWithDomain:@"ASGraphQL" code:0 userInfo:errorInfo];
        fetchBlock(data, error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fetchBlock(nil, error);
    }];
    
    return task;
}


@end
