//
//  TripDetailsViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import "TripDetailsViewController.h"
#import "StopCell.h"
@import GooglePlaces;

@interface TripDetailsViewController () <UITableViewDataSource, UITableViewDelegate>
// public: @property (strong, nonatomic) Trip *trip;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numStopsLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) NSMutableArray<NSMutableDictionary *> *stops;
// stops: [{place: GMSPlace, minSpent:20}]

@end

@implementation TripDetailsViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    self.stops = [NSMutableArray new];
    [self setupView];
    [self fetchStops];
}

- (void)setupView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tripNameLabel.text = self.trip.tripName;
    self.numStopsLabel.text = [[NSString stringWithFormat:@"%lu", self.trip.stops.count] stringByAppendingString:@" stops"];
    
    self.imageView1.layer.cornerRadius = self.imageView1.layer.frame.size.height/2;
    self.imageView2.layer.cornerRadius = self.imageView2.layer.frame.size.height/2;
    self.imageView3.layer.cornerRadius = self.imageView3.layer.frame.size.height/2;
    self.imageView1.clipsToBounds = YES;
    self.imageView2.clipsToBounds = YES;
    self.imageView3.clipsToBounds = YES;
}

- (void)fetchStops {
    GMSPlaceField fields = (GMSPlaceFieldPlaceID | GMSPlaceFieldName | GMSPlaceFieldFormattedAddress);
    for (NSMutableDictionary *stop in self.trip.stops) {
        [_placesClient fetchPlaceFromPlaceID:stop[@"placeId"] placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            NSMutableDictionary *newStop = @{@"place":place, @"minSpent":stop[@"minSpent"]}.mutableCopy;
            [self.stops addObject:newStop];
            [self.tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StopCell" forIndexPath:indexPath];
    NSMutableDictionary *stop = self.stops[indexPath.row];
    cell.index = indexPath.row;
    cell.minSpent = (NSInteger)stop[@"minSpent"];
    cell.place = stop[@"place"];
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
