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
@import GooglePlaces;

@interface MapViewController () <UISearchBarDelegate, GMSMapViewDelegate>
// public: @property (strong, nonatomic) NSString *placeId;
//@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
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
    self.searchResults = [NSMutableArray new];
    self.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    MainTabBarController *tabBar = self.tabBarController;
    self.placeId = tabBar.placeId;
    
    if (self.placeId) {
        [self showPlaceFromId:self.placeId];
    } else { // show user's location on first load
//        [self displayUserLocation];
        [self showSampleMap];
    }
}

- (void)showPlaceFromId:(NSString *)placeID {
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    GMSPlaceField fields = (GMSPlaceFieldPlaceID | GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldCoordinate | GMSPlaceFieldRating | GMSPlaceFieldPriceLevel | GMSPlaceFieldPhoneNumber | GMSPlaceFieldWebsite);
//    GMSPlaceField fields = (GMSPlaceFieldPhotos | GMSPlaceFieldPriceLevel);
    [_placesClient fetchPlaceFromPlaceID:placeID placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching place from ID: %@", error.localizedDescription);
        } else if (place) {
            NSLog(@"Displaying %@", place.name);
            self.currentPlace = place;
            [self showLocationAtPlace:place];
        }
    }];
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
    }];
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
//    marker.snippet = @"hello hello";
    marker.map = mapView;
}

//- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
//
//}

- (void)showSampleMap {
    // Sample code to create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.64542 longitude:-74.0851 zoom:15];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapView.myLocationEnabled = YES;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"segue through here");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([[segue identifier] isEqualToString:@"detailsSegue"]) {
//        if (self.)
//    }
}

@end
