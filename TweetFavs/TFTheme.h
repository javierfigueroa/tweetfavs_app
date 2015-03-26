//
//  TFTheme.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/24/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFFeedCell, TFTweetViewController, TFCategoryCell, TFMenuViewController, TFViewController, TweetsController, CategoriesController;
@interface TFTheme : NSObject

+ (UIColor*)mainColor;
+ (UIColor*)mainColorLight;
+ (UIColor*)neutralColor;
+ (UIColor*)lightColor;
+ (NSString*)fontName;
+ (NSString*)boldFontName;
+ (NSString*)navigationFontName;

+ (void)customizeCategoryCell:(TFCategoryCell*)cell;
+ (void)customizeTweetCell:(TFFeedCell*)cell;
+ (void)customizeTweetController:(TFTweetViewController*)controller;
+ (void)customizeCategoriesController:(CategoriesController*)controller;
+ (void)customizeFeedController:(TweetsController*)controller;
+ (void)styleNavigationBar;
+ (void)styleTabBar:(UITabBar *)tabBar;

+ (void)setBackButton:(UIViewController*)controller;


@end
