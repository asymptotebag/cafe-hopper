//
//  PlaceCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import "PlaceCell.h"
#import <HCSStarRatingView/HCSStarRatingView.h>
@import GooglePlaces;

@implementation PlaceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPlace:(GMSPlace *)place {
    _place = place;
    self.nameLabel.text = place.name;
    self.addressLabel.text = place.formattedAddress;
    NSInteger priceLevel = place.priceLevel;
    NSMutableString *priceString = @"".mutableCopy;
    for(int i=0; i<priceLevel; i++) {
        [priceString appendString:@"$"];
    }
    self.priceLevelLabel.text = priceString;

    [self showStarRating];
    
    self.pictureView.layer.cornerRadius = self.pictureView.frame.size.height/2;
    self.pictureView.clipsToBounds = true;
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColor.systemGray6Color;
    self.selectedBackgroundView = bgView;
}

- (void)showStarRating {
    HCSStarRatingView *starRatingView = [HCSStarRatingView new];
    starRatingView.maximumValue = 5;
    starRatingView.minimumValue = 0;
    starRatingView.tintColor = [UIColor colorNamed:@"MaizeCrayola"];
    starRatingView.allowsHalfStars = YES;
    starRatingView.accurateHalfStars = YES;
    starRatingView.value = self.place.rating;
    [starRatingView setUserInteractionEnabled:NO];
    [starRatingView setBackgroundColor:[UIColor clearColor]];
    starRatingView.emptyStarImage = [[UIImage imageNamed:@"heart-empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    starRatingView.filledStarImage = [[UIImage imageNamed:@"heart-full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentView addSubview:starRatingView];
    
    // autolayout star rating view
    starRatingView.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeTop
                            relatedBy:NSLayoutRelationEqual
                            toItem:self.addressLabel
                            attribute:NSLayoutAttributeBottom
                            multiplier:1.f constant:8.f] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeLeading
                            relatedBy:NSLayoutRelationEqual
                            toItem:self.addressLabel
                            attribute:NSLayoutAttributeLeading
                            multiplier:1.f constant:0.f] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationEqual
                            toItem:self.contentView
                            attribute:NSLayoutAttributeWidth
                            multiplier:0.25f constant:0.f] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeHeight
                            relatedBy:NSLayoutRelationEqual toItem:nil
                            attribute:NSLayoutAttributeHeight
                            multiplier:1.f constant:20.f] setActive:YES];
}

@end
