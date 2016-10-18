//
//  FetchedResultsCollectionViewController.m
//  strip
//
//  Created by Christian on 8/25/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "FetchedResultsCollectionViewController.h"

@interface FetchedResultsCollectionViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readwrite, strong) NSMutableArray             *objectChanges;
@property (nonatomic, readwrite, strong) NSMutableArray             *sectionChanges;
@property (nonatomic, readwrite, strong) NSFetchRequest             *fetchRequest;
@property dispatch_queue_t changesQueue;
@end


@implementation FetchedResultsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _changesQueue = dispatch_queue_create("com.example.MyQueue", NULL);
    [self initializeFetchedResultsController];
}


- (void)performFetch {
    NSManagedObjectContext      *managedObjectContext       = [[self coreDataController] managedObjectContext];
    NSFetchedResultsController  *fetchedResultsController   = [self fetchedResultsController];
    [managedObjectContext performBlock:^{
        NSError *fetchError = nil;

        if (![fetchedResultsController performFetch:&fetchError]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", fetchError, [fetchError userInfo]);
            abort();
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[self collectionView] reloadData];
            }];
        }
    }];
}

- (void)initializeFetchedResultsController
{
    NSFetchRequest          *fetchRequest           =   [self fetchRequest];
    NSManagedObjectContext  *managedObjectContext   =   [[self coreDataController] managedObjectContext];

    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:managedObjectContext
                                                                                                 sectionNameKeyPath:nil cacheName:@"Master"];
    fetchedResultsController.delegate = self;
    [self setFetchedResultsController:fetchedResultsController];

    [self performFetch];
}

- (NSMutableArray*)objectChanges {
    if (_objectChanges == nil) {
        _objectChanges = [[NSMutableArray alloc] init];
    }
    return _objectChanges;
}

- (NSMutableArray*)sectionChanges {
    if (_sectionChanges == nil) {
        _sectionChanges = [[NSMutableArray alloc] init];
    }
    return _sectionChanges;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

#pragma mark -- Core Data

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @[@(sectionIndex)];
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @[@(sectionIndex)];
            break;
    }

    dispatch_sync(_changesQueue, ^{
        [[self sectionChanges] addObject:change];
    });
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    dispatch_sync(_changesQueue, ^{
        [[self objectChanges] addObject:change];
    });
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    dispatch_sync(_changesQueue, ^{
        NSArray *sectionChanges = [[self sectionChanges] copy];
        if ([sectionChanges count] > 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:^{

                for (NSDictionary *change in sectionChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert: {
                                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            case NSFetchedResultsChangeDelete: {
                                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            case NSFetchedResultsChangeUpdate: {
                                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                        }
                    }];
                }
            } completion:nil];
            });
        }

        if ([[self objectChanges] count] > 0 && [[self sectionChanges] count] == 0)
        {

            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.collectionView performBatchUpdates:^{

                    for (NSDictionary *change in [self objectChanges])
                    {
                        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                            switch (type)
                            {
                                case NSFetchedResultsChangeInsert:  {
                                    [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                    break;
                                }
                                case NSFetchedResultsChangeDelete:  {
                                    [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                    break;

                                }
                                case NSFetchedResultsChangeUpdate:  {
                                    [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                    break;
                                }
                                case NSFetchedResultsChangeMove:  {
                                    [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                    break;
                                    
                                }
                            }
                        }];
                    }
                } completion:nil];

            });
        }

        [[self sectionChanges] removeAllObjects];
        [[self objectChanges] removeAllObjects];
        
        
    });
}

- (NSFetchRequest*)fetchRequest {
    if (_fetchRequest == nil) {
        _fetchRequest = [[self fetchRequestProvider] fetchRequestForContent];
    }
    return _fetchRequest;
}

@end
