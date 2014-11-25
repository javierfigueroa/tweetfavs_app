//
//  TFCategoriesDataSource.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/24/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFCategoriesDataSource.h"
#import "TFEditCategoryCell.h"
#import "TFCategoryCell.h"
#import "TFCategories.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"
#import "TFTweet.h"

@interface TFCategoriesDataSource()


@end

@implementation TFCategoriesDataSource

- (NSArray *)sortedCategories
{
    if (!_sortedCategories) {
        NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
        _sortedCategories = [[categories allKeys] sortedArrayUsingSelector: @selector(compare:)];
    }
    
    return _sortedCategories;
}

- (TFCategory *)getCategoryByIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *categories = [[TFCategories sharedCategories] categories];
    NSNumber *key = self.sortedCategories[indexPath.row];
    TFCategory *category = categories[key];
    return category;
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
        editCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return editCell;
    }else{
        TFCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        cell.textLabel.text = category.name;
        cell.detailTextLabel.text = [category.ID intValue] == -1 ? NSLocalizedString(@"All of your favorite tweets", nil) : [NSString stringWithFormat:@"%lu tweets", (unsigned long)category.tweets.count];
        
        if (self.tweet) {
            cell.accessoryType = [TFTweetsAdapter findTweetById:self.tweet.tweetID inCategory:category] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
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
                self.sortedCategories = nil;
                [TFTweetsAdapter getCategories];
            }
        }];
    }
}


@end
