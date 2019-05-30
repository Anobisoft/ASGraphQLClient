//
//  ASGraphQLClient.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASGraphQLClient/ASGraphQuery.h>
#import <ASGraphQLClient/ASGraphQLClientUIDelegate.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ASGraphQLClientType) {
    ASGraphQLAPITypeJSON,
    ASGraphQLAPITypeQuery,
};

extern NSString * const ASGraphQLClientErrorDomain;

@interface ASGraphQLClient : NSObject

@property (nonatomic, readonly) NSURL *APIURL;
@property (nonatomic, nullable) NSString *authHeaderValue;
@property (nonatomic) ASGraphQLClientType APIType;

@property (nonatomic) NSTimeInterval defaultTimeout;
@property (nonatomic, nullable) id<ASGraphQLClientUIDelegate> UIDelegate;

+ (instancetype)clientWithURL:(NSURL *)URL;

- (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                     fetchBlock:(void (^)(NSDictionary * _Nullable data, NSError * _Nullable error))fetchBlock;

- (NSURLSessionDataTask *)query:(ASGraphQuery *)query
                        timeout:(NSTimeInterval)timeout
                     fetchBlock:(void (^)(NSDictionary * _Nullable data, NSError * _Nullable error))fetchBlock;


@end

NS_ASSUME_NONNULL_END
