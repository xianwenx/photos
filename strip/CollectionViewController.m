//
//  CollectionViewController.m
//  strip
//
//  Created by Christian on 8/23/16.
//  Copyright © 2016 Christian. All rights reserved.
//

#import "CollectionViewController.h"
#import "AFCollectionViewCell.h"
#import "PhotoEncrypter.h"
#import "PhotoPreviewViewController.h"
@import CoreData;

@interface CollectionViewController () <NSFetchedResultsControllerDelegate, STRFetchRequestProvider, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property (nonatomic, readwrite, strong) PhotoEncrypter                 *photoEncrypter;
@property (nonatomic, readwrite, strong) UILongPressGestureRecognizer   *gestureRecognizer;
@property (nonatomic, readwrite, strong) PhotoPreviewViewController     *viewController;
@property (nonatomic, readwrite, assign) CGRect                         fromFrame;
@property (nonatomic, readwrite, strong) NSCache                        *cache;
@property (nonatomic, readwrite, strong) NSOperationQueue               *operationQueue;
@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [gestureRecognizer setMinimumPressDuration:0.15];
    [gestureRecognizer setDelegate:self];
    [gestureRecognizer setDelaysTouchesBegan:NO];
    [[self collectionView] addGestureRecognizer:gestureRecognizer];
    [self setGestureRecognizer:gestureRecognizer];

    _cache = [[NSCache alloc] init];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint     point       = [gestureRecognizer locationInView:[self collectionView]];
        NSIndexPath *indexPath  = [[self collectionView] indexPathForItemAtPoint:point];

        if (indexPath != nil) {
            [self displayImageAtIndexPath:indexPath];
        }

    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded || [gestureRecognizer state] == UIGestureRecognizerStateCancelled) {
        [self hideImage];
    }
}


#pragma mark -- Image Preview
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.20;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if (toViewController == [self viewController] && fromViewController == [self parentViewController]) {
        [[transitionContext containerView] addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        toViewController.view.frame = _fromFrame;

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            //        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
            toViewController.view.alpha = 1;
            toViewController.view.frame = self.collectionView.frame;
        } completion:^(BOOL finished) {
            //        fromViewController.view.transform = CGAffineTransformIdentity;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            
        }];

    } else if (toViewController == [self parentViewController] && fromViewController == [self viewController]) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            //        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
            fromViewController.view.alpha = 0;
            fromViewController.view.frame = _fromFrame;
        } completion:^(BOOL finished) {
            //        fromViewController.view.transform = CGAffineTransformIdentity;
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];


        }];

    }

   }

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (void)displayImageAtIndexPath:(NSIndexPath *)indexPath {
    AFCollectionViewCell    *cell = (AFCollectionViewCell *) [[self collectionView] cellForItemAtIndexPath:indexPath];



    PhotoPreviewViewController *viewController = [[PhotoPreviewViewController alloc] init];
    [viewController setImage:[[cell imageView] image]];
    [[viewController view] setBackgroundColor:[UIColor clearColor]];
    [viewController setModalPresentationStyle:UIModalPresentationCustom];
    [viewController setTransitioningDelegate:self];

    [[[self fetchedResultsController] managedObjectContext] performBlock:^{
        NSManagedObject     *imageObject    = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSData *encryptedImageData = [imageObject valueForKey:@"imageData"];

        NSData *imageData = [[self photoEncrypter] decryptedImageData:encryptedImageData];

        UIImage                 *image      = [UIImage imageWithData:imageData];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [viewController setImage:image];
        }];

    }];


/**
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletap:)];
    [[viewController view] addGestureRecognizer:tapGestureRecognizer];
**/
    [[self collectionView] removeGestureRecognizer:[self gestureRecognizer]];
    [[viewController view] addGestureRecognizer:[self gestureRecognizer]];
    _fromFrame = [[self collectionView] convertRect:cell.frame toView:[self view]];
    [self presentViewController:viewController animated:YES completion:^{

    }];
    [self setViewController:viewController];
}

- (void)hideImage {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[[self viewController] view] removeGestureRecognizer:[self gestureRecognizer]];
    [[self collectionView] addGestureRecognizer:[self gestureRecognizer]];

}

- (id<STRFetchRequestProvider>)fetchRequestProvider {
    return self;
}

- (PhotoEncrypter*)photoEncrypter {
    if (_photoEncrypter == nil) {
        _photoEncrypter = [[PhotoEncrypter alloc] init];
    }
    return _photoEncrypter;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    AFCollectionViewCell    *someCell   = (AFCollectionViewCell*) cell;
    someCell.tag = indexPath.item;

    [someCell setImage:nil];
    [[[self fetchedResultsController] managedObjectContext] performBlock:^{
        NSManagedObject     *imageObject    = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSData *encryptedImageData = [imageObject valueForKey:@"thumbnailData"];
        NSData *imageData = [[self photoEncrypter] decryptedImageData:encryptedImageData];
        UIImage                 *image      = [UIImage imageWithData:imageData];

           if (someCell.tag == indexPath.item) {
               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   [someCell setImage:image];
               }];
           }


    }];

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

}


- (NSIndexPath *)keyForIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath class] == [NSIndexPath class]) {
        return indexPath;
    }
    return [NSIndexPath indexPathForItem:[indexPath item] inSection:[indexPath section]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AFCollectionViewCell    *cell = (AFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                                      forIndexPath:indexPath];

    return cell;
}

- (NSFetchRequest*)fetchRequestForContent {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProtectedImage" inManagedObjectContext:[[self coreDataController] managedObjectContext]];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    return fetchRequest;
}

#pragma mark - Sizing

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = MIN(self.view.bounds.size.width, self.view.bounds.size.height)/3.0;
    return CGSizeMake(size, size);
}

@end
