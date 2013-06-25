//
//  TFMenuViewController.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFCategoriesDataSource, JSFlatButton;
@interface TFMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIView *tableHeader;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet JSFlatButton *bottomLeftButton;
@property (weak, nonatomic) IBOutlet JSFlatButton *bottomRightButton;

@property (strong, nonatomic) IBOutlet UIView *tableFooter;
@property (strong, nonatomic) TFCategoriesDataSource *tableDataSource;

- (IBAction)didPressToolbarRightButton:(id)sender;
- (IBAction)didPressToolbarLeftButton:(id)sender;

@end
