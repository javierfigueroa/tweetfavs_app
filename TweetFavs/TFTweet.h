//
//  TFTweet.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFCategory, PFObject;
@interface TFTweet : NSObject

@property (nonatomic, strong) PFObject *parseObject;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSNumber *tweetID;
@property (nonatomic, strong) NSNumber *retweetCount;
@property (nonatomic, strong) NSMutableArray *categories;

- (id)initWithAttributes:(id)tweet;

- (id)initWithParseObject:(PFObject*)tweet;

//CRUD

+ (void)addTweet:(TFTweet*)tweet toCategory:(TFCategory*)category completion:(void(^)(TFTweet *tweet, NSError *error))completion;

+ (void)getByTweetId:(NSNumber *)tweetId completion:(void (^)(TFTweet *tweet, NSError *error))completion;

+ (void)getByCategory:(TFCategory *)category completion:(void (^)(NSArray *tweets, NSError *error))completion;

+ (void)deleteTweet:(TFTweet*)tweet fromCategory:(TFCategory*)category completion:(void(^)(TFTweet *tweet, NSError *error))completion;

@end
