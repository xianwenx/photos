//
//  VanNuysController.m
//  strip
//
//  Created by Christian on 8/25/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "KeyController.h"
#import "UICKeyChainStore.h"

static const int        kSTRStringLength  = 16;
static NSString * const kSTRStringKey     = @"XXXXXXXX";

@interface KeyController ()
@property (nonatomic, readwrite, strong) NSOperationQueue *operationQueue;

@end

@implementation KeyController

- (NSOperationQueue *)operationQueue {
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:1];
    }
    return _operationQueue;
}

#pragma mark - Key generation

errno_t randomCopyBytes(long length, uint8_t *bytes) {
    errno_t errorCode   = 0;
    int     result      = 0;

    result = SecRandomCopyBytes(kSecRandomDefault, length, bytes);

    if (result == -1) {
        errorCode = errno;
    }

    return errorCode;
}

- (errno_t)randomCopyBytes:(NSInteger)length bytes:(uint8_t *)bytes error:(NSError *__autoreleasing *)error {
    errno_t errorCode = randomCopyBytes(length, bytes);

    if (errorCode != 0) {
        NSError *e = [NSError errorWithDomain:NSPOSIXErrorDomain
                                         code:errorCode
                                     userInfo:nil];
        if (error) {
            *error = e;
        }
    }

    return errorCode;
}

- (NSString *)keyStringWithLength:(NSInteger)length {
    NSMutableString     *bytesString            = nil;
    NSString            *result                 = nil;
    NSError             *copyBytesError         = nil;
    errno_t             errorCode               = 0;
    uint8_t             randomBytes[length];

    errorCode = [self randomCopyBytes:length bytes:randomBytes error:&copyBytesError];
    
    if (errorCode == 0) {
        bytesString = [[NSMutableString alloc] initWithCapacity:length*2];
        for (NSInteger index = 0; index < length; index++) {
            [bytesString appendFormat: @"%02x", randomBytes[index]];
        }
        result = [bytesString copy];
    }
    return result;
}

#pragma mark - Keychain

+ (UICKeyChainStore*)sharedKeychain {
    NSString *keychainServiceDomain = @"com.symantec.strip";
    UICKeyChainStore *keychainStore = [UICKeyChainStore keyChainStoreWithService:keychainServiceDomain];
    return keychainStore;
}

- (NSString*)keyWithError:(NSError *__autoreleasing *)error {
    NSString            *result     = nil;
    
    UICKeyChainStore    *keychain   = [[self class] sharedKeychain];

    result = [keychain stringForKey:kSTRStringKey error:error];

    if (result == nil) {
        result = [self keyStringWithLength:kSTRStringLength];
        [keychain setString:result forKey:kSTRStringKey];

    }

    return result;
}



@end
