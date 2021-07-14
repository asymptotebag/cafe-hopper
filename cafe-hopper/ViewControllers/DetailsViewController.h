//
//  DetailsViewController.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import <UIKit/UIKit.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (strong, nonatomic) GMSPlace *place;
@end

NS_ASSUME_NONNULL_END
