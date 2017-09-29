//
//  ASGraphQuery.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 26.07.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnobiKit/AnobiKit.h>

@interface ASGraphQuery : NSObject <DisableStdInstantiating>

@property (readonly) NSString *string;
@property (strong) NSDictionary *variables;

+ (instancetype)queryWithName:(NSString *)qname;

@end
