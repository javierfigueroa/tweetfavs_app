//
//  TFTweet.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFTweet.h"
#import "TFTwitterManager.h"
#import "TFAPIClient.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"

@implementation TFTweet

#define DATE_FORMAT @"eee MMM dd HH:mm:ss ZZZZ yyyy"

- (NSMutableArray *)categories
{
    if (!_categories) {
        _categories = [[NSMutableArray alloc] init];
    }
    
    return _categories;
}


- (id)initWithAttributes:(id)tweet
{
    self = [super init];
    if (self) {
        self.categoryID = tweet[@"categoryId"];
        self.tweetID = tweet[@"tweetId"] ?
        [NSNumber numberWithLongLong:[tweet[@"tweetId"] longLongValue]] :
        [NSNumber numberWithLongLong:[tweet[@"id"] longLongValue]];
        
        self.username = tweet[@"username"] && tweet[@"username"] != (id)[NSNull null] ? tweet[@"username"] : tweet[@"user"][@"name"];
        self.status = tweet[@"text"] ? tweet[@"text"] : tweet[@"status"];
        
//        if (tweet[@"created_at"] != (id)[NSNull null]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = DATE_FORMAT;
            self.created = [formatter dateFromString:tweet[@"created_at"] ? tweet[@"created_at"] : tweet[@"tweetCreatedAt"]];
//        }
        
        self.retweetCount = tweet[@"retweets"] && tweet[@"retweets"] != (id)[NSNull null]?
        [NSNumber numberWithInt:[tweet[@"retweets"] intValue]] :
        [NSNumber numberWithInt:[tweet[@"retweet_count"] intValue]];
        self.avatarURL = [NSURL URLWithString:(tweet[@"avatarUrl"] && tweet[@"avatarUrl"] != (id)[NSNull null] ? tweet[@"avatarUrl"] :tweet[@"user"][@"profile_image_url"])];
    }
    return self;

}

- (id)initWithParseObject:(PFObject*)tweet
{
    self = [self initWithAttributes:tweet];
    self.parseObject = tweet;
    self.ID = tweet.objectId;
    
    return self;
}

- (void)addCategory:(TFCategory*)category completion:(void (^)(TFTweet *tweet, NSError *error))completion;
{
    PFRelation *relation = [self.parseObject relationForKey:@"categories"];
    [relation addObject:category.parseCategory];
    [self.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            if (completion) {
                completion(nil, nil);
            }
        } else {
            // There was a problem, check error.description
            [category.tweets removeObject:self];
            [self.categories removeObject:category];
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

//POST

+ (void)addTweet:(TFTweet*)tweet toCategory:(TFCategory*)category completion:(void(^)(TFTweet *tweet, NSError *error))completion
{
    ACAccount *twitterAccount = [[TFTwitterManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    [category.tweets addObject:tweet];
    [tweet.categories addObject:category];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tweet"];
    [query whereKey:@"tweetId" equalTo:tweet.tweetID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = DATE_FORMAT;
            
            PFObject *parseTweet = [PFObject objectWithClassName:@"Tweet" dictionary:@{@"twitterId":twitterId,
                                                                                       @"tweetCreatedAt": [formatter stringFromDate:tweet.created],
                                                                                       @"tweetId":tweet.tweetID,
                                                                                       @"status": tweet.status,
                                                                                       @"retweets":tweet.retweetCount,
                                                                                       @"avatarUrl":tweet.avatarURL.absoluteString,
                                                                                       @"username":tweet.username}];
            [parseTweet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    tweet.parseObject = parseTweet;
                    tweet.ID = parseTweet.objectId;
                    [tweet addCategory:category completion:completion];
                }else{
                    [category.tweets removeObject:tweet];
                    [tweet.categories removeObject:category];
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            tweet.parseObject = object;
            tweet.ID = object.objectId;
            [tweet addCategory:category completion:completion];
        }
    }];
}

//GET

+ (void)getByTweetId:(NSNumber *)tweetId completion:(void (^)(TFTweet *tweet, NSError *error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tweet"];
    [query whereKey:@"tweetId" equalTo:tweetId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            TFTweet *tweet = [[TFTweet alloc] initWithParseObject:object];
            if (completion) {
                completion(tweet, nil);
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (completion) {
                completion(nil, error);
            }
        }
        
    }];
}

+ (void)getByCategory:(TFCategory *)category completion:(void (^)(NSArray *tweets, NSError *error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tweet"];
    [query whereKey:@"categories" equalTo:category.parseCategory];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:objects.count];
            [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tweets addObject:[[TFTweet alloc] initWithParseObject:obj]];
            }];
            completion(tweets, nil);
        }else{
            completion(nil, error);
        }
    }];
}

//DELETE

+ (void)deleteTweet:(TFTweet*)tweet fromCategory:(TFCategory*)category completion:(void(^)(TFTweet *tweet, NSError *error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tweet"];
    [query whereKey:@"tweetId" equalTo:tweet.tweetID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            tweet.parseObject = object;
            tweet.ID = object.objectId;
            
            PFRelation *relation = [tweet.parseObject relationForKey:@"categories"];
            [relation removeObject:category.parseCategory];
            [tweet.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    if (completion) {
                        completion(nil, nil);
                    }
                }else{
                    if (completion) {
                        [category.tweets addObject:tweet];
                        completion(nil, error);
                    }
                }
            }];
        }
    }];
}

@end
