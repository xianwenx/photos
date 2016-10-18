//
//  SinglePhotoImportOperation.m
//  photos
//
//  Created by Christian Wen on 9/7/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "SinglePhotoImportOperation.h"
#import "PhotoEncrypter.h"
@import Photos;
@interface SinglePhotoImportOperation ()
@property (nonatomic, readwrite, strong) PHAsset                *asset;

@end

@implementation SinglePhotoImportOperation

- (instancetype)initWithPHAsset:(PHAsset*)asset {
    if ((self = [super init])) {
        _asset                  =   asset;
    }
    return self;
}

- (void)main {
    NSString *assetIdentifier = [[self asset] localIdentifier];

    PHImageManager          *imageManager   = [PHImageManager defaultManager];
    PHImageRequestOptions   *options        = [[PHImageRequestOptions alloc] init];
    [options setSynchronous:YES];
    
    
    __block     NSData      *imageData              = nil;
    __block     NSData      *thumbnailData          = nil;
    NSString    *localIdentifier        = [[self asset] localIdentifier];
    NSDate      *creationDate           = [[self asset] creationDate];
    
    
    [imageManager requestImageDataForAsset:[self asset]
                                   options:options
                             resultHandler:^(NSData * _Nullable result,
                                             NSString * _Nullable dataUTI,
                                             UIImageOrientation orientation,
                                             NSDictionary * _Nullable info) {
                                 imageData = result;
                             }];
    
    
    [imageManager requestImageForAsset:[self asset]
                            targetSize:CGSizeMake(100.0, 100.0)
                           contentMode:PHImageContentModeAspectFill
                               options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                   thumbnailData = UIImageJPEGRepresentation(result, 0);
                               }];

    
    NSManagedObject         *protectedImage         = nil;
    
    protectedImage = [NSEntityDescription insertNewObjectForEntityForName:kSTRProtectedImageEntityName
                                                   inManagedObjectContext:managedObjectContext];
    
    NSData *encryptedImage = [[self photoEncrypter] encryptedImageData:imageData];
    NSData *encryptedThumb = [[self photoEncrypter] encryptedImageData:thumbnailData];
    
    [protectedImage setValue:encryptedImage forKey:@"imageData"];
    [protectedImage setValue:encryptedThumb forKey:@"thumbnailData"];
    [protectedImage setValue:localIdentifier forKey:@"localIdentifier"];
    [protectedImage setValue:creationDate forKey:@"creationDate"];
    


    
}

@end.
