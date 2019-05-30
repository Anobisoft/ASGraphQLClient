//
//  ASGraphQueryPrivate.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 27.10.2017.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASGraphQuery(Protected)

@property (readonly) NSData *representationData;
@property (readonly) NSData *representationJSONData;

@end
