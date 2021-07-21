//
//  CarouselCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import "CarouselCell.h"

@implementation CarouselCell

- (void)setPhoto:(GMSPlacePhotoMetadata *)photo {
    // TODO: use this later once you start fetching Place photos
}

- (void)setPlace:(GMSPlace *)place { // temporary setter function
    NSInteger randint = arc4random_uniform(6) + 1;
    NSString *imgName = [NSString stringWithFormat:@"%li", randint];
    [self.pictureView setImage:[UIImage imageNamed:imgName]];
}

@end
