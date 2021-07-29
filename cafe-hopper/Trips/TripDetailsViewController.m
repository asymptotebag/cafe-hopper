//
//  TripDetailsViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import "TripDetailsViewController.h"
#import "StopCell.h"
#import <NSString_UrlEncode/NSString+URLEncode.h>
#import <UserNotifications/UserNotifications.h>
#import "User.h"
@import GooglePlaces;

@interface TripDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate>
// public: @property (strong, nonatomic) Trip *trip;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numStopsLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonBackground;
@property (weak, nonatomic) IBOutlet UIButton *beginTripButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) NSMutableArray *stops;
// stops: [{place: GMSPlace, minSpent:20, timeToNext:14, index:0}]

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
    self.buttonBackground.layer.cornerRadius = 8;
    self.buttonBackground.clipsToBounds = YES;
    
    self.imageView1.layer.cornerRadius = self.imageView1.layer.frame.size.height/2;
    self.imageView2.layer.cornerRadius = self.imageView2.layer.frame.size.height/2;
    self.imageView3.layer.cornerRadius = self.imageView3.layer.frame.size.height/2;
    self.imageView1.clipsToBounds = YES;
    self.imageView2.clipsToBounds = YES;
    self.imageView3.clipsToBounds = YES;
    
    [self.beginTripButton setTitle:@"Begin Trip" forState:UIControlStateNormal];
    [self.beginTripButton setTitle:@"Cancel Trip" forState:UIControlStateSelected];
    [self.beginTripButton setImage:[[UIImage imageNamed:@"play.circle.fill"] imageWithRenderingMode:UIImageRenderingModeAutomatic] forState:UIControlStateNormal];
    [self.beginTripButton setImage:[[UIImage imageNamed:@"xmark.circle.fill"] imageWithRenderingMode:UIImageRenderingModeAutomatic] forState:UIControlStateSelected];
}

- (void)fetchStops {
    GMSPlaceField fields = (GMSPlaceFieldPlaceID | GMSPlaceFieldName | GMSPlaceFieldFormattedAddress);
    __weak typeof(self) weakSelf = self;
    for (NSMutableDictionary *stop in self.trip.stops) {
        [_placesClient fetchPlaceFromPlaceID:stop[@"placeId"] placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (place) {
                NSMutableDictionary *newStop = @{@"place":place, @"index":stop[@"index"], @"minSpent":stop[@"minSpent"]}.mutableCopy;
                if (stop[@"timeToNext"]) { // nil if key doesn't exist
                    newStop[@"timeToNext"] = stop[@"timeToNext"];
                }
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

- (IBAction)onTapNavigate:(id)sender {
    if (self.stops.count >= 2) {
        NSMutableString *URLString = @"https://www.google.com/maps/dir/?api=1".mutableCopy;
        
        GMSPlace *origin = self.stops[0][@"place"];
        NSString *originParameter = [@"&origin=" stringByAppendingString:[origin.name URLEncode]];
        NSString *originIdParameter = [@"&origin_place_id=" stringByAppendingString:origin.placeID];
        [URLString appendString:originParameter];
        [URLString appendString:originIdParameter];
        
        GMSPlace *destination = self.stops[self.stops.count-1][@"place"];
        NSString *destinationParameter = [@"&destination=" stringByAppendingString:[destination.name URLEncode]];
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
                [waypointsParameter appendString:[waypoint.name URLEncode]];
                [waypointsIdsParameter appendString:waypoint.placeID];
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

- (IBAction)onTapBeginTrip:(id)sender {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    if (self.beginTripButton.isSelected) { // already selected, end trip
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cancel Trip" message:@"Are you sure you want to cancel this trip? This will delete scheduled notifications for ALL active trips." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // unschedule all pending notification requests
            [self.beginTripButton setSelected:NO];
            [center removeAllPendingNotificationRequests];
            NSLog(@"Removed all scheduled notifications.");
        }];
        UIAlertAction *neverMind = [UIAlertAction actionWithTitle:@"Never Mind" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:cancel];
        [alert addAction:neverMind];
        [self presentViewController:alert animated:YES completion:^{}];
    } else if (User.currentUser.notifsOn) { // begin trip b/c notifs allowed
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Begin Trip" message:@"Are you sure you want to begin this trip? The app will schedule notifications to remind you when to leave for your next stop." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *beginAction = [UIAlertAction actionWithTitle:@"Begin" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // TODO: change button appearance
            [self.beginTripButton setSelected:YES];
            // create notifications
            double seconds = 0; // running count of seconds for scheduling notifications
            // start from 1 because it doesn't make sense to notify when to leave for the first stop
            for (int i=1; i<self.stops.count; i++) {
                NSMutableDictionary *stop = self.stops[i];
                seconds += [stop[@"minSpent"] doubleValue];
                GMSPlace *place = stop[@"place"];
                UNMutableNotificationContent *notif = [[UNMutableNotificationContent alloc] init];
                notif.title = [NSString localizedUserNotificationStringForKey:self.trip.tripName arguments:nil];
                notif.body = [NSString localizedUserNotificationStringForKey:[[@"Time to leave for " stringByAppendingString:place.name] stringByAppendingString:@"!"] arguments:nil];
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:seconds repeats:NO];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:place.name content:notif trigger:trigger];
                
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (error!=nil) {
                        NSLog(@"Error scheduling notification: %@", error.localizedDescription);
                    } else {
                        NSLog(@"Notification scheduled for %@!", place.name);
                    }
                }];
                if (stop[@"timeToNext"]) {
                    seconds += [stop[@"timeToNext"] doubleValue];
                }
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:beginAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:^{}];
    } else { // user tried to begin trip but notifs are off
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Begin Trip" message:@"Begin Trip schedules notifications to remind you when to leave for your next stop. You must have notifications enabled in the Account tab to use this feature." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:dismiss];
        [self presentViewController:alert animated:YES completion:^{}];
    }
}

- (void)scheduleTestNotification {
    UNMutableNotificationContent *notif = [[UNMutableNotificationContent alloc] init];
    notif.title = [NSString localizedUserNotificationStringForKey:@"Notification Title" arguments:nil];
    notif.body = [NSString localizedUserNotificationStringForKey:@"Notification Body" arguments:nil];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Test Notif" content:notif trigger:trigger];
    NSLog(@"notification set up");
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {}];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // handle notification when app is in the foreground
}

@end
