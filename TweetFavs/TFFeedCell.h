//
//  MLPFeedCell.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFFeedCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;

@property (nonatomic, weak) IBOutlet UIImageView* picImageView;

@property (nonatomic, weak) IBOutlet UIView* picImageContainer;

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;

@property (nonatomic, weak) IBOutlet UILabel* updateLabel;

@property (nonatomic, weak) IBOutlet UILabel* dateLabel;

@property (nonatomic, weak) IBOutlet UILabel* commentCountLabel;

@property (nonatomic, weak) IBOutlet UILabel* likeCountLabel;

@end
