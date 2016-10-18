//
//  ViewController.m
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "ViewController.h"
#import "PhotoStripper.h"
#import "CollectionViewController.h"
#import "PhotoEncrypter.h"
@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, readwrite, strong)            PhotoEncrypter              *photoEncrypter;
@property (nonatomic, readwrite, weak)  IBOutlet    UIButton                    *importButton;
@property (weak, nonatomic) IBOutlet UIButton *importAllButton;
@property (nonatomic, readwrite, strong)            UIImagePickerController     *imagePickerController;
@property (nonatomic, readwrite, weak)              CollectionViewController    *collectionViewController;
@property (nonatomic, readwrite, strong)            NSOperationQueue            *operationQueue;
@end

@implementation ViewController
static NSString * const kSTRProtectedImageEntityName = @"ProtectedImage";

- (UIImagePickerController *)imagePickerController {
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        [_imagePickerController setDelegate:self];
    }
    return _imagePickerController;
}

- (NSOperationQueue *)operationQueue {
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

- (PhotoEncrypter *)photoEncrypter {
    if (_photoEncrypter == nil) {
        _photoEncrypter = [[PhotoEncrypter alloc] init];
    }
    return _photoEncrypter;
}

- (PHFetchResult*)allPhotos {
    PHFetchResult   *fetchResult   = nil;

    fetchResult                    = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];

    return fetchResult;

}

- (PHFetchResult *)assetsForURLs:(NSArray*)assetURLs {
    PHFetchResult   *fetchResult   = nil;

    fetchResult                    = [PHAsset fetchAssetsWithALAssetURLs:assetURLs options:nil];

    return fetchResult;
}

- (void)deleteAssets:(NSArray*)assets completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    PHPhotoLibrary      *photoLibrary   = nil;

    dispatch_block_t    changeBlock     = ^{
        [PHAssetChangeRequest deleteAssets:assets];
    };
    [photoLibrary performChanges:changeBlock completionHandler:completion];
}


- (void)photoExistsWithIdentifier:(NSString*)identifier completion:(void(^)(BOOL exists))completion {
    NSFetchRequest  *fetch      =   [NSFetchRequest fetchRequestWithEntityName:@"ProtectedImage"];
    NSPredicate     *predicate  =   [NSPredicate predicateWithFormat:@"localIdentifier == %@", identifier];

    [fetch setPredicate:predicate];

    [[[self coreDataController] managedObjectContext] performBlock:^{
        NSArray *results    =   [[[self coreDataController] managedObjectContext] executeFetchRequest:fetch error:nil];
        BOOL    result      =   [results count];

        completion(result);
    }];
}

- (void)import {

}

- (void)encryptPhotos:(PHFetchResult *)photoAssets completion:(void (^)(BOOL success, NSError *error))completion {

    dispatch_group_t group = dispatch_group_create();

    [photoAssets enumerateObjectsUsingBlock:^(PHAsset   * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {

            NSManagedObjectContext  *managedObjectContext   = [[self coreDataController] newPrivateContext];
        managedObjectContext.parentContext = self.coreDataController.managedObjectContext;

            dispatch_group_enter(group);

            [managedObjectContext performBlock:^{

                NSFetchRequest  *fetch      =   [NSFetchRequest fetchRequestWithEntityName:@"ProtectedImage"];
                NSPredicate     *predicate  =   [NSPredicate predicateWithFormat:@"localIdentifier == %@", [asset localIdentifier]];

                [fetch setPredicate:predicate];

                NSArray *results    =   [[[self coreDataController] managedObjectContext] executeFetchRequest:fetch error:nil];
                BOOL    result      =   [results count];

                if (result) {
                    dispatch_group_leave(group);

                    return;
                }

                PHImageManager  *imageManager   = [PHImageManager defaultManager];
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                [options setSynchronous:YES];


                __block     NSData      *imageData              = nil;
                __block     NSData      *thumbnailData          = nil;
                NSString    *localIdentifier        = [asset localIdentifier];
                NSDate      *creationDate           = [asset creationDate];


                [imageManager requestImageDataForAsset:asset
                                               options:options
                                         resultHandler:^(NSData * _Nullable result,
                                                         NSString * _Nullable dataUTI,
                                                         UIImageOrientation orientation,
                                                         NSDictionary * _Nullable info) {
                                             imageData = result;
                                         }];


                [imageManager requestImageForAsset:asset
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

                if(idx % 10 == 0){
                        NSError                 *error                  = nil;

                        if (managedObjectContext != nil) {
                            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                                // Replace this implementation with code to handle the error appropriately.
                                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                abort();
                            }
                        }
                    [[self coreDataController] saveContext];

                }
                dispatch_group_leave(group);

            }];


    }];
    

    long groupResult = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);


    [[self coreDataController] saveContext];
    if (completion != nil) {
        completion(YES, nil);
    }




}

- (IBAction)importPhotos:(id)sender {
    [self presentViewController:[self imagePickerController] animated:YES completion:nil];
}

- (void)addPhotos:(PHFetchResult*)assets {
    [self startImport];
    [[self operationQueue] addOperationWithBlock:^{
        [self encryptPhotos:assets completion:^(BOOL success, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self stopImport];
            }];
        }];
    }];

}

- (IBAction)importAllPhotos:(id)sender {
    PHFetchResult *assets = [self allPhotos];
    [self addPhotos:assets];
}

#pragma mark -- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (picker == [self imagePickerController]) {

        [picker dismissViewControllerAnimated:YES completion:nil];
        NSURL *referenceURL = info[UIImagePickerControllerReferenceURL];
        PHFetchResult *assets = [self assetsForURLs:@[referenceURL]] ;
        [self addPhotos:assets];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (picker == [self imagePickerController]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)startImport {
    [[self activityIndicator] startAnimating];
    [[self importButton] setHidden:YES];
    [[self importAllButton] setHidden:YES];
}

- (void)stopImport {
    [[self activityIndicator] stopAnimating];
    [[self importButton] setHidden:NO];
    [[self importAllButton] setHidden:NO];

}

#pragma mark -- UINavigationControllerDelegate

// No implementation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"collection view embed"]) {
        CollectionViewController * childViewController = (CollectionViewController *) [segue destinationViewController];
        self.collectionViewController = childViewController;
        self.collectionViewController.coreDataController = self.coreDataController;
    }
}

@end
