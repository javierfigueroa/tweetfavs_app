//
//  TFTweet.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFTweet : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSNumber *tweetID;

+ (void)getTweetsByCategoryId:(NSNumber*)categoryId andCompletion:(void(^)(NSArray *tweets, NSError *error))completion;

@end
