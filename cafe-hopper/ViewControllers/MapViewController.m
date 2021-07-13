//
//  MapViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MBProgressHUD/MBProgressHUD.h>
@import GooglePlaces;

@interface MapViewController () <UISearchBarDelegate, GMSAutocompleteResultsViewControllerDelegate>
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation MapViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    self.searchResults = [NSMutableArray new];
    self.searchBar.delegate = self;
    [self.searchBar endEditing:true];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    [self displayUserLocation];
//    [self sampleSearch];
}

- (void)displayUserLocation {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    GMSPlaceField placeFields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldCoordinate);
    
    __weak typeof(self) weakSelf = self;
    [_placesClient findPlaceLikelihoodsFromCurrentLocationWithPlaceFields:placeFields callback:^(NSArray<GMSPlaceLikelihood *> * _Nullable likelihoods, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (error) {
            NSLog(@"Error occurred: %@", error.localizedDescription);
            return;
        }
        GMSPlace *place = likelihoods.firstObject.place;
        if (place == nil) {
            NSLog(@"NO current place");
            return;
        }
        NSLog(@"Place: %@", place.name);
        NSLog(@"Address: %@", place.formattedAddress);
        [self showLocationAtPlace:place];
        [MBProgressHUD hideHUDForView:self.view animated:true];
    }];
}

- (void)showLocationAtPlace:(GMSPlace *)place {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:15];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView.myLocationEnabled = YES;
    [self.view insertSubview:mapView atIndex:0];
    
    // Create a marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    marker.title = @"You are here";
    marker.snippet = @"hello hello";
    marker.map = mapView;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // segue into search (results) vc
    [self performSegueWithIdentifier:@"mapSearchSegue" sender:nil];
}

- (void)sampleSearch {
//    UISearchController *searchController = [UISearchController ]
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;

    _searchController = [[UISearchController alloc]
                             initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;

    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 88.0, 250, 50)];

    [subView addSubview:_searchController.searchBar];
    [_searchController.searchBar sizeToFit];
    [self.view addSubview:subView];

    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    self.definesPresentationContext = YES;
}

- (void)resultsController:(nonnull GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)resultsController:(nonnull GMSAutocompleteResultsViewController *)resultsController didFailAutocompleteWithError:(nonnull NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // handle the error.
    NSLog(@"Error: %@", error.localizedDescription);
}

- (void)showSampleMap {
    // Sample code to create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView.myLocationEnabled = YES;
//    [self.view addSubview:mapView];
    [self.view insertSubview:mapView atIndex:0];
    
    // Create a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView;
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
