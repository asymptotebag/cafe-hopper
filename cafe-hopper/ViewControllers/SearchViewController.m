//
//  SearchViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/13/21.
//

#import "SearchViewController.h"
#import "SearchResultCell.h"
#import "MapViewController.h"
#import "MainTabBarController.h"
@import GooglePlaces;

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation SearchViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    self.searchResults = [NSMutableArray new];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)filterSearchResults:(NSArray<GMSAutocompletePrediction *> *)results {
    for (GMSAutocompletePrediction *result in results) {
        if ([result.types containsObject:@"cafe"] || [result.types containsObject:@"bakery"] || [result.types containsObject:@"bar"]) {
            [self.searchResults addObject:result];
        }
    }
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) { // idk i want to prevent making too many requests
        GMSAutocompleteSessionToken *token = [[GMSAutocompleteSessionToken alloc] init];
        // create type filter
        GMSAutocompleteFilter *_filter = [[GMSAutocompleteFilter alloc] init];
        _filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
        
        self.searchResults = [NSMutableArray new];
        
        [_placesClient findAutocompletePredictionsFromQuery:searchText filter:_filter sessionToken:token callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error in getting autocomplete predictions: %@", error.localizedDescription);
            } else if (results) {
                [self filterSearchResults:results];
            }
        }];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    GMSAutocompletePrediction *result = self.searchResults[indexPath.row];
    cell.result = result;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarController *tabBar = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    GMSAutocompletePrediction *result = self.searchResults[indexPath.row];
    NSString *placeId = result.placeID;
    tabBar.placeId = placeId;
    [self presentViewController:tabBar animated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    NSString *segId = [segue identifier];
}

@end
