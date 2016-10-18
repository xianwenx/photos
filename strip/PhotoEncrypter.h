//
//  PhotoEncrypter.h
//  strip
//
//  Created by Christian on 8/26/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface PhotoEncrypter : NSObject

- (NSData*)decryptedImageData:(NSData*)imageData;

- (NSData*)encryptedImageData:(NSData*)imageData;



@end
