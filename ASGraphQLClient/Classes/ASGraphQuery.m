//
//  ASGraphQuery.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQuery.h"

#define ASGraphQueryFileExt @"graphql"

@implementation ASGraphQuery {
	NSString *name;
}

static NSMutableDictionary *instancesCache;

+ (void)initialize {
	[super initialize];
    instancesCache = [NSMutableDictionary new];
}

+ (instancetype)queryWithName:(NSString *)qname;  {
    if (!qname.length) return nil;
    id instance = instancesCache[qname];
    if (instance) return instance;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:qname ofType:ASGraphQueryFileExt];
    BOOL isDirectory;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (filePath && fileExists && !isDirectory) {
        instance == [[self alloc] initWithFilePath:(NSString *)filePath];
        instancesCache[qname] = instance;
        return instance;
    } else {
        NSLog(@"[ERROR] filePath '%@' %@exists, is %@directory", filePath, fileExists ? @"" : @"not ", isDirectory ? @"" : @"not ");
    }
    return nil;
}

- (instancetype)initWithFilePath:(NSString *)filePath {    
    if (self = [super init]) {
        NSError *error = nil;
        _string = [NSString stringWithContentsOfFile:filePath
                                            encoding:NSUTF8StringEncoding
                                               error:&error];
        if (error) {
            NSLog(@"[ERROR] %@", error);
        }
    }
    return self;
}

- (NSUInteger)hash {
	return self.string.hash ^ _variables.hash;
}

@end
