//
//  ASAuthViewController.m
//  ASGraphQLClient_Example
//
//  Created by Stanislav Pletnev on 30/05/2019.
//  Copyright © 2019 Anobisoft. All rights reserved.
//

#import "ASAuthViewController.h"
#import <ASGraphQLClient/ASGraphQLClient.h>

@interface ASAuthViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tokenField;
@property ASGraphQLClient *client;

@end


@implementation ASAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tokenField.text = @"321358a7b6c1419739a31127f8a1593e32346d2b";
    NSURL *APIURL = [NSURL URLWithString:@"https://api.github.com/graphql"];
    self.client = [ASGraphQLClient clientWithURL:APIURL];
}

- (IBAction)submitAction:(id)sender {
    NSString *token = self.tokenField.text;
    if (token.length) {
        self.client.authHeaderValue = [NSString stringWithFormat:@"bearer %@", token];
        [self request];
    }
}

- (void)request {
    ASGraphQuery *query = [ASGraphQuery queryWithName:@"example"];
//    query.variables = @{ @"number_of_repos" : @3, };
    
    [self.client query:query fetchBlock:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        NSLog(@"data: %@", data);
        NSLog(@"error: %@", error);
    }];
}


@end
