//
//  ASGraphQuery.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASGraphQuery.h"
#import "ASGraphQueryProtected.h"

#define ASGraphQueryFileExt @"graphql"

@interface ASGraphQuery() <AKObjectReverseMapping>
@end

@implementation ASGraphQuery {
    NSString *_query;
}

#pragma mark -
#pragma mark - Instantiation


+ (NSMutableDictionary *)instancesCache {
    static NSMutableDictionary *_instancesCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instancesCache = [NSMutableDictionary new];
    });
    return _instancesCache;
}

+ (instancetype)queryWithString:(NSString *)query {
    return [[self alloc] initWithString:query];
}

- (instancetype)initWithString:(NSString *)query {
    if (self = [super init]) {
        _query = query;
    }
    return self;
}

+ (instancetype)queryWithName:(NSString *)qname {
    if (!qname.length) return nil;
    id instance = self.instancesCache[qname];
    if (instance) return instance;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:qname ofType:ASGraphQueryFileExt];
    BOOL isDirectory;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (filePath && fileExists && !isDirectory) {
        instance = [[self alloc] initWithFilePath:(NSString *)filePath];
        self.instancesCache[qname] = instance;
        return instance;
    } else {
        NSLog(@"[ERROR] filePath '%@' %@exists, is %@directory", filePath, fileExists ? @"" : @"not ", isDirectory ? @"" : @"not ");
    }
    return nil;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        NSError *error = nil;
        _query = [NSString stringWithContentsOfFile:filePath
                                           encoding:NSUTF8StringEncoding
                                              error:&error];
        if (error) {
            NSLog(@"[ERROR] %@", error);
        }
    }
    return self;
}

#pragma mark -
#pragma mark - AKObjectReverseMapping

- (NSDictionary *)keyedRepresentation {
    NSDictionary *parameters = @{@"query" : _query};
    if (self.variables) {
        NSMutableDictionary *mutable = parameters.mutableCopy;
        mutable[@"variables"] = self.variables;
        parameters = mutable.copy;
    }
    return parameters;
}

#pragma mark -
#pragma mark - Serialization

- (NSArray *)arrayWithKey:(NSString *)key value:(id)value {
    NSMutableArray *mutable = [NSMutableArray new];
    if ([value conformsToProtocol:@protocol(AKObjectReverseMapping)]) {
        id<AKObjectReverseMapping> reverseMapped = value;
        value = reverseMapped.keyedRepresentation;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = value;
        for (NSString *nestedKey in dict.allKeys) {
            [mutable addObjectsFromArray:[self arrayWithKey:(key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey) value:dict[nestedKey]]];
        }
    } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
        NSArray *array = value;
        for (id object in array) {
            [mutable addObjectsFromArray:[self arrayWithKey:[NSString stringWithFormat:@"%@[]", key] value:object]];
        }
    } else {
        [mutable addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return mutable.copy;
}

- (NSString *)representationString {
    NSString *params = [[self arrayWithKey:nil value:self] componentsJoinedByString:@"&"];
    return [params stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

#pragma mark -
#pragma mark - Comparation

- (NSUInteger)hash {
	return _query.hash ^ _variables.hash;
}

- (BOOL)isEqual:(ASGraphQuery *)object {
    if (![object.class isKindOfClass:self.class]) return false;
    if (object.hash != self.hash) return false;
    return [self.representationData isEqualToData:object.representationData];    
}

@end

#pragma mark -
#pragma mark - Protected

@implementation ASGraphQuery(Protected)

- (NSData *)representationData {
    return [self.representationString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)representationJSONData {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.keyedRepresentation options:0 error:&error];
    if (error) {
#ifdef DEBUG
        @throw error;
#else
        NSLog(@"[ERROR] NSJSONSerialization error: %@", error);
#endif
    }
    return data;
}

@end
