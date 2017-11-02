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

+ (instancetype)instantiateWithAPIURL:(NSURL *)APIURL {
    return [[self alloc] initWithAPIURL:APIURL];
}

- (instancetype)initWithAPIURL:(NSURL *)APIURL {
    if (self = [super init]) {
        serverReachability = [AKReachability reachabilityWithHostname:APIURL.host];
        serverReachability.delegate = self;
        suspendedTasks = [NSMutableArray new];
    }
    return self;
}


- (void)reachability:(AKReachability *)reachability didChangeStatus:(AKReachabilityStatus)status {
    if (status && suspendedTasks) {
        for (NSURLSessionDataTask *task in suspendedTasks) {
            [task resume];
        }
    } else {
        suspendedTasks = [NSMutableArray new];
    }
    if (self.UIDelegate && status) {
        [self.UIDelegate hideServerNotReachableAlert];
    }
}

- (void)enqueueTask:(NSURLSessionDataTask *)task {
    if (serverReachability.currentStatus) {
        [task resume];
    } else {
        if (!suspendedTasks) suspendedTasks = [NSMutableArray new];
        [suspendedTasks addObject:task];
        if (self.UIDelegate) [self.UIDelegate showServerNotReachableAlert];
    }
}

@end
