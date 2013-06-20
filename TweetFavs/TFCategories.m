//
//  TFCategories.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFCategories.h"
#import "TFCategory.h"
#import "MLSocialNetworksManager.h"

NSString *const TFCategoriesFetched = @"TFCategoriesFetched";

@implementation TFCategories

- (NSMutableArray *)categories
{
    if (!_categories) {
        _categories = [[NSMutableArray alloc] init];
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

- (void)fetchCategories
{
    ACAccount *twitterAccount = [[MLSocialNetworksManager sharedManager] twitterAccount];
    NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
    [TFCategory getCategoriesById:twitterId andCompletion:^(NSArray *categories, NSError *error) {
        [self.categories removeAllObjects];
        if (!error) {
            [self.categories addObjectsFromArray:categories];
            TFCategory *all = [[TFCategory alloc] init];
            all.name = NSLocalizedString(@"All", nil);
            all.ID = [NSNumber numberWithInt:-1];
            [self.categories insertObject:all atIndex:0];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TFCategoriesFetched object:nil];
    }];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self fetchCategories];
    }
    return self;
}

@end
