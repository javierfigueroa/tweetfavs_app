//
//  TFTweetsAdapter.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount, TFTweet, TFCategory;
@interface TFTweetsAdapter : NSObject

+ (void)getCategories;

+ (void)getFavoriteTweetsWithCompletion:(void(^)(NSArray *tweets))completion;

+ (void)getFavoriteTweetsSinceID:(NSNumber*)ID andMaxID:(NSNumber*)maxID completion:(void(^)(NSArray *tweets))completion;

+ (void)getTweetByID:(NSNumber *)tweetID completion:(void (^)(NSMutableDictionary *tweet))completion;

+ (void)getCategoriesByTweet:(TFTweet *)tweet completion:(void(^)(NSArray *categories))completion;

@end
