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
    [[self class] getFavoriteTweetsSinceID:nil];
}

+ (void)getFavoriteTweetsSinceID:(NSNumber*)ID
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    NSNumber *allKey = [NSNumber numberWithInt:-1];
    TFCategory *category = categories[allKey];
    
    if (category.tweets.count == 0) {
        MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
        [manager getFavoriteTweetsSinceID:ID completion:^(NSArray *tweets, NSError *error) {
            
            if (!ID) {
                [[[self class] dataSource].tweets removeAllObjects];
                [category.tweets removeAllObjects];
            }
            
            [tweets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                TFTweet *tweet = [[TFTweet alloc] initWithAttributes:obj];
                [category.tweets addObject:tweet];
            }];
            
            [[self class] dataSource].tweets = category.tweets;
            [[[self class] tableView] reloadData];
        }];
    }else{
        [[self class] dataSource].tweets = category.tweets;
        [[[self class] tableView] reloadData];
    }
}

+ (void)setTweets:(NSMutableArray *)tweets
{
    [[self class] dataSource].tweets = tweets;
    [[[self class] tableView] reloadData];
}

+ (void)getTweetsByCategoryID:(NSNumber *)categoryID completion:(void(^)(void))completion
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    TFCategory *category = categories[categoryID];
    
    [TFTweet getTweetsByCategoryId:categoryID andCompletion:^(NSArray *tweets, NSError *error) {
        [category.tweets removeAllObjects];
        [category.tweets addObjectsFromArray:tweets];
        
        [[self class] dataSource].tweets = category.tweets;
        [[[self class] tableView] reloadData];
        
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
