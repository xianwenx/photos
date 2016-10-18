//
//  SynchronizedUIActivityIndicatorView.m
//  photos
//
//  Created by Christian on 9/6/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "SynchronizedUIActivityIndicatorView.h"

@interface SynchronizedUIActivityIndicatorView ()
@property (nonatomic, readwrite, assign) BOOL shouldStartAnimating;
@end

@implementation SynchronizedUIActivityIndicatorView

- (void)startAnimating {
//    [super startAnimating];
    _shouldStartAnimating = YES;
    double currentTime = CACurrentMediaTime();
    double animationLength = 1.0;
    double mod = fmod(currentTime, animationLength);
    double difference = (animationLength - mod);
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, difference*NSEC_PER_SEC);
    dispatch_after(when, dispatch_get_main_queue(), ^{
//        [super stopAnimating];
        if (_shouldStartAnimating) {
            [super startAnimating];
        }
    });

}

- (void)stopAnimating {
    _shouldStartAnimating = NO;
    [super stopAnimating];
}

- (BOOL)isAnimating {
    return [super isAnimating];
}

@end
