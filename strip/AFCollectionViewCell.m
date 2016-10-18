//
//  AFCollectionViewCell.m
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "AFCollectionViewCell.h"


@implementation AFCollectionViewCell

- (void)setImage:(UIImage *)image
{
    [[self imageView] setImage:image];
    if (image) {
        [[self activityIndicator] stopAnimating];
    } else {
        [[self activityIndicator] startAnimating];
    }
}

@end
