//
//  TFCategory.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFCategory.h"
#import "TFAPIClient.h"
#import "TFTweet.h"

@implementation TFCategory

- (NSMutableArray *)tweets
{
    if (!_tweets) {
        _tweets = [[NSMutableArray alloc] init];
    }
    
    return _tweets;
}

- (id)initWithAttributes:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        NSDictionary *category = data[@"category"] ? data[@"category"] : data;
        self.userID = category[@"user_id"];
        self.name = category[@"name"];
        self.ID = category[@"id"];
        
        NSArray *tweets = data[@"tweets"];
        [tweets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
            [self.tweets addObject:tweet];
        }];
    }
    return self;
}

+ (void)getCategoriesById:(NSString*)userId andCompletion:(void(^)(NSArray *categories, NSError *error))completion
{
    NSString *url = [NSString stringWithFormat:@"categories/%@.json", userId];
    [[TFAPIClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *JSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:JSON.count];
        [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TFCategory *category = [[TFCategory alloc] initWithAttributes:obj];
            [categories addObject:category];
        }];
        
        if (completion) {
            completion(categories, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)getCategoriesByTweetId:(NSNumber*)tweetID andCompletion:(void(^)(NSArray *categories, NSError *error))completion
{
    NSString *url = [NSString stringWithFormat:@"categories/by/tweet/%@.json", tweetID];
    [[TFAPIClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *JSON = (NSArray*)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:JSON.count];
        [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TFCategory *category = [[TFCategory alloc] initWithAttributes:obj];
            [categories addObject:category];
        }];
        
        if (completion) {
            completion(categories, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
