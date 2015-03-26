//
//  TFAPIClient.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFAPIClient.h"


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
    if (self) {
        
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
    }
    
    return self;
}


@end
