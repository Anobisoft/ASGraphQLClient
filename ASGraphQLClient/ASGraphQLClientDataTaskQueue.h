//
//  ASGraphQLClientDataTaskQueue.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 02.11.2017.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASGraphQLClient/ASGraphQLClientUIDelegate.h>

@interface ASGraphQLClientDataTaskQueue : NSObject

@property (weak) id<ASGraphQLClientUIDelegate> UIDelegate;

+ (instancetype)instantiateWithURL:(NSURL *)URL;
- (void)enqueueTask:(NSURLSessionDataTask *)task;

- (instancetype)init NS_UNAVAILABLE;


@end
