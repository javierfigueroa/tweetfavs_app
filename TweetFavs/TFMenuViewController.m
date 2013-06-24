//
//  TFMenuViewController.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFMenuViewController.h"
#import "MLSocialNetworksManager.h"
#import "TFCategories.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"
#import "TFTweet.h"
#import "TFAppDelegate.h"
#import "IIViewDeckController.h"
#import "TFViewController.h"
#import "TFCategoryCell.h"
#import "TFEditCategoryCell.h"
#define trimString( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]


@interface TFMenuViewController ()

@property (nonatomic, strong) NSArray *sortedCategories;

@end

@implementation TFMenuViewController

- (NSArray *)sortedCategories
{
    if (!_sortedCategories) {
        NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
        _sortedCategories = [[categories allKeys] sortedArrayUsingSelector: @selector(compare:)];

    }
    
    return _sortedCategories;
}

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
    
    NSString* boldFontName = @"GillSans-Bold";
    self.accountLabel.textColor =[UIColor whiteColor];
    self.accountLabel.font =  [UIFont fontWithName:boldFontName size:18.0f];
    self.accountLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:0.6];
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"TFCategoryCell" bundle:nil] forCellReuseIdentifier:@"TFCategoryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TFEditCategoryCell" bundle:nil] forCellReuseIdentifier:@"TFEditCategoryCell"];
    
    MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
    UIColor *bgColor = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
    ;
    self.accountButton.backgroundColor = bgColor;
    self.toolbarView.backgroundColor = bgColor;
    self.accountLabel.text = manager.twitterAccount.username;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:TFCategoriesFetched object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        
        [self didPressToolbarLeftButton:nil];
    }else{
        MLSocialNetworksManager *manager = [MLSocialNetworksManager sharedManager];
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
    [self.bottomRightButton setTitle:self.tableView.editing ? NSLocalizedString(@"Save", nil) : NSLocalizedString(@"Account", nil) forState:UIControlStateNormal];
    [self.bottomLeftButton setTitle:self.tableView.editing ? NSLocalizedString(@"Cancel", nil) : NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
}


- (void)refresh
{
    [TFTweetsAdapter getFavoriteTweets];
    [self reloadCategories];
}

- (TFCategory *)getCategoryByIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    NSNumber *key = self.sortedCategories[indexPath.row];
    TFCategory *category = categories[key];
    return category;
}

- (void)reloadCategories
{
    _sortedCategories = nil;
    [self.tableView reloadData];
}


#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"TFCategoryCell";
    TFCategory *category = [self getCategoryByIndexPath:indexPath];
    
    if (category.editing) {
        TFEditCategoryCell *editCell = [tableView dequeueReusableCellWithIdentifier:@"TFEditCategoryCell"];
        editCell.menuTableView = tableView;
        editCell.category = category;
        return editCell;
    }else{
        TFCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        cell.textLabel.text = category.name;
        cell.detailTextLabel.text = [category.ID intValue] == -1 ? NSLocalizedString(@"All of your favorite tweets", nil) : [NSString stringWithFormat:@"%i tweets", category.tweets.count];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFCategory *category;
    category = [self getCategoryByIndexPath:indexPath];
    
    if (self.tableView.editing) {
        if (!category.editing) {
            category.editing = YES;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
    }else{        
        category.editing = NO;
        TFAppDelegate *appDelegate = (TFAppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.viewController.title = [category.ID intValue] == -1 ? @"TweetFavs" : category.name;
        
        if ([category.ID intValue] == -1) {
            [TFTweetsAdapter getFavoriteTweets];
            IIViewDeckController *deckController = appDelegate.deckController;
            [deckController closeLeftViewAnimated:YES];
        }else{
            [TFTweetsAdapter setTweets:category.tweets];
            IIViewDeckController *deckController = appDelegate.deckController;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //can edit every category except the 'all' category
    return indexPath.row > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TFCategory *category = [self getCategoryByIndexPath:indexPath];
        [TFCategory deleteCategory:category completion:^(NSArray *categories, NSError *error) {
            if (!error) {
                NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
                [categories removeObjectForKey:category.ID];
                [self reloadCategories];
            }
        }];
    }
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
