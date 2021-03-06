//
//  TFCategories.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TFCategoriesFetched;
extern NSString *const TFCategoriesEdited;
extern NSString *const TFTweetsLoaded;

@interface TFCategories : NSObject

+ (TFCategories *)sharedCategories;

@property (nonatomic, strong) NSMutableDictionary *categories; /*cat id, category obj */

@end
