//
//  AFCollectionViewCell.h
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AFCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)setImage:(UIImage *)image;

@end
