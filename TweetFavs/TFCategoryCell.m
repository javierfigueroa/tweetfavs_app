//
//  TFCategoryCell.m
//  TweetFavs
//
//  Created by Javier Figueroa on 6/20/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "TFCategoryCell.h"

@implementation TFCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)awakeFromNib{
    
    UIColor* mainColor = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
    NSString* boldFontName = @"Optima-ExtraBlack";
    self.textLabel.textColor =  mainColor;
    self.textLabel.font =  [UIFont fontWithName:boldFontName size:14.0f];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end
