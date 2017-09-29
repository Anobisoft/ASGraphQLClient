//
//  ASGraphQLClient.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnobiKit/AnobiKit.h>
#import <ASGraphQLClient/ASGraphQuery.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASGraphQLClient : NSObject <Abstract>

+ (void)setAPIURLString:(NSString *)APIURL;

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock;

+ (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary  * _Nullable data, NSError  * _Nullable error))fetchBlock;


@end

NS_ASSUME_NONNULL_END
