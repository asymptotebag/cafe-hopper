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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPlace:(GMSPlace *)place {
    _place = place;
    
    self.placeNameLabel.text = place.name;
    self.addressLabel.text = place.formattedAddress;
    self.timeSpentField.text = [NSString stringWithFormat:@"%ld", [self.minSpent integerValue]];
    self.stopIndexLabel.text = [NSString stringWithFormat:@"%li", self.index+1];
//    self.stopIndexLabel.textColor = UIColor.labelColor;
    self.indexBorder.layer.cornerRadius = self.indexBorder.layer.frame.size.height/2;
//    self.indexBorder.layer.borderColor = UIColor.lightGrayColor.CGColor;
//    self.indexBorder.layer.borderWidth = 1.f;
//    self.indexBorder.layer.backgroundColor = UIColor.clearColor.CGColor;
    
    if (!self.isLastStop && self.timeToNext) { // add distance to next stop
        self.betweenStopsView.hidden = NO;
        self.travelTimeLabel.text = [[NSString stringWithFormat:@"%@", self.timeToNext] stringByAppendingString:@" min"];
        self.dot1.layer.cornerRadius = self.dot1.frame.size.height/2;
        self.dot1.clipsToBounds = true;
        self.dot2.layer.cornerRadius = self.dot2.frame.size.height/2;
        self.dot2.clipsToBounds = true;
        self.dot3.layer.cornerRadius = self.dot3.frame.size.height/2;
        self.dot3.clipsToBounds = true;
        self.dot4.layer.cornerRadius = self.dot4.frame.size.height/2;
        self.dot4.clipsToBounds = true;
    } else {
        self.betweenStopsView.hidden = YES;
    }
}

@end
