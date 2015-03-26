//
//  TFEditCategoryCell.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/23/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFEditCategoryCell.h"
#import "TFCategory.h"
#import "TFCategories.h"
#import "TweetFavs-Swift.h"

#define trimString( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@implementation TFEditCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textFieldView.placeholder = self.category.name;
}

#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    TabController *tabBar = (TabController*) [UIApplication sharedApplication].keyWindow.rootViewController;
//    UINavigationController *navBar = tabBar.selectedViewController.navigationController;
//    [self.menuTableView setFrame:<#(CGRect)#>:CGPointMake(0, navBar.navigationBar.frame.size.height) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (trimString(textField.text).length > 0) {
        self.category.name = textField.text;
    }
    
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.menuTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}
@end
