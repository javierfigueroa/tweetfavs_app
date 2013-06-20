//
//  TFCategory.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFCategory.h"
#import "TFAPIClient.h"

@implementation TFCategory

- (id)initWithAttributes:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

+ (void)getCategoriesById:(NSString*)userId andCompletion:(void(^)(NSArray *categories, NSError *error))completion
{
    NSString *url = [NSString stringWithFormat:@"categories/%@.json", userId];
    [[TFAPIClient sharedClient] getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *categories = [NSJSONSerialization JSONObjectWithData:responseObject options:nil error:nil];
        
#if DEBUG
        NSLog(@"%@", categories);
#endif
        
        if (completion) {
            completion(categories, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
