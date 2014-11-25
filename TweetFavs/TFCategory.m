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
#import "TFTwitterManager.h"

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

+ (void)addCategoryWithName:(NSString*)name completion:(void(^)(TFCategory *category, NSError *error))completion
{
    ACAccount *twitterAccount = [[TFTwitterManager sharedManager] twitterAccount];
    NSString *userId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSDictionary *parameters = @{@"twitter_id":userId, @"name": name};
    [[TFAPIClient sharedClient] POST:@"categories.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *JSON = (NSDictionary*)responseObject;
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        TFCategory *category = [[TFCategory alloc] initWithAttributes:JSON];
        if (completion) {
            completion(category, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)updateCategory:(TFCategory*)category completion:(void(^)(TFCategory *category, NSError *error))completion

{
    ACAccount *twitterAccount = [[TFTwitterManager sharedManager] twitterAccount];
    NSString *userId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSDictionary *parameters = @{@"twitter_id":userId, @"name": category.name};
    NSString *url = [NSString stringWithFormat:@"categories/%@.json", category.ID];
    
    [[TFAPIClient sharedClient] PUT:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *JSON = (NSDictionary*)responseObject;
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        TFCategory *category = [[TFCategory alloc] initWithAttributes:JSON];
        if (completion) {
            completion(category, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)getCategoriesById:(NSString*)userId andCompletion:(void(^)(NSArray *categories, NSError *error))completion
{
    NSString *url = [NSString stringWithFormat:@"categories/%@.json", userId];
    [[TFAPIClient sharedClient] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *JSON = (NSArray*)responseObject;
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
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)getCategoriesByTweetId:(NSNumber*)tweetID andCompletion:(void(^)(NSArray *categories, NSError *error))completion
{
    NSString *url = [NSString stringWithFormat:@"categories/by/tweet/%@.json", tweetID];
    [[TFAPIClient sharedClient] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *JSON = (NSArray*)responseObject;
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
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)deleteCategory:(TFCategory*)category completion:(void(^)(NSArray *categories, NSError *error))completion

{
    ACAccount *twitterAccount = [[TFTwitterManager sharedManager] twitterAccount];
    NSString *userId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSString *url = [NSString stringWithFormat:@"categories/%@/%@.json", userId, category.ID];
    [[TFAPIClient sharedClient] DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *JSON = (NSDictionary*)responseObject;
#if DEBUG
        NSLog(@"%@", JSON);
#endif
        if (completion) {
            completion(nil, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
