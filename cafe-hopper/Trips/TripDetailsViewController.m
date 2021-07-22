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

@property (strong, nonatomic) NSMutableArray *stops;
// stops: [{place: GMSPlace, minSpent:20, timeToNext:14}]

@property (nonatomic) NSInteger stopsLoaded;

@end

@implementation TripDetailsViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    self.stopsLoaded = 0;
    self.stops = [NSMutableArray new];
    for (int i=0; i<self.trip.stops.count; i++) {
        [self.stops addObject:[NSNull null]];
    }
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
            if (place) {
                NSMutableDictionary *newStop = @{@"place":place, @"index":stop[@"index"], @"minSpent":stop[@"minSpent"]}.mutableCopy;
                if (stop[@"timeToNext"]) { // nil if key doesn't exist
                    newStop[@"timeToNext"] = stop[@"timeToNext"];
                }
//                [self.stops addObject:newStop];
                NSLog(@"Setting index %@", stop[@"index"]);
                [self.stops setObject:newStop atIndexedSubscript:[stop[@"index"] integerValue]];
                self.stopsLoaded++;
                if (self.stopsLoaded == self.trip.stops.count) {
                    NSLog(@"Loaded %li stops, now reloading table view", self.stopsLoaded);
                    [self.tableView reloadData];
                }
            } else {
                NSLog(@"Error fetching place: %@", error.localizedDescription);
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.stops.count;
    return self.stopsLoaded;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StopCell" forIndexPath:indexPath];
    NSMutableDictionary *stop = self.stops[indexPath.row];
    cell.trip = self.trip;
    cell.index = indexPath.row;
    cell.isLastStop = indexPath.row == self.trip.stops.count-1;
    cell.minSpent = (NSNumber *)stop[@"minSpent"];
    if (stop[@"timeToNext"]) {
        cell.timeToNext = stop[@"timeToNext"];
    } else {
        cell.timeToNext = nil;
    }
    cell.place = stop[@"place"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete item from trip locally and update Parse
        NSMutableDictionary *stop = self.stops[indexPath.row];
        [Trip removeStopAtIndex:[stop[@"index"] integerValue] fromTrip:self.trip withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Deleted stop successfully");
                [self fetchStops];
            } else {
                NSLog(@"Error deleting stop: %@", error.localizedDescription);
            }
        }];
    }
}

- (NSString *)URLEncodeString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    string = [string stringByReplacingOccurrencesOfString:@"%" withString:@"Percent"];
    return [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (IBAction)onTapNavigate:(id)sender {
    if (self.stops.count >= 2) {
        NSMutableString *URLString = @"https://www.google.com/maps/dir/?api=1".mutableCopy;
        
        GMSPlace *origin = self.stops[0][@"place"];
        NSString *originParameter = [@"&origin=" stringByAppendingString:[self URLEncodeString:origin.name]];
        NSString *originIdParameter = [@"&origin_place_id=" stringByAppendingString:origin.placeID];
        [URLString appendString:originParameter];
        [URLString appendString:originIdParameter];
        
        GMSPlace *destination = self.stops[self.stops.count-1][@"place"];
        NSString *destinationParameter = [@"&destination=" stringByAppendingString:[self URLEncodeString:destination.name]];
        NSString *destinationIdParameter = [@"&destination_place_id=" stringByAppendingString:destination.placeID];
        [URLString appendString:destinationParameter];
        [URLString appendString:destinationIdParameter];
        
        NSInteger numWaypoints = self.stops.count - 2;
        if (numWaypoints > 0) {
            NSMutableString *waypointsParameter = @"&waypoints=".mutableCopy;
            NSMutableString *waypointsIdsParameter = @"&waypoint_place_ids=".mutableCopy;
            for (int i=0; i<numWaypoints; i++) {
                // url encode waypoints (pipe character is %7C)
                GMSPlace *waypoint = self.stops[i+1][@"place"];
                [waypointsParameter appendString:[self URLEncodeString:waypoint.name]];
                [waypointsIdsParameter appendString:[self URLEncodeString:waypoint.placeID]];
                if (i < numWaypoints - 1) { // add pipe for all except last one
                    [waypointsParameter appendString:@"%7C"];
                    [waypointsIdsParameter appendString:@"%7C"];
                }
            }
            [URLString appendString:waypointsParameter];
            [URLString appendString:waypointsIdsParameter];
        }
        
        NSLog(@"URL to open: %@", URLString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Navigation unavailable" message:@"A trip must have at least 2 stops to enable navigation." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:^{}];
    }
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
