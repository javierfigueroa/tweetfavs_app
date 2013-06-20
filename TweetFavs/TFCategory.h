//
//  TFCategory.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFCategory : NSObject

+ (void)getCategoriesById:(NSString*)userId andCompletion:(void(^)(NSArray *categories, NSError *error))completion;

@end
