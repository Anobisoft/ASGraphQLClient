//
//  ASGraphQLClientDataTaskQueue.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 02.11.2017.
//

#import "ASGraphQLClientDataTaskQueue.h"
#import <AnobiKit/AKReachability.h>

@interface ASGraphQLClientDataTaskQueue(private) <AKReachabilityDelegate>
@end

@implementation ASGraphQLClientDataTaskQueue {
    AKReachability *serverReachability;
    NSMutableArray<NSURLSessionDataTask *> *suspendedTasks;
}

#pragma mark -
#pragma mark - Instantiation

+ (instancetype)instantiateWithAPIURL:(NSURL *)APIURL {
    return [[self alloc] initWithAPIURL:APIURL];
}

- (instancetype)initWithAPIURL:(NSURL *)APIURL {
    if (self = [super init]) {
        serverReachability = [AKReachability reachabilityWithHostname:APIURL.host];
        suspendedTasks = [NSMutableArray new];
        serverReachability.delegate = self;

    }
    return self;
}

#pragma mark -

- (void)enqueueTask:(NSURLSessionDataTask *)task {
    if (serverReachability.currentStatus) {
        [task resume];
    } else {
        if (!suspendedTasks) suspendedTasks = [NSMutableArray new];
        [suspendedTasks addObject:task];
        if (self.UIDelegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.UIDelegate showServerNotReachableAlert];
            });            
        }
    }
}

#pragma mark -
#pragma mark - AKReachabilityDelegate

- (void)reachability:(AKReachability *)reachability didChangeStatus:(AKReachabilityStatus)status {
    if (status) {
        for (NSURLSessionDataTask *task in suspendedTasks) {
            [task resume];
        }
        [suspendedTasks removeAllObjects];
    }
    if (self.UIDelegate && status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.UIDelegate hideServerNotReachableAlert];
        });
    }
}



@end
