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
#import "User.h"
@import GooglePlaces;

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic) BOOL isShowingHistory;

@end

@implementation SearchViewController {
    GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _placesClient = [GMSPlacesClient sharedClient];
    self.searchBar.delegate = self;
    // want to start out showing search history
    self.isShowingHistory = YES;
    [self.searchBar becomeFirstResponder];
    self.searchResults = [NSMutableArray new];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // populate with recent searches
    self.searchResults = User.currentUser.searchHistory;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    self.isShowingHistory = YES;
    self.searchResults = User.currentUser.searchHistory;
    [self.tableView reloadData];
}

- (void)filterSearchResults:(NSArray<GMSAutocompletePrediction *> *)results {
    for (GMSAutocompletePrediction *result in results) {
        if ([result.types containsObject:@"cafe"] || [result.types containsObject:@"bakery"] || [result.types containsObject:@"bar"]) {
            if (![self.searchResults containsObject:result]) {
                [self.searchResults addObject:result]; // don't add duplicates
            }
        }
    }
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.isShowingHistory = NO;
    if (searchText.length > 0) { // idk i want to prevent making too many requests
        GMSAutocompleteSessionToken *token = [[GMSAutocompleteSessionToken alloc] init];
        // create type filter
        GMSAutocompleteFilter *_filter = [[GMSAutocompleteFilter alloc] init];
        _filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
        
        self.searchResults = [NSMutableArray new];
        
        __weak typeof(self) weakSelf = self;
        [_placesClient findAutocompletePredictionsFromQuery:searchText filter:_filter sessionToken:token callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
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
    // clear out recent/current searches if the search bar is empty
    if (self.searchBar.text.length == 0) {
        NSLog(@"search bar text began edting w/ empty text");
        self.searchResults = @[].mutableCopy;
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    self.isShowingHistory = YES;
    self.searchResults = User.currentUser.searchHistory;
    [self.tableView reloadData];
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
    if (self.isShowingHistory) {
        NSDictionary *recentResult = self.searchResults[indexPath.row];
        cell.recentResult = recentResult;
    } else {
        GMSAutocompletePrediction *result = self.searchResults[indexPath.row];
        cell.result = result;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarController *tabBar = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];

    if (self.isShowingHistory) {
        NSDictionary *recentResult = self.searchResults[indexPath.row];
        NSString *placeId = recentResult[@"placeID"];
        tabBar.placeId = placeId;
    } else {
        GMSAutocompletePrediction *result = self.searchResults[indexPath.row];
        NSString *placeId = result.placeID;
        tabBar.placeId = placeId;
        // add result to history
        NSDictionary *searchResult = @{@"name":[result.attributedPrimaryText string], @"address":[result.attributedSecondaryText string], @"placeID":placeId};
        User *user = [User currentUser];
        [user.searchHistory insertObject:searchResult atIndex:0];
        // show max of 10 recent searches
        for (int i=5; i<user.searchHistory.count; i++) {
            [user.searchHistory removeObjectAtIndex:i];
        }
        user[@"searchHistory"] = user.searchHistory;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Added tapped result to search history.");
            } else {
                NSLog(@"Error adding tapped result to search history");
            }
        }];
    }
    [self presentViewController:tabBar animated:YES completion:nil];
}

@end
