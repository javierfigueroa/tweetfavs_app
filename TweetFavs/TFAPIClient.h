//
//  TFAPIClient.h
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TFAPIClient : AFHTTPRequestOperationManager

+ (TFAPIClient *)sharedClient;

@end
