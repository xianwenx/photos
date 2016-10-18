//
//  AppDelegate.m
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataController.h"
#import "ViewController.h"
@interface AppDelegate ()
@property (strong, nonatomic) CoreDataController *coreDataController;
@end

@implementation AppDelegate

- (instancetype)init {
    if ( (self = [super init]) ) {
        _coreDataController = [[CoreDataController alloc] init];
    }
    return self;
}

- (void)setRootViewControllerCoreDataController:(CoreDataController*)coreDataController {
    ViewController *rootViewController = (ViewController *) self.window.rootViewController;
    [rootViewController setCoreDataController:coreDataController];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setRootViewControllerCoreDataController:_coreDataController];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[self coreDataController] saveContext];
}

@end
