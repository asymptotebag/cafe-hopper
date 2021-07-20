//
//  StopCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/20/21.
//

#import "StopCell.h"

@implementation StopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlace:(GMSPlace *)place {
    _place = place;
    
    self.placeNameLabel.text = place.name;
    self.addressLabel.text = place.formattedAddress;
    self.timeSpentField.text = [NSString stringWithFormat:@"%li", self.minSpent];
    self.stopIndexLabel.text = [NSString stringWithFormat:@"%li", self.index+1];
    
    self.indexBorder.layer.cornerRadius = self.indexBorder.layer.frame.size.height/2;
//    self.indexBorder.layer.borderColor = UIColor.lightGrayColor.CGColor;
//    self.indexBorder.layer.borderWidth = 1.f;
//    self.indexBorder.layer.backgroundColor = UIColor.clearColor.CGColor;
}

@end
