//
//  ASGraphQLClient.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASGraphQLClient/ASGraphQuery.h>
#import <ASGraphQLClient/ASGraphQLClientServerReachabilityUIDelegate.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ASGraphQLClientErrorDomain;

@interface ASGraphQLClient : NSObject <Abstract>

@property (class) NSURL *APIURL;
@property (class) NSString *APIURLString;
@property (class) NSTimeInterval defaultTimeout;
@property (class) id<ASGraphQLClientServerReachabilityUIDelegate> UIDelegate;

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock;

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock;


@end

NS_ASSUME_NONNULL_END
