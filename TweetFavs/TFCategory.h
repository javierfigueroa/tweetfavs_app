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
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSMutableArray *tweets;

- (id)initWithAttributes:(NSDictionary*)data;

//CRUD

+ (void)addCategoryWithName:(NSString*)name completion:(void(^)(TFCategory *category, NSError *error))completion;

+ (void)updateCategory:(TFCategory*)category completion:(void(^)(TFCategory *category, NSError *error))completion;

+ (void)getCategoriesById:(NSString*)userId andCompletion:(void(^)(NSArray *categories, NSError *error))completion;

+ (void)getCategoriesByTweetId:(NSNumber*)tweetID andCompletion:(void(^)(NSArray *categories, NSError *error))completion;

+ (void)deleteCategory:(TFCategory*)category completion:(void(^)(NSArray *categories, NSError *error))completion;
@end
