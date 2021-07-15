//
//  PlaceCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import <UIKit/UIKit.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface PlaceCell : UITableViewCell
@property (strong, nonatomic) GMSPlace *place;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

NS_ASSUME_NONNULL_END
