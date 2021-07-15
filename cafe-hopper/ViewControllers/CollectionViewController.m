//
//  CollectionViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import "CollectionViewController.h"
#import "PlaceCell.h"
@import GooglePlaces;

@interface CollectionViewController () <UITableViewDataSource, UITableViewDelegate>
// public: @property (strong, nonatomic) Collection *collection;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<GMSPlace *> *places;

@end

@implementation CollectionViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    [self setupTableView];
    self.places = [NSMutableArray new];
    [self fetchPlacesinCollection];
    self.navigationItem.title = self.collection.collectionName;
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)fetchPlacesinCollection { // query
    GMSPlaceField fields = (GMSPlaceFieldPlaceID | GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldRating | GMSPlaceFieldPriceLevel);
    
    for (NSString *placeId in self.collection.places) {
        [_placesClient fetchPlaceFromPlaceID:placeId placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            [self.places addObject:place];
            [self.tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    cell.place = self.places[indexPath.row];
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
