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

+ (void)getFavoriteTweets;

+ (void)getFavoriteTweetsSinceID:(NSNumber*)ID andMaxID:(NSNumber*)maxID completion:(void(^)(NSArray *tweets))completion;

+ (void)getTweetsByCategoryID:(NSNumber *)categoryID completion:(void(^)(void))completion;

+ (void)getTweetByID:(NSNumber *)tweetID completion:(void (^)(NSMutableDictionary *tweet))completion;

+ (void)getCategoriesByTweetID:(NSNumber *)tweetID completion:(void(^)(NSArray *categories))completion;

+ (void)setTweets:(NSArray *)tweets;

+ (TFTweet *)findTweetById:(NSNumber *)ID inCategory:(TFCategory *)category;
@end
