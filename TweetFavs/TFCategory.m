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

- (id)initWithParseObject:(PFObject*)parseObject
{
    self = [super init];
    if (self) {
        self.userID = parseObject[@"twitterId"];
        self.name = parseObject[@"name"];
        self.ID = parseObject.objectId;
        self.parseCategory = parseObject;
    }
    return self;
}

//POST

+ (void)addCategoryWithName:(NSString*)name completion:(void(^)(TFCategory *category, NSError *error))completion
{
    ACAccount *twitterAccount = [[TFTwitterManager sharedManager] twitterAccount];
    NSString *userId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSDictionary *parameters = @{@"twitterId":userId,
                                 @"name": name};
    
    PFObject *parseCategory = [PFObject objectWithClassName:@"Category" dictionary:parameters];
    [parseCategory saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            if (completion) {
                TFCategory *category = [[TFCategory alloc] initWithParseObject:parseCategory];
                if (completion) {
                    completion(category, nil);
                }
            }
        } else {
            // There was a problem, check error.description
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

//GET

+ (void)getCategoriesByTwitterId:(NSString *)twitterId completion:(void (^)(NSArray *, NSError *))completion
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"twitterId = '%@'", twitterId]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Category" predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:objects.count];
            [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
                TFCategory *category = [[TFCategory alloc] initWithParseObject:obj];
                [categories addObject:category];
            }];
            
            if (completion) {
                completion(categories, nil);
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

+ (void)getCategoriesByTweet:(TFTweet*)tweet completion:(void (^)(NSArray *, NSError *))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tweet"];
    [query whereKey:@"tweetId" equalTo:tweet.tweetID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            
            tweet.categoryID = object[@"categoryId"];
            tweet.ID = object.objectId;
            
            PFRelation *relation = [object relationForKey:@"categories"];
            [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    // There was an error
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    if (completion) {
                        completion(nil, error);
                    }
                } else {
                    tweet.categories = [[NSMutableArray alloc] initWithCapacity:objects.count];
                    [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
                        TFCategory *category = [[TFCategory alloc] initWithParseObject:obj];
                        [tweet.categories addObject:category];
                    }];
                    
                    if (completion) {
                        completion(tweet.categories, nil);
                    }
                }
            }];
        }
    }];
}

//PUT

+ (void)updateCategory:(TFCategory*)category completion:(void(^)(TFCategory *category, NSError *error))completion
{
    category.parseCategory[@"name"] = category.name;
    [category.parseCategory saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (completion) {
                completion(category, nil);
            }
        }else{
            if (completion) {
                completion(nil, error);
            }
        }
        
    }];
}

//DELETE

+ (void)deleteCategory:(TFCategory*)category completion:(void(^)(NSArray *categories, NSError *error))completion
{
    [category.parseCategory deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (completion) {
                completion(nil, nil);
            }
        }else{
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

@end
