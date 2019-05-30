//
//  ASGraphQuery.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnobiKit/AKObjectMapping.h>

@interface ASGraphQuery : NSObject

+ (instancetype)queryWithName:(NSString *)qname;
+ (instancetype)queryWithString:(NSString *)query;

@property (strong) NSDictionary<NSString *, id> *variables;

@end
