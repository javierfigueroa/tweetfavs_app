//
//  TFTheme.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/24/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFTheme.h"
#import "TFFeedCell.h"
#import "TFTweetViewController.h"
#import "TFCategoryCell.h"
#import "JSFlatButton.h"
#import <QuartzCore/QuartzCore.h>
#import "TweetFavs-Swift.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@implementation TFTheme
+ (UIColor *)flatGrayColor
{
    return UIColorFromRGB(0x95A5A6);
}

+ (UIColor *)flatDarkGrayColor
{
    return UIColorFromRGB(0x7F8C8D);
}

+ (UIColor *)flatGreenColor
{
    return UIColorFromRGB(0x2ECC71);
}
+ (UIColor *)flatBlueColor
{
    return UIColorFromRGB(0x3498DB);
}
+ (UIColor *)flatYellowColor
{
    return UIColorFromRGB(0xF1C40F);
}

+ (UIColor *)flatWhiteColor
{
    return UIColorFromRGB(0xECF0F1);
}

+ (UIColor *)flatDarkWhiteColor
{
    return UIColorFromRGB(0xBDC3C7);
}

+ (UIColor*)mainColor
{
    return [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
}

+ (UIColor*)mainColorLight
{
    return [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:0.7f];
}

+ (UIColor*)neutralColor
{
    return [UIColor colorWithWhite:0.4 alpha:1.0];
}

+ (UIColor*)lightColor
{
    return [UIColor colorWithWhite:0.7 alpha:1.0];
}

+ (NSString*)fontName
{
    return @"Helvetica";// @"Optima-Regular";
}

+ (NSString*)boldFontName
{
    return @"Helvetica-Bold";//@"Optima-ExtraBlack";
}

+ (NSString*)navigationFontName
{
    return @"Helvetica-Bold";
}

+ (UIImage *)backgroundImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef composedImageContext = CGBitmapContextCreate(NULL,
                                                              10,
                                                              10,
                                                              8,
                                                              10*4,
                                                              colorSpace,
                                                              kCGImageAlphaPremultipliedFirst);
    
    CGColorSpaceRelease(colorSpace);
    
    
    CGContextSetFillColorWithColor(composedImageContext, [[self flatBlueColor] CGColor]);
    CGContextFillRect(composedImageContext, CGRectMake(0, 0, 10, 10));
    
    
    CGImageRef cgImage = CGBitmapContextCreateImage(composedImageContext);
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(composedImageContext);
    CGImageRelease(cgImage);
    
    return newImage;
}

+ (void)customizeTweetCell:(TFFeedCell *)cell
{
    UIColor* mainColor = [self mainColor];
    UIColor* neutralColor = [self neutralColor];
    
    UIColor* mainColorLight = [self mainColorLight];
    UIColor* lightColor = [self lightColor];
    
    cell.nameLabel.textColor =  mainColor;
    cell.nameLabel.font =  [UIFont fontWithName:[self boldFontName] size:14.0f];
    
    cell.updateLabel.textColor =  neutralColor;
    cell.updateLabel.font =  [UIFont fontWithName:[self fontName] size:12.0f];
    
    cell.dateLabel.textColor = lightColor;
    cell.dateLabel.font =  [UIFont fontWithName:[self fontName] size:8.0f];
    
    cell.commentCountLabel.textColor = mainColorLight;
    cell.commentCountLabel.font =  [UIFont fontWithName:[self fontName] size:10.0f];
    
    cell.likeCountLabel.textColor = mainColorLight;
    cell.likeCountLabel.font =  [UIFont fontWithName:[self fontName] size:10.0f];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (void)customizeTweetController:(TFTweetViewController *)controller
{
    UIColor* mainColor = [self mainColor];
    UIColor* neutralColor = [self neutralColor];
    
    UIColor* mainColorLight = [self mainColorLight];
    UIColor* lightColor = [self lightColor];
    
    controller.nameLabel.textColor =  mainColor;
    controller.nameLabel.font =  [UIFont fontWithName:[self boldFontName] size:14.0f];
    
    controller.statusLabel.textColor =  neutralColor;
    controller.statusLabel.font =  [UIFont fontWithName:[self fontName] size:12.0f];
    
    controller.timeLabel.textColor = lightColor;
    controller.timeLabel.font =  [UIFont fontWithName:[self fontName] size:8.0f];
    
    controller.categoriesLabel.textColor = mainColorLight;
    controller.categoriesLabel.font =  [UIFont fontWithName:[self fontName] size:10.0f];
    
    controller.retweetsLabel.textColor = mainColorLight;
    controller.retweetsLabel.font =  [UIFont fontWithName:[self fontName] size:10.0f];
    
    controller.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    controller.avatarView.clipsToBounds = YES;
    controller.avatarView.layer.cornerRadius = 2.0f;
    
    controller.avatarView.backgroundColor = [UIColor whiteColor];
    controller.avatarView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:0.6f].CGColor;
    controller.avatarView.layer.borderWidth = 1.0f;
    controller.avatarView.layer.cornerRadius = 2.0f;
    controller.avatarView.layer.cornerRadius = 20.0f;
    
    controller.categoriesTableView.backgroundColor = [UIColor whiteColor];
    controller.categoriesTableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:0.6];
}

