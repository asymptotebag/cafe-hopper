//
//  StopCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/20/21.
//

#import "StopCell.h"
#import "Trip.h"

@implementation StopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeSpentField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPlace:(GMSPlace *)place {
    _place = place;
    
    self.placeNameLabel.text = place.name;
    self.addressLabel.text = place.formattedAddress;
    [self.timeSpentButton setBackgroundImage:[UIImage systemImageNamed:@"clock"] forState:UIControlStateNormal];
    [self.timeSpentButton setTintColor:UIColor.systemGrayColor];
    self.timeSpentField.text = [NSString stringWithFormat:@"%ld", [self.minSpent integerValue]];
    self.stopIndexLabel.text = [NSString stringWithFormat:@"%li", self.index+1];
    self.indexBorder.layer.cornerRadius = self.indexBorder.layer.frame.size.height/2;
    if ((self.index + 1) % 2 == 0) {
        UIColor *evenColor = [UIColor colorNamed:@"CafeAuLait"];
        self.indexBorder.layer.backgroundColor = evenColor.CGColor;
        [self.indexLeftLine setBackgroundColor:evenColor];
        [self.indexRightLine setBackgroundColor:evenColor];
    } else {
        UIColor *oddColor = [UIColor colorNamed:@"Tan"];
        self.indexBorder.layer.backgroundColor = oddColor.CGColor;
        [self.indexLeftLine setBackgroundColor:oddColor];
        [self.indexRightLine setBackgroundColor:oddColor];
    }
    
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"Text field began editing");
    [self.timeSpentButton setBackgroundImage:[UIImage systemImageNamed:@"checkmark.circle"] forState:UIControlStateNormal];
    [self.timeSpentButton setTintColor:UIColor.systemGreenColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Text field ended editing");
    [self.trip changeDurationOfStopAtIndex:self.index toDuration:[textField.text integerValue] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Successfully changed duration");
        } else {
            NSLog(@"Error changing duration: %@", error.localizedDescription);
        }
    }];
    [self.timeSpentButton setBackgroundImage:[UIImage systemImageNamed:@"clock"] forState:UIControlStateNormal];
    [self.timeSpentButton setTintColor:UIColor.systemGrayColor];
}

- (IBAction)onTapClock:(id)sender {
    if (self.timeSpentField.isEditing) { // only end editing if it's editing now
        [self.contentView endEditing:true];
    }
}

- (IBAction)onTapTravelMode:(id)sender {
    // TODO: show UIMenu with multiple travel options
}

@end
