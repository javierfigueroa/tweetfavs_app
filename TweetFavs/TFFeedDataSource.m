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
#import <QuartzCore/QuartzCore.h>

@interface TFFeedDataSource()

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation TFFeedDataSource

- (NSCache *)imageCache
{
    if (!_imageCache) {
        _imageCache = [[NSCache alloc] init];
    }
    
    return _imageCache;
}

- (dispatch_queue_t)queue
{
    if(!_queue) {
        _queue = dispatch_queue_create("com.tweetfavs.bg", 0);
    }
    
    return _queue;
}

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
    
    NSString *objID = [NSString stringWithFormat:@"%@", tweet.tweetID];
    UIImage *cellImage = [self.imageCache objectForKey:objID];
    
    if (!cellImage) {
        dispatch_queue_t queue = self.queue;// dispatch_queue_create("com.tweetfavs.bg", 0);
        dispatch_async(queue, ^{
            NSData *data = [NSData dataWithContentsOfURL:tweet.avatarURL];
            UIImage *img = [[UIImage alloc] initWithData:data];
            
            // Begin a new image that will be the new image with the rounded corners
            // (here with the size of an UIImageView)
            UIGraphicsBeginImageContextWithOptions(cell.profileImageView.bounds.size, NO, 0.0);
            
            // Add a clip before drawing anything, in the shape of an rounded rect
            [[UIBezierPath bezierPathWithRoundedRect:cell.profileImageView.bounds
                                        cornerRadius:20.0] addClip];
            // Draw your image
            [img drawInRect:cell.profileImageView.bounds];
            
            // Get the image, here setting the UIImageView image
            img = UIGraphicsGetImageFromCurrentImageContext();
            
            // Lets forget about that we were drawing
            UIGraphicsEndImageContext();
            
            [self.imageCache setObject:img forKey:objID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.profileImageView setImage:img];
                [cell setNeedsLayout];
            });
        });
    }else{
        [cell.profileImageView setImage:cellImage];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];    
    TFTweet *tweet = self.tweets[indexPath.row];
    
    if (tweet.status.length == 0) {
        dispatch_async(self.queue, ^{
            [TFTweetsAdapter getTweetByID:tweet.tweetID completion:^(NSMutableDictionary *atweet) {
                [tweet updateWithAttributes:atweet];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self configureTweetCell:tweet cell:cell];
                });
            }];
        });
    }
    
    if (tweet.edited) {
        dispatch_async(self.queue, ^{
            [TFTweetsAdapter getCategoriesByTweetID:tweet.tweetID completion:^(NSArray *categories) {
                tweet.categories = [NSMutableArray arrayWithArray:categories];
                tweet.edited = NO;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                [self configureTweetCell:tweet cell:cell];
                    });
            }];
        });
    }
    
    [self configureTweetCell:tweet cell:cell];
    
    return cell;
}

@end
