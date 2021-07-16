//
//  PlacesViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "PlacesViewController.h"
#import "CollectionViewController.h"
#import "User.h"
#import "CollectionCell.h"
#import "Collection.h"
#import <Parse/Parse.h>

@interface PlacesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CollectionCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray<Collection *> *collections;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL inEditingMode;

@end

@implementation PlacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User currentUser];
    
    self.collections = [NSMutableArray new];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.inEditingMode = NO;
    [self fetchCollections];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchCollections) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    CGFloat itemsPerLine = 2;
    CGFloat width = floorf((self.collectionView.frame.size.width - self.flowLayout.minimumInteritemSpacing*(itemsPerLine - 1))/itemsPerLine);
    CGFloat height = width + 21;
    self.flowLayout.itemSize = CGSizeMake(width, height);
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)fetchCollections {
    PFQuery *query = [Collection query];
    [query whereKey:@"owner" equalTo:self.user];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Collection *> * _Nullable collections, NSError * _Nullable error) {
        if (collections) {
            self.collections = collections.mutableCopy;
            [self.refreshControl endRefreshing];
            [self.collectionView reloadData];
        } else {
            NSLog(@"Error fetching this user's collections: %@", error.localizedDescription);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collections.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    cell.inEditingMode = self.inEditingMode;
    cell.delegate = self;
    cell.collection = self.collections[indexPath.item];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (IBAction)onTapCreate:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create New Collection" message:@"Enter a name for your new collection." preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Collection Name";
    }];
    
    UIAlertController *duplicateAlert = [UIAlertController alertControllerWithTitle:@"Cannot create collection" message:@"Collection names must be unique." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self presentViewController:alert animated:YES completion:^{}];
    }];
    [duplicateAlert addAction:dismissAction];
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *name = alert.textFields.firstObject;
        NSMutableArray *existingNames = [NSMutableArray new];
        for (Collection *collection in self.collections) {
            [existingNames addObject:collection.collectionName];
        }
        if ([existingNames containsObject:name.text]) {
            // can't create duplicate collection name, show alert again
            NSLog(@"User attempted to create duplicate collection.");
            [self presentViewController:duplicateAlert animated:YES completion:^{}];
        } else { // create new collection
            [Collection createCollectionWithName:name.text completion:^(BOOL succeeded, NSError * _Nullable error) {
                [User addCollectionNamed:name.text forUser:self.user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
                NSLog(@"Created new collection successfully.");
//                [self.collections addObject:<#(nonnull Collection *)#>]
                [self fetchCollections]; // should reload data
            }];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:createAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{}];
}

- (IBAction)tapEdit:(id)sender {
    if (self.inEditingMode) { // exit editing mode
        self.inEditingMode = NO;
        [self.editBarButton setImage:[UIImage systemImageNamed:@"square.and.pencil"]];
    } else { // enter editing mode
        self.inEditingMode = YES;
        [self.editBarButton setImage:[UIImage systemImageNamed:@"xmark.square"]];
    }
    [self.collectionView reloadData];
//    [self.collectionView layoutSubviews];
//    [self fetchCollections];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *selected = [self.collectionView cellForItemAtIndexPath:indexPath];
    Collection *selectedCollection = selected.collection;
    if (self.inEditingMode) {
        NSLog(@"selected cell is in editing mode");
    } else { // perform segue
        NSLog(@"segue to details");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CollectionViewController *collectionVC = [storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
        collectionVC.collection = selectedCollection;
        [self.navigationController pushViewController:collectionVC animated:YES];
    }
}

- (void)didTapDelete:(UICollectionViewCell *)cell {
    CollectionCell *selectedCell = (CollectionCell *)cell;
    Collection *selectedCollection = selectedCell.collection;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:selectedCell];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Collection" message:@"Are you sure you want to delete this collection?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [Collection deleteCollection:selectedCollection withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
        [self.collections removeObject:selectedCollection];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"viewCollectionSegue"] && !self.inEditingMode) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
        Collection *collection = self.collections[indexPath.item];
        CollectionViewController *collectionVC = [segue destinationViewController];
        collectionVC.collection = collection;
    } else {
        NSLog(@"segue not recognized");
    }
}

@end
