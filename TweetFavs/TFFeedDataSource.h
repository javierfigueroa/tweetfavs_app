//
//  TFFeedDataSource.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFFeedDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *tweets;

- (void)getFavoriteTweetsSinceID:(NSNumber*)tweetID;

@end
