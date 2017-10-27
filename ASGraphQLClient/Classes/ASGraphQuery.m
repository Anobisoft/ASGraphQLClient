//
//  ASGraphQuery.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQuery.h"
#import "ASGraphQueryPrivate.h"

#define ASGraphQueryFileExt @"graphql"

@implementation ASGraphQuery {
    NSString *string;
}

static NSMutableDictionary *instancesCache;

+ (void)initialize {
	[super initialize];
    instancesCache = [NSMutableDictionary new];
}

- (NSArray *)arrayWithKey:(NSString *)key value:(id)value {
    NSMutableArray *mutable = [NSMutableArray new];
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = value;
        
        mutable addObjectsFromArray:[self arrayWithKey:[NSString stringWithFormat:@"%@[%@]", key, nestedKey] value]
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
    }
}

- (NSData *)representationData {
    
    return [NSData data];
}

- (NSDictionary *)keyedRepresentation {
    NSDictionary *parameters = @{@"query" : string};
    if (self.variables) {
        NSMutableDictionary *mutable = parameters.mutableCopy;
        mutable[@"variables"] = self.variables;
        parameters = mutable.copy;
    }
    return parameters;
}

+ (instancetype)queryWithName:(NSString *)qname;  {
    if (!qname.length) return nil;
    id instance = instancesCache[qname];
    if (instance) return instance;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:qname ofType:ASGraphQueryFileExt];
    BOOL isDirectory;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (filePath && fileExists && !isDirectory) {
        instance = [[self alloc] initWithFilePath:(NSString *)filePath];
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
        string = [NSString stringWithContentsOfFile:filePath
                                           encoding:NSUTF8StringEncoding
                                              error:&error];
        if (error) {
            NSLog(@"[ERROR] %@", error);
        }
    }
    return self;
}

- (NSUInteger)hash {
	return string.hash ^ _variables.hash;
}

@end
