//
//  MLPAppDelegate.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/19/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

@class TFViewController;

@interface TFAppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TFViewController *viewController;

@end
