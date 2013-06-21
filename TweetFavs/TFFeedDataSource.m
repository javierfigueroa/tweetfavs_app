//
//  TFFeedDataSource.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFFeedDataSource.h"
#import "TFFeedCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+HumanInterval.h"
#import "TFTweetsAdapter.h"
#import "TFTweet.h"
#import "TFCategory.h"
#import "TFCategories.h"

@implementation TFFeedDataSource

- (NSMutableArray *)tweets
{
    if (!_tweets) {
        _tweets = [[NSMutableArray alloc] init];
    }
    
    return _tweets;
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

- (void)configureTweetCell:(TFTweet*)tweet cell:(TFFeedCell *)cell
{
    cell.nameLabel.text = tweet.username;
    cell.updateLabel.text = tweet.status;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ ago", [tweet.created humanIntervalSinceNow]];
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%@ retweets", tweet.retweetCount];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%i categories", [tweet.categories count]];
    [cell.profileImageView setImageWithURL:tweet.avatarURL];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    
    TFTweet *tweet = self.tweets[indexPath.row];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        if (tweet.status.length == 0) {
            [TFTweetsAdapter getTweetByID:tweet.tweetID completion:^(NSMutableDictionary *atweet) {
                [tweet updateWithAttributes:atweet];
                [self configureTweetCell:tweet cell:cell];
            }];
        }
        
        if (tweet.categories.count == 0) {
            [TFTweetsAdapter getCategoriesByTweetID:tweet.tweetID completion:^(NSArray *categories) {
                tweet.categories = [NSMutableArray arrayWithArray:categories];
                [self configureTweetCell:tweet cell:cell];
            }];
        }
    
        [self configureTweetCell:tweet cell:cell];
//    });
    
    return cell;
}

@end
