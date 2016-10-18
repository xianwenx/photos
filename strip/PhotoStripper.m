//
//  PhotoStripper.m
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "PhotoStripper.h"

@implementation PhotoStripper

#pragma mark -- Encryption

- (void)copyImageWithAssetURL:(NSURL*)assetURL {
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil] lastObject];
    NSLog(@"asset description: %@", [asset description]);

    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            [PHAssetChangeRequest deleteAssets:@[asset]];
        } error:nil];


        // delete the original image


    }];
}


#pragma mark -- EXIF
- (void)performChange:(dispatch_block_t)changeBlock {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:changeBlock
                                      completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Finished deleting asset. %@", (success ? @"Success." : error));
    }];
}

- (void)modifyAsset:(PHAsset*)asset {
    NSLog(@"%@", [asset description]);

    [self performChange:^{
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest changeRequestForAsset:asset];
        [assetRequest setCreationDate:[NSDate date]];
        [assetRequest setLocation:nil];
    }];
 

}

- (void)deletePhotos:(NSArray<PHAsset *>*)photos {

}

- (NSError *)modifyPhotos {
    NSError *error = nil;

    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:nil];

    NSMutableArray *assets = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:asset];
        [self modifyAsset:asset];
    }];

    return error;
}

@end
