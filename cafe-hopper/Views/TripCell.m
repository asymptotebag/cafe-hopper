//
//  TripCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import "TripCell.h"

@implementation TripCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.layer removeAllAnimations];
    [self.layer removeFromSuperlayer];
}

- (void)setTrip:(Trip *)trip { // custom setter
    _trip = trip;
    self.tripNameLabel.text = trip.tripName;
    
    NSString *numStops = [NSString stringWithFormat:@"%lu", trip.stops.count];
    self.stopsLabel.text = [numStops stringByAppendingString:@" stops"];
    
    [self drawDottedLine];
    
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
