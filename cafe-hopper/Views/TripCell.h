//
//  TripCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

NS_ASSUME_NONNULL_BEGIN

@interface TripCell : UITableViewCell
@property (strong, nonatomic) Trip *trip;

@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *originNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *originImageView;
@property (weak, nonatomic) IBOutlet UILabel *destinationNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *destinationImageView;
@property (weak, nonatomic) IBOutlet UILabel *stopsLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

NS_ASSUME_NONNULL_END
