//
//  PhotoPreviewViewController.m
//  strip
//
//  Created by Christian on 8/30/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "PhotoPreviewViewController.h"

@interface PhotoPreviewViewController ()
@property (nonatomic, readwrite, strong) UIImageView *imageView;
@end

@implementation PhotoPreviewViewController

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _imageView;
}

- (void)setImage:(UIImage*)image {
    [[self imageView] setImage:image];
}

- (void)loadView {
    [self setView:[self imageView]];
}

@end
