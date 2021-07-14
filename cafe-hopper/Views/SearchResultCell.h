//
//  SearchResultCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/13/21.
//

#import <UIKit/UIKit.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultCell : UITableViewCell
@property (strong, nonatomic) GMSAutocompletePrediction *result;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;

@end

NS_ASSUME_NONNULL_END
