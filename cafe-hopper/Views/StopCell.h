//
//  StopCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/20/21.
//

#import <UIKit/UIKit.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface StopCell : UITableViewCell
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) NSNumber *minSpent;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL isLastStop;

@property (weak, nonatomic) IBOutlet UIView *indexBorder;
@property (weak, nonatomic) IBOutlet UILabel *stopIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *timeSpentField;

@property (weak, nonatomic) IBOutlet UIView *betweenStopsView; // hide this for last stop
@property (weak, nonatomic) IBOutlet UIButton *transportationButton;
@property (weak, nonatomic) IBOutlet UILabel *travelTimeLabel;

@end

NS_ASSUME_NONNULL_END
