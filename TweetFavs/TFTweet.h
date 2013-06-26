//
//  TFTweet.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFCategory;
@interface TFTweet : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSNumber *tweetID;
@property (nonatomic, strong) NSNumber *retweetCount;
@property (nonatomic, strong) NSMutableArray *categories;

- (id)initWithAttributes:(NSDictionary*)data;

- (void)updateWithAttributes:(NSDictionary*)data;


+ (void)addTweet:(TFTweet*)tweet toCategory:(TFCategory*)category Completion:(void(^)(NSArray *tweets, NSError *error))completion;

+ (void)getTweetsByCategoryId:(NSNumber*)categoryId andCompletion:(void(^)(NSArray *tweets, NSError *error))completion;

+ (void)deleteTweet:(TFTweet*)tweet fromCategory:(TFCategory*)category Completion:(void(^)(NSArray *tweets, NSError *error))completion;

@end
