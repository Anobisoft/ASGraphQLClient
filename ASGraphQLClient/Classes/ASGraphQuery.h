//
//  ASGraphQuery.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnobiKit/AKTypes.h>

@interface ASGraphQuery : NSObject <DisableNSInit>

@property (strong) NSDictionary<NSString *, id> *variables;

+ (instancetype)queryWithName:(NSString *)qname;

@end
