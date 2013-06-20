//
//  TFTweetsAdapter.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;
@interface TFTweetsAdapter : NSObject

+ (void)getFavoriteTweets;

+ (void)getTweetsByCategoryID:(NSNumber *)categoryID completion:(void(^)(void))completion;

+ (void)getTweetByID:(NSNumber *)tweetID completion:(void (^)(NSDictionary *tweet))completion;

@end
