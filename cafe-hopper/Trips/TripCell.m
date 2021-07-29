//
//  TripCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import "TripCell.h"
@import GooglePlaces;

@implementation TripCell {
    GMSPlacesClient *_placesClient;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _placesClient = [GMSPlacesClient sharedClient];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.layer removeAllAnimations];
    [self.layer removeFromSuperlayer];
}

- (NSString *)timestampFromMinutes:(NSInteger)minutes {
    NSInteger hours = minutes/60;
    if (hours == 0) {
        return [[NSString stringWithFormat:@"%li", minutes] stringByAppendingString:@" min"];
    }
    NSInteger minutesLeft = minutes - hours * 60;
    return [[[NSString stringWithFormat:@"%li", hours] stringByAppendingString:@"h "] stringByAppendingString:[[NSString stringWithFormat:@"%li", minutesLeft] stringByAppendingString:@"m"]];
}

- (void)setTrip:(Trip *)trip { // custom setter
    _trip = trip;
    
    UIImageSymbolConfiguration *defaultConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleLarge];
    if ([trip.isActive boolValue]) {
        NSLog(@"setting image to stopwatch");
        [self.activeIndicator setImage:[UIImage systemImageNamed:@"stopwatch.fill" withConfiguration:defaultConfig]];
    } else {
        NSLog(@"setting image to map pin");
        [self.activeIndicator setImage:[UIImage systemImageNamed:@"mappin.circle.fill" withConfiguration:defaultConfig]];
    }
    self.tripNameLabel.text = trip.tripName;
    
    NSString *numStops = [NSString stringWithFormat:@"%lu", trip.stops.count];
    // handle 1 stop separately
    if (trip.stops.count == 1) {
        self.stopsLabel.text = [numStops stringByAppendingString:@" stop"];
    } else {
        self.stopsLabel.text = [numStops stringByAppendingString:@" stops"];
    }
    // calculate duration of trip
    NSInteger duration = 0;
    for (NSMutableDictionary *stop in trip.stops) {
        duration += [stop[@"minSpent"] integerValue];
        if (stop[@"timeToNext"]) {
            duration += [stop[@"timeToNext"] integerValue];
        }
    }
    self.durationLabel.text = [self timestampFromMinutes:duration];
    
    // TODO: bring back images when you're ready
    /*
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldPhotos);
    __weak typeof(self) weakSelf = self;
    [_placesClient fetchPlaceFromPlaceID:trip.stops[0][@"placeId"] placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (place) {
            self.originNameLabel.text = place.name;
            GMSPlacePhotoMetadata *metadata = place.photos[0];
            [self->_placesClient loadPlacePhoto:metadata constrainedToSize:CGSizeMake(50, 50) scale:1.f callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                if (photo) {
                    [self.originImageView setImage:photo];
                } else {
                    NSLog(@"Error loading photo: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error getting origin details: %@", error.localizedDescription);
        }
    }];
    [_placesClient fetchPlaceFromPlaceID:trip.stops[trip.stops.count-1][@"placeId"] placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (place) {
            self.destinationNameLabel.text = place.name;
            GMSPlacePhotoMetadata *metadata = place.photos[0];
            [self->_placesClient loadPlacePhoto:metadata constrainedToSize:CGSizeMake(50, 50) scale:1.f callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                if (photo) {
                    [self.destinationImageView setImage:photo];
                } else {
                    NSLog(@"Error loading photo: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error getting destination name: %@", error.localizedDescription);
        }
    }];
     */
    
//    [self drawDottedLine];
    
    self.originImageView.layer.cornerRadius = self.originImageView.frame.size.height/2;
    self.originImageView.clipsToBounds = true;
    self.destinationImageView.layer.cornerRadius = self.destinationImageView.frame.size.height/2;
    self.destinationImageView.clipsToBounds = true;
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColor.systemGray6Color;
    self.selectedBackgroundView = bgView;
}

- (void)drawDottedLine { // draw dotted line between origin and destination
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor grayColor] CGColor]];
    [shapeLayer setLineWidth:1.5f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:@[@1.5, @4]]; // figure out what this does
    
    NSLog(@"self.bounds.origin: (%f, %f)", self.bounds.origin.x, self.bounds.origin.y);
    NSLog(@"self.bounds.size: %f x %f", self.bounds.size.width, self.bounds.size.height);
    
    NSLog(@"self.originNameLabel.frame.origin: (%f, %f)", self.originNameLabel.frame.origin.x, self.originNameLabel.frame.origin.y);
    NSLog(@"self.originNameLabel.frame.size: %f x %f", self.originNameLabel.frame.size.width, self.originNameLabel.frame.size.height);
    
    // TODO: WHY DO I NEED TO MANUALLY SHIFT THE COORDINATES BY SO MUCH
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat originX = self.originNameLabel.frame.origin.x + self.originNameLabel.frame.size.width + 215.f;
    CGFloat originY = self.originNameLabel.frame.origin.y + self.originNameLabel.frame.size.height/2 + 60.f;
    NSLog(@"(originX, originY) = (%f, %f)", originX, originY);
    CGPathMoveToPoint(path, NULL, originX, originY);
    
    CGFloat destinationX = self.destinationImageView.frame.origin.x + 200.f;
    CGFloat destinationY = originY;
    NSLog(@"(destinationX, destinationY) = (%f, %f)", destinationX, destinationY);
    CGPathAddLineToPoint(path, NULL, destinationX, destinationY);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [self.layer addSublayer:shapeLayer];
}

@end
