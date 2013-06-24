//
//  TFEditCategoryCell.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/23/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFCategory;
@interface TFEditCategoryCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldView;
@property (weak, nonatomic) UITableView *menuTableView;
@property (weak, nonatomic) TFCategory *category;


@end
