//
//  TFMenuViewController.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFMenuViewController.h"
#import "MLSocialNetworksManager.h"
#import "TFCategories.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"
#import "TFTweet.h"
#import "TFAppDelegate.h"
#import "IIViewDeckController.h"
#import "TFViewController.h"
#import "TFCategoryCell.h"

@interface TFMenuViewController ()

@end

@implementation TFMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* boldFontName = @"GillSans-Bold";
    self.accountLabel.textColor =[UIColor whiteColor];
    self.accountLabel.font =  [UIFont fontWithName:boldFontName size:18.0f];
    self.accountLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:0.6];
    [self.tableView registerNib:[UINib nibWithNibName:@"TFCategoryCell" bundle:nil] forCellReuseIdentifier:@"TFCategoryCell"];
    
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    self.accountButton.backgroundColor = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
    self.accountLabel.text = manager.twitterAccount.username;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:TFCategoriesFetched object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressAccountButton:(id)sender {
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    [manager getTwitterAccounts:^(NSObject *response, NSError *error) {
        if (error) {
            if (error.code != 600) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"No Twitter Accounts") message:NSLocalizedString(@"We couldn't find any authorized twitter accounts in your phone, please add one and try again", @"We couldn't find any authorized twitter accounts in your phone, please add one and try again") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                [alert show];
            }
        }else{
            self.accountLabel.text = manager.twitterAccount.username;
            [TFTweetsAdapter getCategories];
        }
    }];
}

- (void)refresh
{
    [TFTweetsAdapter getFavoriteTweets];
    [self.tableView reloadData];
}


#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TFCategories sharedCategories] categories].allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"TFCategoryCell";
    
    TFCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    TFCategory *category = categories[categories.allKeys[indexPath.row]];
    cell.textLabel.text = category.name;
    cell.detailTextLabel.text = [category.ID intValue] == -1 ? NSLocalizedString(@"All of your favorite tweets", nil) : [NSString stringWithFormat:@"%i tweets", category.tweets.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    NSNumber *key = categories.allKeys[indexPath.row];
    TFCategory *category = categories[key];
    
    TFAppDelegate *appDelegate = (TFAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.viewController.title = [category.ID intValue] == -1 ? @"TweetFavs" : category.name;
    
    if ([category.ID intValue] == -1) {
        [TFTweetsAdapter getFavoriteTweets];
        IIViewDeckController *deckController = appDelegate.deckController;
        [deckController closeLeftViewAnimated:YES];
    }else{
        [TFTweetsAdapter setTweets:category.tweets];
        IIViewDeckController *deckController = appDelegate.deckController;
        [deckController closeLeftViewAnimated:YES];
    }
}

@end
