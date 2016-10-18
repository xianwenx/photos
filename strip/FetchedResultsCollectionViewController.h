//
//  FetchedResultsCollectionViewController.h
//  strip
//
//  Created by Christian on 8/25/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataController.h"

@protocol STRFetchRequestProvider <NSObject>
- (NSFetchRequest*)fetchRequestForContent;
@end

@interface FetchedResultsCollectionViewController : UICollectionViewController
@property (nonatomic, readwrite, strong)    CoreDataController          *coreDataController;
@property (nonatomic, readonly, strong)     NSFetchedResultsController      *fetchedResultsController;
@property (nonatomic, readwrite, weak)    id<STRFetchRequestProvider>       fetchRequestProvider;
@end
