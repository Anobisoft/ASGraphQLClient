//
//  ASGraphQLClientDataTaskQueue.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 02.11.2017.
//

#import <Foundation/Foundation.h>
#import <AnobiKit/AKTypes.h>
#import <ASGraphQLClient/ASGraphQLClientUIDelegate.h>

@interface ASGraphQLClientDataTaskQueue : NSObject <DisableNSInit>

+ (instancetype)instantiateWithAPIURL:(NSURL *)APIURL;
- (void)enqueueTask:(NSURLSessionDataTask *)task;
@property (weak) id<ASGraphQLClientUIDelegate> UIDelegate;

@end
