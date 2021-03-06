//
//  TFTwitterManager.h
//  TweetFavs
//
//  Created by Javier Figueroa on 11/25/14.
//  Copyright (c) 2014 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

extern NSString *const TFGetAccounts;
extern NSString *const TFAccountSelected;

@interface TFTwitterManager : NSObject

@property (strong, nonatomic) ACAccount *twitterAccount;


+ (TFTwitterManager *) sharedManager;

- (void) getTwitterAccounts:(void(^)(NSArray *accounts, NSError *error))completion;


- (void) getTweetById:(NSNumber*)tweetID completion:(void(^)(NSDictionary *tweet, NSError *error))completion;


- (void) getFavoriteTweetsSinceID:(NSNumber*)sinceID andMaxID:(NSNumber*)maxID completion:(void(^)(NSArray *tweets, NSError *error))completion;

@end
