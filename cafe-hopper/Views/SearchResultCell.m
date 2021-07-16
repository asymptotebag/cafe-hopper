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

- (void)setResult:(GMSAutocompletePrediction *)result { // custom setter
    _result = result;
    
    UIFont *regFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    NSMutableAttributedString *bolded = [result.attributedPrimaryText mutableCopy];
    [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute inRange:NSMakeRange(0, bolded.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        UIFont *font = (value == nil) ? regFont : boldFont;
        [bolded addAttribute:NSFontAttributeName value:font range:range];
    }];

    self.placeNameLabel.attributedText = bolded;
    self.placeAddressLabel.attributedText = result.attributedSecondaryText;
}

@end
