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

+ (void)getFavoriteTweets
{
    [TFCategories sharedCategories];
    [[self class] getFavoriteTweetsWithPage:0];
}

+ (void)getFavoriteTweetsWithPage:(int)page
{
    [TFCategories sharedCategories];
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    [manager getFavoriteTweetsWithPage:page completion:^(NSArray *tweets, NSError *error) {
        if (page == 0) {
            [[[self class] dataSource].tweets removeAllObjects];
        }
        
        [[[self class] dataSource].tweets addObjectsFromArray:tweets];
        [[[self class] tableView] reloadData];
    }];
}

+ (void)getTweetsByCategoryID:(NSNumber *)categoryID completion:(void(^)(void))completion
{
    [TFTweet getTweetsByCategoryId:categoryID andCompletion:^(NSArray *tweets, NSError *error) {
        [[[self class] dataSource].tweets removeAllObjects];
        [[[self class] dataSource].tweets addObjectsFromArray:tweets];
        [[[self class] tableView] reloadData];
        
        if (completion) {
            completion();
        }
    }];
}

+ (void)getTweetByID:(NSNumber *)tweetID completion:(void (^)(NSDictionary *tweet))completion
{
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    [manager getTweetById:tweetID completion:^(NSDictionary *tweet, NSError *error) {
        completion(tweet);
    }];
}

@end
