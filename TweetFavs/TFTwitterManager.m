//
//  TFTwitterManager.m
//  TweetFavs
//
//  Created by Javier Figueroa on 11/25/14.
//  Copyright (c) 2014 Mainloop LLC. All rights reserved.
//

#import "TFTwitterManager.h"
#import <Twitter/Twitter.h>

NSString *const TFGetAccounts = @"TFGetAccounts";
NSString *const TFAccountSelected = @"TFAccountSelected";

@implementation TFTwitterManager


+ (TFTwitterManager *) sharedManager {
    static TFTwitterManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TFTwitterManager alloc] init];
    });
    
    return _sharedManager;
}


- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) getTwitterAccounts:(void(^)(NSArray *accounts, NSError *error))completion
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(accountsArray, error);
            });
        }
    }];
}

- (void)getTweetById:(NSNumber *)tweetID completion:(void (^)(NSDictionary *tweet, NSError *error))completion
{
    assert(self.twitterAccount);
    
    SLRequest *getRequest  = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                              requestMethod:SLRequestMethodGET
                                                        URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/show.json"]
                                                 parameters:@{@"id":tweetID}];
    
    
    [getRequest setAccount:self.twitterAccount];
    [getRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                            options:0
                                                              error:&jsonError];
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(JSON, error);
            });
        }
    }];
}

- (void)getFavoriteTweetsSinceID:(NSNumber *)sinceID andMaxID:(NSNumber *)maxID completion:(void (^)(NSArray *, NSError *))completion
{
    assert(self.twitterAccount);
    
    NSString *url = @"";
    
    if (maxID != nil && sinceID != nil) {
        url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/list.json?since_id=%@&max_id=%@", sinceID, maxID];
    }else if (sinceID != nil) {
        url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/list.json?since_id=%@", sinceID];
    }else if (maxID != nil) {
        url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/list.json?max_id=%@", maxID];
    }else{
        url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/list.json"];
    }
    
    
    SLRequest *getRequest  = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodGET
                                                          URL:[NSURL URLWithString:url]
                                                   parameters:nil];
    
    
    [getRequest setAccount:self.twitterAccount];
    [getRequest performRequestWithHandler:^(NSData *responseData,
                                            NSHTTPURLResponse *urlResponse,
                                            NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            NSArray *JSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:0
                                                                   error:&jsonError];
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(JSON, error);
            });
        }
    }];
}


@end
