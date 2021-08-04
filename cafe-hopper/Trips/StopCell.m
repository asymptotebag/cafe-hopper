//
//  StopCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/20/21.
//

#import "StopCell.h"
#import "Trip.h"

@implementation StopCell {
    NSDictionary<NSString*, UIImage*> *_travelModeIcons;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeSpentField.delegate = self;
    _travelModeIcons = @{@"driving":[UIImage systemImageNamed:@"car"], @"walking":[UIImage systemImageNamed:@"figure.walk"], @"bicycling":[UIImage systemImageNamed:@"bicycle"]};
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
        
        [self.travelModeButton setImage:_travelModeIcons[self.travelMode] forState:UIControlStateNormal];
        self.travelModeButton.showsMenuAsPrimaryAction = YES;
        [self setupTravelModePicker];
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

- (void)setupTravelModePicker {
    // show UIMenu with multiple travel options
    UIAction *driving = [UIAction actionWithTitle:@"Driving" image:[UIImage systemImageNamed:@"car"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) { // set mode to driving
        self.travelMode = @"driving";
        [self.travelModeButton setImage:self->_travelModeIcons[self.travelMode] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [self.trip changeTravelModeOfStopAtIndex:self.index toMode:@"driving" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully changed travel mode to driving");
                strongSelf.timeToNext = self.trip.stops[self.index][@"timeToNext"];
                strongSelf.travelTimeLabel.text = [[NSString stringWithFormat:@"%@", strongSelf.timeToNext] stringByAppendingString:@" min"];
            } else {
                NSLog(@"Error changing travel mode: %@", error.localizedDescription);
            }
        }];
    }];
    UIAction *walking = [UIAction actionWithTitle:@"Walking" image:[UIImage systemImageNamed:@"figure.walk"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) { // set mode to walking
        self.travelMode = @"walking";
        [self.travelModeButton setImage:self->_travelModeIcons[self.travelMode] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [self.trip changeTravelModeOfStopAtIndex:self.index toMode:@"walking" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully changed travel mode to walking");
                strongSelf.timeToNext = self.trip.stops[self.index][@"timeToNext"];
                strongSelf.travelTimeLabel.text = [[NSString stringWithFormat:@"%@", strongSelf.timeToNext] stringByAppendingString:@" min"];
            } else {
                NSLog(@"Error changing travel mode: %@", error.localizedDescription);
            }
        }];
    }];
    UIAction *biking = [UIAction actionWithTitle:@"Biking" image:[UIImage systemImageNamed:@"bicycle"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) { // set mode to bicycling
        self.travelMode = @"bicycling";
        [self.travelModeButton setImage:self->_travelModeIcons[self.travelMode] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [self.trip changeTravelModeOfStopAtIndex:self.index toMode:@"bicycling" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully changed travel mode to biking");
                strongSelf.timeToNext = self.trip.stops[self.index][@"timeToNext"];
                strongSelf.travelTimeLabel.text = [[NSString stringWithFormat:@"%@", strongSelf.timeToNext] stringByAppendingString:@" min"];
            } else {
                NSLog(@"Error changing travel mode: %@", error.localizedDescription);
            }
        }];
    }];
    self.travelModePicker = [UIMenu menuWithTitle:@"Change travel mode:" children:@[driving, walking, biking]];
    [self.travelModeButton setMenu:self.travelModePicker];
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

@end
