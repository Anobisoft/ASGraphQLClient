//
//  ASGraphQLClientUIDelegate.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 02.11.2017.
//

#import <Foundation/Foundation.h>

@protocol ASGraphQLClientUIDelegate <NSObject>
- (void)showServerNotReachableAlert;
- (void)hideServerNotReachableAlert;
@end
