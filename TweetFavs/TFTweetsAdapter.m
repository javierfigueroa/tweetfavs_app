//
//  TFTweetsAdapter.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFTweetsAdapter.h"
#import "MLSocialNetworksManager.h"
#import "TFCategories.h"
#import "TFFeedDataSource.h"
#import "TFAppDelegate.h"
#import "TFViewController.h"
#import "TFTweet.h"
#import "TFCategory.h"

@implementation TFTweetsAdapter

+ (UITableView*)tableView
{
    TFAppDelegate *appDelegate = (TFAppDelegate*)[UIApplication sharedApplication].delegate;
    TFViewController *feedController = appDelegate.viewController;
    return feedController.tableView;
}

+ (TFFeedDataSource*)dataSource
{
    TFAppDelegate *appDelegate = (TFAppDelegate*)[UIApplication sharedApplication].delegate;
    TFViewController *feedController = appDelegate.viewController;
    return feedController.tableViewDataSource;
}

+ (void)reloadDataSource
{
    [[[self class] tableView] reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:TFTweetsLoaded object:nil];
}

+ (void)getCategories
{
    ACAccount *twitterAccount = [[MLSocialNetworksManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    [TFCategory getCategoriesById:twitterId andCompletion:^(NSArray *rcategories, NSError *error) {
        [categories removeAllObjects];
        if (!error) {
            [rcategories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                TFCategory *category = (TFCategory*)obj;
                categories[category.ID] = category;
            }];
            
            TFCategory *all = [[TFCategory alloc] init];
            all.name = NSLocalizedString(@"All", nil);
            all.ID = [NSNumber numberWithInt:-1];
            categories[all.ID] = all;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TFCategoriesFetched object:nil];
    }];
}

+ (void)getFavoriteTweets
{
    [[self class] getFavoriteTweetsSinceID:nil andMaxID:nil completion:nil];
}

+ (void)getFavoriteTweetsSinceID:(NSNumber*)sinceID andMaxID:(NSNumber*)maxID completion:(void(^)(NSArray *tweets))completion
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    NSNumber *allKey = [NSNumber numberWithInt:-1];
    TFCategory *category = categories[allKey];
    
    if (category.tweets.count == 0 || sinceID || maxID) {
        MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
        [manager getFavoriteTweetsSinceID:sinceID andMaxID:maxID completion:^(NSArray *tweets, NSError *error) {
            
            //Error case when twitter fails
            if ([tweets isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = (NSDictionary*)tweets;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Twitter Error", nil) message:response[@"errors"][0][@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                [[self class] dataSource].tweets = category.tweets;
                [[self class] reloadDataSource];
                
                if (completion) {
                    completion(@[]);
                }
            }else{
                //usually the first time we get tweets
                if (!sinceID && !maxID) {
                    [[[self class] dataSource].tweets removeAllObjects];
                    [category.tweets removeAllObjects];
                }
                
                //append to the top of the list since these are new tweets
                if (sinceID) {
                    [tweets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
                        [category.tweets insertObject:tweet atIndex:0];
                    }];
                }else{
                //append to the end, when loading more tweets
                    if (!maxID || tweets.count > 1) {
                        [tweets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
                            [category.tweets addObject:tweet];
                        }];   
                    }
                }
                
                [[self class] dataSource].tweets = category.tweets;
                [[self class] reloadDataSource];
                
                if (completion) {
                    completion(tweets);
                }
            }
        }];
    }else{
        [[self class] dataSource].tweets = category.tweets;
        [[self class] reloadDataSource];
        
        if (completion) {
            completion(category.tweets);
        }
    }
}

+ (void)setTweets:(NSMutableArray *)tweets
{
    [[self class] dataSource].tweets = tweets;
    [[self class] reloadDataSource];
}

+ (void)getTweetsByCategoryID:(NSNumber *)categoryID completion:(void(^)(void))completion
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    TFCategory *category = categories[categoryID];
    
    [TFTweet getTweetsByCategoryId:categoryID andCompletion:^(NSArray *tweets, NSError *error) {
        [category.tweets removeAllObjects];
        [category.tweets addObjectsFromArray:tweets];
        
        [[self class] dataSource].tweets = category.tweets;
        [[self class] reloadDataSource];
        
        if (completion) {
            completion();
        }
    }];
}

+ (void)getCategoriesByTweetID:(NSNumber *)tweetID completion:(void(^)(NSArray *categories))completion
{
    
    [TFCategory getCategoriesByTweetId:tweetID andCompletion:^(NSArray *categories, NSError *error) {        
        if (!error && completion) {
            completion(categories);
        }
    }];
}


+ (TFTweet *)findTweetById:(NSNumber *)ID inCategory:(TFCategory *)category
{
    for (TFTweet *tweet in category.tweets) {
        if ([tweet.tweetID isEqualToNumber:ID]) {
            return tweet;
        }
    }
    
    return nil;
}


+ (void)getTweetByID:(NSNumber *)tweetID completion:(void (^)(NSMutableDictionary *tweet))completion
{
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    [manager getTweetById:tweetID completion:^(NSDictionary *tweet, NSError *error) {
        completion([NSMutableDictionary dictionaryWithDictionary:tweet]);
    }];
}

@end
