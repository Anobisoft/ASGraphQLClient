//
//  ASGraphQuery.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnobiKit/AnobiKit.h>

@interface ASGraphQuery : NSObject <DisableNSInit>

@property (strong) NSDictionary *variables;

+ (instancetype)queryWithName:(NSString *)qname;

@end
