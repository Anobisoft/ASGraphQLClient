//
//  ASGraphQLClientUIDelegate.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 02.11.2017.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASGraphQLClientUIDelegate <NSObject>

- (void)showServerNotReachableAlert;
- (void)hideServerNotReachableAlert;

@end
