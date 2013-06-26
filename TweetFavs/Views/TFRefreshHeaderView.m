//
//  TFRefreshHeaderView.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/26/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFRefreshHeaderView.h"

@implementation TFRefreshHeaderView

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TFRefreshHeaderView" owner:self options:nil];
        self = [nib objectAtIndex:0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
