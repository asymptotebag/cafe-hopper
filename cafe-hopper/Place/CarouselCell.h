//
//  CarouselCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import <UIKit/UIKit.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface CarouselCell : UICollectionViewCell
@property (strong, nonatomic) GMSPlacePhotoMetadata *photo;
@property (strong, nonatomic) GMSPlace *place; // temporary
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

@end

NS_ASSUME_NONNULL_END
