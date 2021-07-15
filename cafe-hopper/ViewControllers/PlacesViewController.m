//
//  PlacesViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "PlacesViewController.h"
#import "User.h"
#import "CollectionCell.h"
#import "Collection.h"
#import <Parse/Parse.h>

@interface PlacesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSArray<Collection *> *collections;

@end

@implementation PlacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User currentUser];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self fetchCollections];

//    [[User getCurrentUserInBackground] continueWithBlock:^id _Nullable(BFTask<__kindof PFUser *> * _Nonnull t) {
//        if (t.cancelled || t.error) {
//            NSLog(@"Task cancelled");
//            return nil;
//        }
//        if (t.error) {
//            NSLog(@"Error performing task / cancelled task");
//            return t.error;
//        }
//        NSLog(@"Got user successfully");
//        self.user = t.result;
//        NSLog(@"collections: %@", self.user.collections);
//        [self.collectionView reloadData];
//        return t.result;
//    }];
    
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
            self.collections = collections;
            [self.collectionView reloadData];
        } else {
            NSLog(@"Error fetching this user's colletions: %@", error.localizedDescription);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collections.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    cell.collection = self.collections[indexPath.item];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