+ (void)customizeFeedController:(TweetsController *)controller
{
    controller.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    controller.table.backgroundColor = [UIColor whiteColor];
//    controller.emptyStateLabel.textColor = [self mainColor];
}

+ (void)customizeCategoryCell:(TFCategoryCell *)cell
{
    UIColor* mainColor = [self mainColor];
    NSString* boldFontName = [self boldFontName];;
    cell.textLabel.textColor =  mainColor;
    cell.textLabel.font =  [UIFont fontWithName:boldFontName size:14.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (void)setBackButton:(UIViewController*)controller
{
    // Set the custom back button
    UIImage *buttonImage = [UIImage imageNamed:@"nav-back-icon"];
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.adjustsImageWhenDisabled = NO;
    
    
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, 25, 25);
    
    [button addTarget:controller.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    customBarItem.tintColor = [TFTheme flatDarkGrayColor];
    controller.navigationItem.leftBarButtonItem = customBarItem;
    controller.navigationItem.hidesBackButton = YES;
}

+ (void)customizeCategoriesController:(CategoriesController *)controller
{
    controller.tableView.backgroundColor = [UIColor whiteColor];
    controller.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:0.6];
    controller.tableView.allowsSelectionDuringEditing = YES;
}

+ (void)styleNavigationBar
{
//    CGSize size = CGSizeMake(320, 44);
//    UIColor* color = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
//    
//    UIGraphicsBeginImageContext(size);
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
//    CGContextSetFillColorWithColor(currentContext, color.CGColor);
//    CGContextFillRect(currentContext, fillRect);
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    
//    [[UIBarButtonItem appearance] setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[self backgroundImage] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UINavigationBar* navAppearance = [UINavigationBar appearance];
    [navAppearance setTintColor:[TFTheme flatBlueColor]];
    [navAppearance setBackgroundImage:[self backgroundImage] forBarMetrics:UIBarMetricsDefault];
    
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowOffset = CGSizeMake(0.0, 0.0);
    textShadow.shadowColor = [UIColor lightGrayColor];
    [navAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [TFTheme flatWhiteColor], NSForegroundColorAttributeName,
                                           [UIFont fontWithName:[self navigationFontName] size:18.0f], NSFontAttributeName, textShadow, NSShadowAttributeName,
                                           nil]];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[TFTheme flatWhiteColor],
                                    NSForegroundColorAttributeName,
                                    textShadow,
                                    NSShadowAttributeName,
                                    nil];
    
    [[UIBarButtonItem appearance] setTintColor:[TFTheme flatWhiteColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes                                                forState:UIControlStateNormal];
}

+ (void)styleTabBar:(UITabBar *)tabBar
{
    CGSize size = CGSizeMake(tabBar.frame.size.width, tabBar.frame.size.height);
//    UIColor* color = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, [TFTheme flatWhiteColor].CGColor);
    CGContextFillRect(currentContext, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[UITabBar appearance] setBackgroundImage:image];
    [[UITabBar appearance] setTintColor:[TFTheme flatBlueColor]];
    [[UITabBar appearance] setTranslucent:NO];
    
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowOffset = CGSizeMake(0.0, 0.0);
    textShadow.shadowColor = [UIColor lightGrayColor];

    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],
                                    NSForegroundColorAttributeName,
                                    textShadow,
                                    NSShadowAttributeName,
                                    nil];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
}

@end
