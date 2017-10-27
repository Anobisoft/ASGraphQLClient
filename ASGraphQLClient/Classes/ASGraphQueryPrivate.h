//
//  ASGraphQueryPrivate.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.10.2017.
//

#import <Foundation/Foundation.h>

@protocol ASGraphQueryPrivate <NSObject>
@property (readonly) NSData *representationData;
@end

@interface ASGraphQuery(Private) <AKObjectReverseMapping, ASGraphQueryPrivate>

@end
