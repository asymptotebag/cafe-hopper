//
//  SearchResultCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/13/21.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setCell:(GMSAutocompletePrediction *)result { // custom setter for reuse
//    _result = result;
//    NSLog(@"setting cell");
//    self.placeNameLabel.attributedText = result.attributedPrimaryText;
//    self.placeAddressLabel.attributedText = result.attributedSecondaryText;
//}

@end