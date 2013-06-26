//
//  TFTweet.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFTweet.h"
#import "MLSocialNetworksManager.h"
#import "TFAPIClient.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"

@implementation TFTweet

- (NSMutableArray *)categories
{
    if (!_categories) {
        _categories = [[NSMutableArray alloc] init];
    }
    
    return _categories;
}

- (id)initWithAttributes:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        [self updateWithAttributes:data];
        self.edited = YES;
    }
    return self;
}

- (void)updateWithAttributes:(NSDictionary*)data
{
    
    NSDictionary *tweet = data[@"tweet"] ? data[@"tweet"] : data;
    
    if (tweet[@"tweet_id"]) {
        self.ID = tweet[@"id"];
    }
    
    self.categoryID = tweet[@"category_id"];
    
    self.tweetID = tweet[@"tweet_id"] ?
    [NSNumber numberWithLongLong:[tweet[@"tweet_id"] longLongValue]] :
    [NSNumber numberWithLongLong:[tweet[@"id"] longLongValue]];
    
    self.username = tweet[@"user"][@"name"];
    self.status = tweet[@"text"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy";
    self.created = [formatter dateFromString:tweet[@"created_at"]];
    
    self.retweetCount = [NSNumber numberWithInt:[tweet[@"retweet_count"] intValue]];
    self.avatarURL = [NSURL URLWithString:tweet[@"user"][@"profile_image_url"]];
    
    NSArray *categories = data[@"categories"];
    [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TFCategory *category = [[TFCategory alloc] initWithAttributes:obj];
        [self.categories addObject:category];
    }];
}

+ (void)getTweetsByCategoryId:(NSNumber*)categoryId andCompletion:(void(^)(NSArray *tweets, NSError *error))completion
{
    ACAccount *twitterAccount = [[MLSocialNetworksManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    NSString *url = [NSString stringWithFormat:@"tweets/%@/%@.json", twitterId, categoryId];
    
    [[TFAPIClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *JSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:JSON.count];
        [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
            [tweets addObject:tweet];
        }];
        
        if (completion) {
            completion(tweets, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)addTweet:(TFTweet*)tweet toCategory:(TFCategory*)category Completion:(void(^)(NSArray *tweets, NSError *error))completion
{
    ACAccount *twitterAccount = [[MLSocialNetworksManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSDictionary *parameters = @{@"twitter_id":twitterId, @"category_id":category.ID, @"tweet_id":tweet.tweetID};
    
    [category.tweets addObject:tweet];
    
    [[TFAPIClient sharedClient] postPath:@"tweets.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *JSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        
        if (completion) {
            completion(nil, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            [category.tweets removeObject:tweet];
            completion(nil, error);
        }
    }];
}

+ (void)deleteTweet:(TFTweet*)tweet fromCategory:(TFCategory*)category Completion:(void(^)(NSArray *tweets, NSError *error))completion
{
    ACAccount *twitterAccount = [[MLSocialNetworksManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    TFTweet *tweetToRemove = [TFTweetsAdapter findTweetById:tweet.tweetID inCategory:category];
    [category.tweets removeObject:tweetToRemove];
    [category.tweets removeObject:tweet];
    
    NSString *url = [NSString stringWithFormat:@"tweets/%@/%@/%@.json", twitterId, category.ID, tweet.tweetID];
    
    [[TFAPIClient sharedClient] deletePath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSArray *JSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//#if DEBUG
//        NSLog(@"%@", JSON);
//#endif
        
        if (completion) {
            completion(nil, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            [category.tweets addObject:tweetToRemove];
            completion(nil, error);
        }
    }];
}

@end
