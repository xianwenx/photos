//
//  CoreData.m
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "CoreDataController.h"

@implementation CoreDataController
@synthesize managedObjectContext            = _managedObjectContext;
@synthesize managedObjectModel              = _managedObjectModel;
@synthesize persistentStoreCoordinator      = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    NSURL           *result         = nil;
    NSArray         *URLs           = nil;
    NSFileManager   *fileManager    = [NSFileManager defaultManager];

    URLs    = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    result  = [URLs lastObject];

    return result;
}

- (NSURL *)storeURL {
    NSURL       *result = nil;
    result              = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"aaasdfds.sqlite"];

    return result;
}

- (NSURL *)modelURL {
    NSURL       *result     =   nil;
    NSBundle    *mainBundle =   [NSBundle mainBundle];
    result                  =   [mainBundle URLForResource:@"DataModel"
                                             withExtension:@"momd"];

    return result;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]];
    }
    return _managedObjectModel;
}

- (NSError *)persistentStoreCreationError:(NSError*)coreDataError {
    NSError             *result         = nil;
    NSString            *failureReason  = @"There was an error creating or loading the application's saved data.";
    NSMutableDictionary *dict           = [NSMutableDictionary dictionary];

    dict[NSLocalizedDescriptionKey]         = @"Failed to initialize the application's saved data";
    dict[NSLocalizedFailureReasonErrorKey]  = failureReason;
    dict[NSUnderlyingErrorKey]              = coreDataError;

    result = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];

    return result;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error]) {
            NSError *publicError = [self persistentStoreCreationError:error];
            NSLog(@"Unresolved error %@, %@", publicError, [publicError userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }

    }

    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (NSManagedObjectContext*)newPrivateContext
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return context;
}

- (void)saveContext {
    NSManagedObjectContext  *managedObjectContext   = [self managedObjectContext];

    [managedObjectContext performBlock:^{
        NSError                 *error                  = nil;

        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }];
}


@end
