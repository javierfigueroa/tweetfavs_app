//
//  TFTweetViewController.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/24/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFTweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TFTweet.h"
#import "NSDate+HumanInterval.h"
#import "TFTheme.h"
#import "TFCategoriesDataSource.h"
#import "TFCategories.h"

@interface TFTweetViewController ()

@end

@implementation TFTweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureTweet
{
    self.nameLabel.text = self.tweet.username;
    self.statusLabel.text = self.tweet.status;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ ago", [self.tweet.created humanIntervalSinceNow]];
    self.retweetsLabel.text = [NSString stringWithFormat:@"%@ retweets", self.tweet.retweetCount];
    self.categoriesLabel.text = [NSString stringWithFormat:@"%i categories", [self.tweet.categories count]];
    [self.avatarView setImageWithURL:self.tweet.avatarURL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TFTheme customizeTweetController:self];
    [TFTheme setBackButton:self];
    self.title = NSLocalizedString(@"Fav", nil);
    [self configureTweet];
    [self.categoriesTableView registerNib:[UINib nibWithNibName:@"TFCategoryCell" bundle:nil] forCellReuseIdentifier:@"TFCategoryCell"];
    self.tableDataSource = [[TFCategoriesDataSource alloc] init];
    self.tableDataSource.tweet = self.tweet;
    self.categoriesTableView.dataSource = self.tableDataSource;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:TFCategoriesEdited object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    self.tableDataSource.sortedCategories = nil;
    [self.categoriesTableView reloadData];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //skip the all category
    if (indexPath.row > 0) {
        TFCategory *category;
        category = [self.tableDataSource getCategoryByIndexPath:indexPath];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
            [TFTweet deleteTweet:self.tweet fromCategory:category Completion:nil];
        }else{
            [TFTweet addTweet:self.tweet toCategory:category Completion:nil];
        }
        
        self.tweet.edited = YES;
        [self configureTweet];
        [[NSNotificationCenter defaultCenter] postNotificationName:TFCategoriesEdited object:nil];
        
//        [self.categoriesTableView reloadRowsAtIndexPaths:@[indexPath]
//                                        withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.tableHeaderLabel.font = [UIFont fontWithName:[TFTheme boldFontName] size:12];
    self.tableHeaderLabel.textColor = [UIColor whiteColor];
    self.tableHeader.backgroundColor = [TFTheme mainColor];
    return self.tableHeader;
}

@end
