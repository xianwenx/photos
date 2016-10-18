//
//  PhotoStripper.h
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

@import Foundation;
@import Photos;

@interface PhotoStripper : NSObject
- (NSError *)modifyPhotos;
- (void)copyImageWithAssetURL:(NSURL*)assetURL;
@end
