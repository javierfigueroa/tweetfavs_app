//
//  TFMenuViewController.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFMenuViewController.h"
#import "TFCategories.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"
#import "TFTweet.h"
#import "TFAppDelegate.h"
#import "IIViewDeckController.h"
#import "TFViewController.h"
#import "TFCategoryCell.h"
#import "TFEditCategoryCell.h"
#import "TFTheme.h"
#import "TFCategoriesDataSource.h"
#import "JSFlatButton.h"
#import "IIViewDeckController.h"
#import "TFTwitterManager.h"
#define trimString( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]


@interface TFMenuViewController ()

@end

@implementation TFMenuViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TFTheme customizeMenuController:self];
    
    
    [self.bottomLeftButton setFlatImage:[UIImage imageNamed:@"settings"]];
    [self.bottomRightButton setFlatImage:[UIImage imageNamed:@"account"]];
    [self.bottomRightButton setTitle:NSLocalizedString(@" Twitter", nil) forState:UIControlStateNormal];
    [self.bottomLeftButton setTitle:NSLocalizedString(@" Edit", nil) forState:UIControlStateNormal];
    [self.tableView registerNib:[UINib nibWithNibName:@"TFCategoryCell" bundle:nil] forCellReuseIdentifier:@"TFCategoryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TFEditCategoryCell" bundle:nil] forCellReuseIdentifier:@"TFEditCategoryCell"];
    
    TFTwitterManager *manager = [TFTwitterManager sharedManager];
    self.accountLabel.text = manager.twitterAccount.username;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCategories) name:TFCategoriesFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCategories) name:TFCategoriesEdited object:nil];
    
    self.tableDataSource = [[TFCategoriesDataSource alloc] init];
    self.tableView.dataSource = self.tableDataSource;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)didPressToolbarRightButton:(id)sender {
    //when editing this button is to save changes, otherwise to show the accounts actionsheet
    if (self.tableView.editing) {        
        NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
        [categories enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            TFCategory *category = (TFCategory*)obj;
            if (category.editing) {
                [TFCategory updateCategory:category completion:^(TFCategory *category, NSError *error) {
                    if (!error) {
                        NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
                        categories[category.ID] = category;
                    }
                }];
            }
        }];
        
        [self toggleEditMode];
    }else{
        TFTwitterManager *manager = [TFTwitterManager sharedManager];
        [manager getTwitterAccounts:^(NSObject *response, NSError *error) {
            if (error) {
                if (error.code != 600) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"No Twitter Accounts") message:NSLocalizedString(@"We couldn't find any authorized twitter accounts in your phone, please add one and try again", @"We couldn't find any authorized twitter accounts in your phone, please add one and try again") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                    [alert show];
                }
            }else{
                self.accountLabel.text = manager.twitterAccount.username;
                [TFTweetsAdapter getCategories];
            }
        }];
    }
}

- (IBAction)didPressToolbarLeftButton:(id)sender {
    [self toggleEditMode];
}

#pragma mark - Private Methods

- (void)setAllCategoryActive
{
    TFAppDelegate *appDelegate = (TFAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.viewController.title = @"TweetFavs";
    appDelegate.viewController.canLoadMore = YES;
    appDelegate.viewController.pullToRefreshEnabled = YES;
    [appDelegate.viewController setFooterViewVisibility:YES];
    
    [TFTweetsAdapter getFavoriteTweets];
    IIViewDeckController *deckController = self.viewDeckController;
    [deckController closeLeftViewAnimated:YES];
}

- (void)toggleEditMode
{
    //when editing this button is to finishing the editing mode
    NSMutableArray *reloadItems = [[NSMutableArray alloc] init];
    if (self.tableView.editing) {
        NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
        for (int i=0; i<categories.allKeys.count; i++) {
            NSString *key = categories.allKeys[i];
            TFCategory *category = categories[key];
            category.editing = NO;
            [reloadItems addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        };
    }
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self.tableView reloadRowsAtIndexPaths:reloadItems withRowAnimation:UITableViewRowAnimationFade];
    
    if (self.tableView.editing) {
        [self.bottomLeftButton setFlatImage:nil];
        [self.bottomRightButton setFlatImage:nil];
        [self.bottomRightButton setTitle:NSLocalizedString(@" Save", nil) forState:UIControlStateNormal];
        [self.bottomLeftButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    }else{
        [self.bottomLeftButton setFlatImage:[UIImage imageNamed:@"settings"]];
        [self.bottomRightButton setFlatImage:[UIImage imageNamed:@"account"]];
        [self.bottomRightButton setTitle:NSLocalizedString(@" Twitter", nil) forState:UIControlStateNormal];
        [self.bottomLeftButton setTitle:NSLocalizedString(@" Edit", nil) forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TFCategoriesEdited object:nil];
}

- (void)reloadCategories
{
    self.tableDataSource.sortedCategories = nil;
    [self.tableView reloadData];
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFCategory *category;
    category = [self.tableDataSource getCategoryByIndexPath:indexPath];
    
    if (self.tableView.editing) {
        if (!category.editing && indexPath.row > 0) {
            category.editing = YES;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
    }else{        
        category.editing = NO;
        if ([category.ID intValue] == -1) {
            [self setAllCategoryActive];
        }else{
            TFAppDelegate *appDelegate = (TFAppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.viewController.title = category.name;
            appDelegate.viewController.canLoadMore = NO;
            appDelegate.viewController.pullToRefreshEnabled = NO;
            [appDelegate.viewController setFooterViewVisibility:NO];
            
            [TFTweetsAdapter setTweets:category.tweets];
            IIViewDeckController *deckController = self.viewDeckController;
            [deckController closeLeftViewAnimated:YES];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.tableFooter;
}

#pragma mark - New Category Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableFooter.frame.size.height) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (trimString(textField.text).length > 0) {
        [TFCategory addCategoryWithName:textField.text completion:^(TFCategory *category, NSError *error) {
            if (!error) {
                NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
                textField.text = @"";
                categories[category.ID] = category;
                [self reloadCategories];
            }
        }];
    }
    
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
