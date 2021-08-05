//
//  MapViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "MapViewController.h"
#import "MainTabBarController.h"
#import "DetailsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <CoreLocation/CoreLocation.h>
@import GooglePlaces;

@interface MapViewController () <UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate>
// public: @property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (strong, nonatomic) GMSPlace *currentPlace;

@end

@implementation MapViewController {
    GMSPlacesClient *_placesClient;
    GMSMarker *infoMarker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.searchResults = [NSMutableArray new];
    self.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    MainTabBarController *tabBar = (MainTabBarController *)self.tabBarController;
    self.placeId = tabBar.placeId;
    
    if (self.placeId) {
        [self showPlaceFromId:self.placeId];
    } else { // show user's location on first load
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.64542 longitude:-74.0851 zoom:15];
        self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
        self.mapView.hidden = YES;
        [self.view insertSubview:self.mapView atIndex:0];
        if ([self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            NSLog(@"Location services authorized.");
            [self displayUserLocation];
        } else {
            NSLog(@"Location services not authorized.");
            self.mapView.hidden = NO;
        }
    }
}

- (void)showPlaceFromId:(NSString *)placeID {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    GMSPlaceField fields = (GMSPlaceFieldPlaceID | GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldCoordinate | GMSPlaceFieldRating | GMSPlaceFieldPriceLevel | GMSPlaceFieldPhoneNumber | GMSPlaceFieldWebsite | GMSPlaceFieldPhotos);
    
    __weak typeof(self) weakSelf = self;
    [_placesClient fetchPlaceFromPlaceID:placeID placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (error) {
            NSLog(@"Error fetching place from ID: %@", error.localizedDescription);
        } else if (place) {
            NSLog(@"Displaying %@", place.name);
            self.currentPlace = place;
            [self showLocationAtPlace:place];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if ([self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Location services authorized.");
        [self displayUserLocation];
    }
}

- (void)displayUserLocation {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [self.locationManager startUpdatingLocation];
    CLLocationDegrees lat = self.locationManager.location.coordinate.latitude;
    CLLocationDegrees lon = self.locationManager.location.coordinate.longitude;
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"latitude: %f", lat);
    NSLog(@"longitude: %f", lon);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lon zoom:15.f];
    [self.mapView setCamera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.hidden = NO;
    
    // Create a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lon);
    marker.title = @"You are here";
    marker.snippet = @"Welcome!";
    marker.map = self.mapView;
    [MBProgressHUD hideHUDForView:self.view animated:true];
}

- (void)showLocationAtPlace:(GMSPlace *)place {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:15];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView.myLocationEnabled = YES;
    [self.view insertSubview:mapView atIndex:0];
    mapView.delegate = self;
    [MBProgressHUD hideHUDForView:self.view animated:true];
    
    // Create a marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    marker.title = place.name;
    marker.map = mapView;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    // TODO: this should also open up details view
}

- (void)showSampleMap { // currently unused
    // Sample code to create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.64542 longitude:-74.0851 zoom:15];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];

    [self.view insertSubview:mapView atIndex:0];
    
    // Create a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.64542, -74.0851);
    marker.title = @"Brooklyn";
    marker.snippet = @"New York City";
    marker.map = mapView;
}

- (void)mapView:(GMSMapView *)mapView didTapPOIWithPlaceID:(NSString *)placeID name:(NSString *)name location:(CLLocationCoordinate2D)location {
    NSLog(@"You tapped %@: %@, %f/%f", name, placeID, location.latitude, location.longitude);
    infoMarker = [GMSMarker markerWithPosition:location];
    infoMarker.title = name;
//    infoMarker.snippet = placeID;
    infoMarker.opacity = 0;
    CGPoint pos = infoMarker.infoWindowAnchor;
    pos.y = 1;
    infoMarker.infoWindowAnchor = pos;
    infoMarker.map = mapView;
    mapView.selectedMarker = infoMarker;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // segue into search (results) vc
    [self performSegueWithIdentifier:@"mapSearchSegue" sender:nil];
    [self.searchBar endEditing:true];
    [self.searchBar resignFirstResponder];
}

- (IBAction)onTapDetailsButton:(id)sender {
    if (self.currentPlace) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailsViewController *detailsVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
        detailsVC.place = self.currentPlace;
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

@end
