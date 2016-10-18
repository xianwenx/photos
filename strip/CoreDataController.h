//
//  CoreData.h
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

@import Foundation;
@import CoreData;
@interface CoreDataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext*)newPrivateContext;
@end
