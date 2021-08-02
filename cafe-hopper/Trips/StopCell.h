//
//  StopCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/20/21.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface StopCell : UITableViewCell <UITextFieldDelegate>
@property (strong, nonatomic) Trip *trip;
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) NSNumber *minSpent;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL isLastStop;
@property (strong, nonatomic) NSNumber *_Nullable timeToNext;

@property (weak, nonatomic) IBOutlet UIView *indexBorder;
@property (weak, nonatomic) IBOutlet UIView *indexLeftLine;
@property (weak, nonatomic) IBOutlet UIView *indexRightLine;
@property (weak, nonatomic) IBOutlet UILabel *stopIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *timeSpentField;
@property (weak, nonatomic) IBOutlet UIButton *timeSpentButton;

@property (weak, nonatomic) IBOutlet UIView *betweenStopsView; // hide this for last stop
@property (weak, nonatomic) IBOutlet UIView *dot1;
@property (weak, nonatomic) IBOutlet UIView *dot2;
@property (weak, nonatomic) IBOutlet UIView *dot3;
@property (weak, nonatomic) IBOutlet UIView *dot4;
@property (weak, nonatomic) IBOutlet UIButton *transportationButton;
@property (weak, nonatomic) IBOutlet UILabel *travelTimeLabel;

@end

NS_ASSUME_NONNULL_END
