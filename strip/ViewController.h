//
//  ViewController.h
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataController.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) CoreDataController *coreDataController;
@end

