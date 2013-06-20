//
//  MLPViewController.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/19/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFFeedDataSource;
@interface TFViewController : UIViewController<UITableViewDelegate>

@property (strong, nonatomic) TFFeedDataSource *tableViewDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
