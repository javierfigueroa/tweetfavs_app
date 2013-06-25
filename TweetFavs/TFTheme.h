//
//  TFTheme.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/24/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFFeedCell, TFTweetViewController, TFCategoryCell, TFMenuViewController, TFViewController;
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
+ (void)customizeMenuController:(TFMenuViewController*)controller;
+ (void)customizeFeedController:(TFViewController*)controller;
+ (void)styleNavigationBar;

+ (void)setBackButton:(UIViewController*)controller;


@end
