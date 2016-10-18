//
//  PhotoEncrypter.m
//  strip
//
//  Created by Christian on 8/26/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "PhotoEncrypter.h"
#import "photos-Swift.h"
#import "KeyController.h"

@interface PhotoEncrypter ()
@property (nonatomic, readwrite, strong) KeyController *keyController;
@property (nonatomic, readwrite, copy)  NSString *key;
@property dispatch_queue_t queue;

@end

@implementation PhotoEncrypter

- (instancetype)init {
    if ((self = [super init])) {
        _queue = dispatch_queue_create("com.symantec.photoEncrypter", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (KeyController *)keyController {
    if (_keyController == nil) {
        _keyController = [[KeyController alloc] init];
    }
    return _keyController;
}


- (NSData*)decryptedImageData:(NSData*)imageData {
    __block NSData *result = nil;

    NSError     *keyError   = nil;
    NSString    *key        = [[self keyController] keyWithError:&keyError];

    if (key != nil) {
    NSError *cryptorError   = nil;

    result         = [RNCryptor decryptData:imageData password:key error:&cryptorError];

    }

    return result;
}

- (NSData*)encryptedImageData:(NSData*)imageData  {
    __block NSData *result = nil;

    NSError     *keyError   = nil;
    NSString    *key        = [[self keyController] keyWithError:&keyError];

    if (key != nil) {
        result         = [RNCryptor encryptData:imageData password:key];
    }
    
    return result;
}

@end
