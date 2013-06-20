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

@implementation TFTweet

- (id)initWithAttributes:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        NSDictionary *category = data[@"tweet"];
        self.categoryID = category[@"category_id"];
        self.tweetID = [NSNumber numberWithLongLong:[category[@"tweet_id"] longLongValue]];
        self.ID = category[@"id"];
    }
    return self;
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


@end
