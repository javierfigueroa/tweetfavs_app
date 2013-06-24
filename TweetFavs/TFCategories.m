//
//  TFCategories.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFCategories.h"
#import "TFCategory.h"
#import "TFTweetsAdapter.h"
#import "MLSocialNetworksManager.h"

NSString *const TFCategoriesFetched = @"TFCategoriesFetched";

@implementation TFCategories

- (NSMutableDictionary *)categories
{
    if (!_categories) {
        _categories = [[NSMutableDictionary alloc] init];
    }
    
    return _categories;
}

+ (TFCategories *) sharedCategories {
    static TFCategories *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TFCategories alloc] init];
    });
    
    return _sharedClient;
}


- (id)init
{
    self = [super init];
    if (self) {
        TFCategory *all = [[TFCategory alloc] init];
        all.name = NSLocalizedString(@"All", nil);
        all.ID = [NSNumber numberWithInt:-1];
        self.categories[all.ID] = all;    }
    return self;
}

@end
