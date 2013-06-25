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
#import "TFCategories.h"

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
    self.tableView.dataSource = self.tableViewDataSource;
    [self firstTimeAccountCheck];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFavoriteTweets) name:TFCategoriesFetched object:nil];
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
    [self.tableViewDataSource getFavoriteTweetsSinceID:nil];
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

@end
