//
//  TripsListViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import "TripsListViewController.h"
#import "TripDetailsViewController.h"
#import "Trip.h"
#import "User.h"
#import "TripCell.h"
#import <Parse/Parse.h>
@import GooglePlaces;

@interface TripsListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray<Trip *> *trips;

@end

@implementation TripsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User currentUser];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.trips = [NSMutableArray new];
    [self fetchTrips];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTrips) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchTrips {
    PFQuery *query = [Trip query];
    [query whereKey:@"owner" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable trips, NSError * _Nullable error) {
        if (trips) {
            self.trips = trips.mutableCopy;
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error fetching this user's trips: %@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TripCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCell" forIndexPath:indexPath];
    cell.trip = self.trips[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete item from trip locally and update Parse
        Trip *trip = self.trips[indexPath.row];
        [self.trips removeObject:trip];
        [Trip deleteTrip:trip withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Deleted trip successfully");
                [self.tableView reloadData];
            } else {
                NSLog(@"Error deleting trip: %@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"tripDetailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Trip *trip = self.trips[indexPath.row];
        TripDetailsViewController *detailsVC = [segue destinationViewController];
        detailsVC.trip = trip;
    }
}

@end
