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

- (void)configureTweetCell:(id)tweet cell:(TFFeedCell *)cell
{
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    
    id tweet = self.tweets[indexPath.row];
    
    if ([tweet isKindOfClass:[NSDictionary class]]) {
        [self configureTweetCell:tweet cell:cell];
    }else{
        TFTweet *atweet = (TFTweet*)tweet;
        [TFTweetsAdapter getTweetByID:atweet.tweetID completion:^(NSDictionary *tweet) {
            [self.tweets replaceObjectAtIndex:indexPath.row withObject:tweet];
            [self configureTweetCell:tweet cell:cell];
        }];
    }
    
    return cell;
}

@end
