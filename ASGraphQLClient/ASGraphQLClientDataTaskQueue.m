//
//  ASGraphQLClientDataTaskQueue.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 02.11.2017.
//

#import "ASGraphQLClientDataTaskQueue.h"
#import <AnobiKit/AKReachability.h>

@interface ASGraphQLClientDataTaskQueue() <AKReachabilityDelegate>
@property (nonatomic, readonly) AKReachability *serverReachability;
@property (nonatomic, readonly) NSMutableArray<NSURLSessionDataTask *> *suspendedTasks;
@property (nonatomic) NSURL *URL;
@end

@implementation ASGraphQLClientDataTaskQueue

#pragma mark -
#pragma mark - Instantiation

+ (instancetype)instantiateWithURL:(NSURL *)URL {
    return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        self.URL = URL;
    }
    return self;
}

@synthesize serverReachability = _serverReachability;
- (AKReachability *)serverReachability {
    if (!_serverReachability) {
        _serverReachability = [AKReachability reachabilityWithHostname:self.URL.host];
        _serverReachability.delegate = self;
    }
    return _serverReachability;
}

@synthesize suspendedTasks = _suspendedTasks;
- (NSMutableArray<NSURLSessionDataTask *> *)suspendedTasks {
    if (!_suspendedTasks) {
        _suspendedTasks = [NSMutableArray new];
    }
    return _suspendedTasks;
}

#pragma mark -

- (void)enqueueTask:(NSURLSessionDataTask *)task {
    if (self.serverReachability.currentStatus) {
        [task resume];
    } else {
        [self.suspendedTasks addObject:task];
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
    if (!_suspendedTasks) return ;
    if (status) {
        for (NSURLSessionDataTask *task in self.suspendedTasks) {
            [task resume];
        }
        [self.suspendedTasks removeAllObjects];
    }
    if (self.UIDelegate && status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.UIDelegate hideServerNotReachableAlert];
        });
    }
}



@end
