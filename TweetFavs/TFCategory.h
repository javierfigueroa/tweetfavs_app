//
//  TFCategory.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject, TFTweet;
@interface TFCategory : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) PFObject *parseCategory;

- (id)initWithParseObject:(PFObject*)parseObject;

//CRUD

+ (void)addCategoryWithName:(NSString*)name completion:(void(^)(TFCategory *category, NSError *error))completion;

+ (void)getCategoriesByTwitterId:(NSString*)twitterId completion:(void(^)(NSArray *categories, NSError *error))completion;

+ (void)getCategoriesByTweet:(TFTweet*)tweet completion:(void(^)(NSArray *categories, NSError *error))completion;

+ (void)updateCategory:(TFCategory*)category completion:(void(^)(TFCategory *category, NSError *error))completion;

+ (void)deleteCategory:(TFCategory*)category completion:(void(^)(NSArray *categories, NSError *error))completion;

@end
