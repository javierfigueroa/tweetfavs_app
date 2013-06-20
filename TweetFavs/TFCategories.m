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
        ACAccount *twitterAccount = [[MLSocialNetworksManager sharedManager] twitterAccount];
        NSString *twitterId = [twitterAccount valueForKeyPath:@"properties.user_id"];
        [TFCategory getCategoriesById:twitterId andCompletion:^(NSArray *categories, NSError *error) {
            if (!error) {
                self.categories = [[NSMutableArray alloc] initWithArray:categories];
                [[NSNotificationCenter defaultCenter] postNotificationName:TFCategoriesFetched object:nil];
            }
        }];
    }
    return self;
}

@end
