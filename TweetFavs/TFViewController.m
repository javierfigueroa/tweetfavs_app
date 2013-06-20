//
//  MLPViewController.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/19/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFViewController.h"
#import "MLSocialNetworksManager.h"
#import "TFFeedCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+HumanInterval.h"
#import "TFCategories.h"

@interface TFViewController ()

@property (nonatomic, retain) NSMutableArray *tweets;

@end

@implementation TFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* boldFontName = @"GillSans-Bold";
    [self styleNavigationBarWithFontName:boldFontName];
    self.title = @"TweetFavs";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:0.6];
    [self.tableView registerNib:[UINib nibWithNibName:@"TFFeedCell" bundle:nil] forCellReuseIdentifier:@"FeedCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresWithNewAccount) name:@"NewAccount" object:nil];
    
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    if (manager.twitterAccount) {
        [self getFavoriteTweets:manager.twitterAccount];
    }else{
        [manager getTwitterAccounts:^(NSObject *response, NSError *error) {
            if (error) {
                if (error.code != 600) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"No Twitter Accounts") message:NSLocalizedString(@"We couldn't find any authorized twitter accounts in your phone, please add one and try again", @"We couldn't find any authorized twitter accounts in your phone, please add one and try again") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                    [alert show];
                }
            }else{
                ACAccount *twitterAccount = (ACAccount*)response;
                [self getFavoriteTweets:twitterAccount];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)refresWithNewAccount
{
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    [self getFavoriteTweets:manager.twitterAccount];
}

- (void)getFavoriteTweets:(ACAccount*)account
{
    [TFCategories sharedCategories];
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    [manager getFavoriteTweetsWithAccount:account completion:^(NSArray *tweets, NSError *error) {
        self.tweets = [[NSMutableArray alloc] initWithArray:tweets];
        [self.tableView reloadData];
        NSLog(@"%@", tweets);
    }];
}

-(void)styleNavigationBarWithFontName:(NSString*)navigationTitleFont{
    
    
    CGSize size = CGSizeMake(320, 44);
    UIColor* color = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
    
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UINavigationBar* navAppearance = [UINavigationBar appearance];
    
    [navAppearance setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [navAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor whiteColor], UITextAttributeTextColor,
                                           [UIFont fontWithName:navigationTitleFont size:18.0f], UITextAttributeFont, [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)], UITextAttributeTextShadowOffset,
                                           nil]];
    UIImageView* searchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search.png"]];
    searchView.frame = CGRectMake(0, 0, 20, 20);
    
    UIBarButtonItem* searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchView];
    
    self.navigationItem.rightBarButtonItem = searchItem;
    
    
    UIImageView* menuView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu.png"]];
    menuView.frame = CGRectMake(0, 0, 28, 20);
    
    UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuView];
    
    self.navigationItem.leftBarButtonItem = menuItem;
}


#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    
    NSDictionary *tweet = self.tweets[indexPath.row];
    cell.nameLabel.text = tweet[@"user"][@"name"];
    cell.updateLabel.text = tweet[@"text"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy";
    NSDate *created = [formatter dateFromString:tweet[@"created_at"]];
    
    cell.dateLabel.text = [created humanIntervalSinceNow];
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%@ retweets", tweet[@"retweet_count"]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%@ categories", tweet[@"retweet_count"]];
    
    NSURL* url = [NSURL URLWithString:tweet[@"user"][@"profile_image_url"]];
    [cell.profileImageView setImageWithURL:url];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 125;
}


@end
