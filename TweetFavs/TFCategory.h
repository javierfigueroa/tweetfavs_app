//
//  TFCategory.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFCategory : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *userID;

- (id)initWithAttributes:(NSDictionary*)data;

+ (void)getCategoriesById:(NSString*)userId andCompletion:(void(^)(NSArray *categories, NSError *error))completion;

@end
