//
//  TFCategories.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TFCategoriesFetched;

@interface TFCategories : NSObject

- (void)fetchCategories;

+ (TFCategories *)sharedCategories;

@property (nonatomic, strong) NSMutableArray *categories;

@end
