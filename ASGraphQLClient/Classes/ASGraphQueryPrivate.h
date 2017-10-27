//
//  ASGraphQueryPrivate.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.10.2017.
//

#import <Foundation/Foundation.h>

@protocol ASGraphQueryPrivate <NSObject>
@property (readonly) NSDictionary *representation;

@end

@interface ASGraphQuery(Private) <ASGraphQueryPrivate>

@end
