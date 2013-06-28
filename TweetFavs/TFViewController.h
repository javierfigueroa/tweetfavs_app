//
//  MLPViewController.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/19/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STableViewController.h"

@class TFFeedDataSource;
@interface TFViewController : STableViewController<UITableViewDelegate>

@property (assign, nonatomic) BOOL loadMoreEnabled;
@property (strong, nonatomic) TFFeedDataSource *tableViewDataSource;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *emptyStateView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyStateImage;
@property (weak, nonatomic) IBOutlet UILabel *emptyStateLabel;

@end
