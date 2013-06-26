//
//  MLPViewController.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/19/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFViewController.h"
#import "MLSocialNetworksManager.h"
#import "TFFeedDataSource.h"
#import "TFTweetsAdapter.h"
#import "TFTweetViewController.h"
#import "TFTweet.h"
#import "TFTheme.h"
#import "TFCategory.h"
#import "TFCategories.h"
#import "TFRefreshHeaderView.h"
#import "TFRefreshFooterView.h"

@interface TFViewController ()


@end

@implementation TFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TFTheme styleNavigationBar];
    
    UIImageView* menuView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-menu-icon"]];
    UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuView];
    self.navigationItem.leftBarButtonItem = menuItem;
    
    self.title = @"TweetFavs";
    [TFTheme customizeFeedController:self];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TFFeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    [self firstTimeAccountCheck];
    
    TFRefreshHeaderView *header = [[TFRefreshHeaderView alloc] init];
    self.headerView = header;
    
    TFRefreshFooterView *footer = [[TFRefreshFooterView alloc] init];
    self.footerView = footer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFavoriteTweets) name:TFCategoriesFetched object:nil];
    self.tableView.dataSource = self.tableViewDataSource;
    
    self.canLoadMore = YES;
    self.pullToRefreshEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFavoriteTweets
{
    [TFTweetsAdapter getFavoriteTweets];
}

- (void)firstTimeAccountCheck
{
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    if (manager.twitterAccount ) {
        [TFTweetsAdapter getCategories];
    }else{
        [manager getTwitterAccounts:^(NSObject *response, NSError *error) {
            if (error) {
                if (error.code != 600) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"No Twitter Accounts") message:NSLocalizedString(@"We couldn't find any authorized twitter accounts in your phone, please add one and try again", @"We couldn't find any authorized twitter accounts in your phone, please add one and try again") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                    [alert show];
                }
            }else{
                [TFTweetsAdapter getCategories];
            }
        }];
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 125;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFTweetViewController *tweetcontroller = [[TFTweetViewController alloc] initWithNibName:@"TFTweetViewController" bundle:nil];
    
    TFTweet *tweet =  self.tableViewDataSource.tweets[indexPath.row];
    tweetcontroller.tweet = tweet;
    
    [self.navigationController pushViewController:tweetcontroller animated:YES];
    
}

#pragma mark - Pull to Refresh

- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    TFRefreshHeaderView *hv = (TFRefreshHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.label.text = NSLocalizedString(@"Loading...", nil);
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(TFRefreshHeaderView *)self.headerView activityIndicator] stopAnimating];
}

- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    if (!self.pullToRefreshEnabled) {
        self.headerView = nil;
    }else{
        TFRefreshHeaderView *header = [[TFRefreshHeaderView alloc] init];
        self.headerView = header;
    }
    
    TFRefreshHeaderView *hv = (TFRefreshHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.label.text = @"Release to refresh...";
    else
        hv.label.text = @"Pull down to refresh...";
}

- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    
    NSNumber *allKey = [NSNumber numberWithInt:-1];
    TFCategory *category = [[TFCategories sharedCategories] categories][allKey];
    TFTweet *firstTweet = category.tweets[0];
    [TFTweetsAdapter getFavoriteTweetsSinceID:firstTweet.tweetID andMaxID:nil completion:^(NSArray *tweets) {
        [self.tableView reloadData];
        [self refreshCompleted];
    }];
    
    return YES;
}

#pragma mark - Load More

- (void) willBeginLoadingMore
{
    TFRefreshFooterView *fv = (TFRefreshFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    TFRefreshFooterView *fv = (TFRefreshFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by:
        [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
    }
}

- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    NSNumber *allKey = [NSNumber numberWithInt:-1];
    TFCategory *category = [[TFCategories sharedCategories] categories][allKey];
    TFTweet *lastTweet = category.tweets[category.tweets.count-1];
    [TFTweetsAdapter getFavoriteTweetsSinceID:nil andMaxID:lastTweet.tweetID completion:^(NSArray *tweets) {
        if (tweets.count == 1) {
            NSNumber *tweetID = [NSNumber numberWithLongLong:[tweets[0][@"id"] longLongValue]];
            self.canLoadMore = ![lastTweet.tweetID isEqualToNumber:tweetID];
        }
        
        [self loadMoreCompleted];
    }];
    
    return YES;
}
@end
