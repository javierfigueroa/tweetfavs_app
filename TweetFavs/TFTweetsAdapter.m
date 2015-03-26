//
//  TFTweetsAdapter.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFTweetsAdapter.h"
#import "TFCategories.h"
#import "TFFeedDataSource.h"
#import "TFAppDelegate.h"
#import "TFTweet.h"
#import "TFCategory.h"
#import "TFTwitterManager.h"

static NSMutableArray *_favorites;

@implementation TFTweetsAdapter

+ (NSMutableArray *)favorites
{
    if (_favorites == nil) {
        _favorites = [[NSMutableArray alloc] init];
    }
    
    return _favorites;
}

+ (void)getCategories
{
    ACAccount *twitterAccount = [[TFTwitterManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    [TFCategory getCategoriesByTwitterId:twitterId completion:^(NSArray *cats, NSError *error) {
        [categories removeAllObjects];
        if (!error) {
            [cats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                TFCategory *category = (TFCategory*)obj;
                categories[category.ID] = category;
            }];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TFCategoriesFetched object:nil];
    }];
}

+ (void)getFavoriteTweetsWithCompletion:(void(^)(NSArray *tweets))completion
{
    [[self class] getFavoriteTweetsSinceID:nil andMaxID:nil completion:completion];
}

+ (void)getFavoriteTweetsSinceID:(NSNumber*)sinceID andMaxID:(NSNumber*)maxID completion:(void(^)(NSArray *tweets))completion
{
    
//    if ([TFTweetsAdapter favorites].count == 0 || sinceID || maxID) {
        TFTwitterManager *manager = [TFTwitterManager sharedManager];
        [manager getFavoriteTweetsSinceID:sinceID andMaxID:maxID completion:^(NSArray *tweets, NSError *error) {
            
            //Error case when twitter fails
            if ([tweets isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = (NSDictionary*)tweets;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Twitter Error", nil) message:response[@"errors"][0][@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                if (completion) {
                    completion(@[]);
                }
            }else{
                //usually the first time we get tweets
                if (!sinceID && !maxID) {
                    [[TFTweetsAdapter favorites] removeAllObjects];
                }
                
                //append to the top of the list since these are new tweets
                if (sinceID) {
                    [tweets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
                        [[TFTweetsAdapter favorites] insertObject:tweet atIndex:0];
                    }];
                }else{
                //append to the end, when loading more tweets
                    if (!maxID || tweets.count > 1) {
                        [tweets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
                            [[TFTweetsAdapter favorites] addObject:tweet];
                        }];   
                    }
                }
                
                if (completion) {
                    completion([TFTweetsAdapter favorites]);
                }
            }
        }];
//    }else{
//        if (completion) {
//            completion([TFTweetsAdapter favorites]);
//        }
//    }
}

+ (void)getCategoriesByTweet:(TFTweet *)tweet completion:(void(^)(NSArray *categories))completion
{
    [TFCategory getCategoriesByTweet:tweet completion:^(NSArray *categories, NSError *error) {
        if (!error && completion) {
            completion(categories);
        }
    }];
}

+ (void)getTweetByID:(NSNumber *)tweetID completion:(void (^)(NSMutableDictionary *tweet))completion
{
    TFTwitterManager *manager = [TFTwitterManager sharedManager];
    [manager getTweetById:tweetID completion:^(NSDictionary *tweet, NSError *error) {
        completion([NSMutableDictionary dictionaryWithDictionary:tweet]);
    }];
}

@end
