//
//  TFAPIClient.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAPIBaseURLString =
//@"http://0.0.0.0:3000/";
@"http://tweetfavs.heroku.com/";

@implementation TFAPIClient

+ (TFAPIClient *)sharedClient {
    static TFAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TFAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=utf-8"];
    
    return self;
}


@end
