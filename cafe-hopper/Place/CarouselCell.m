//
//  CarouselCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import "CarouselCell.h"

@implementation CarouselCell

- (void)setPhoto:(UIImage *)photo {
    self.pictureView.alpha = 0;
    [self.pictureView setImage:photo];
    [UIView animateWithDuration:0.3 animations:^{
        self.pictureView.alpha = 1;
    }];
}

- (void)setPlace:(GMSPlace *)place { // temporary setter function
    NSInteger randint = arc4random_uniform(6) + 1;
    NSString *imgName = [NSString stringWithFormat:@"%li", randint];
    [self.pictureView setImage:[UIImage imageNamed:imgName]];
}

@end
