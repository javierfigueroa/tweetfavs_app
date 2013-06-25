//
//  TFCategoriesDataSource.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/24/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFCategory, TFTweet;
@interface TFCategoriesDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, assign) TFTweet *tweet;
@property (nonatomic, strong) NSArray *sortedCategories;

- (TFCategory *)getCategoryByIndexPath:(NSIndexPath *)indexPath;

@end
