//
//  CollectionCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "CollectionCell.h"
#import "Collection.h"
#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0

@implementation CollectionCell

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setCollection:(Collection *)collection {
    _collection = collection;
    
    self.nameLabel.text = collection.collectionName;
    self.frameView.layer.cornerRadius = 15;
    self.frameView.clipsToBounds = YES;
    [self.topLeftView setImage:[UIImage imageNamed:@"1"]];
    [self.topRightView setImage:[UIImage imageNamed:@"2"]];
    [self.bottomLeftView setImage:[UIImage imageNamed:@"3"]];
    [self.bottomRightView setImage:[UIImage imageNamed:@"4"]];
    
    if (self.inEditingMode && ![self.collection.collectionName isEqualToString:@"All"]) {
        // you can't delete the All collection
        self.deleteButton.hidden = NO;
        [self startJiggling];
    } else {
        self.deleteButton.hidden = YES; // hide X when not editing
        [self stopJiggling];
    }
}

- (IBAction)tapDelete:(id)sender {
    [self.delegate didTapDelete:self]; // handle deletion in delegate method
}

// Jiggle animation code is from https://stackoverflow.com/a/7284435

- (void)startJiggling {
    NSInteger randomInt = arc4random_uniform(500);
    float r = (randomInt/500.0)+0.5;

    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( (kAnimationRotateDeg * -1.0) - r ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg + r ));

     self.transform = leftWobble;  // starting point

     [[self layer] setAnchorPoint:CGPointMake(0.5, 0.5)];

     [UIView animateWithDuration:0.15
                delay:0
                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                animations:^{self.transform = rightWobble;}
                completion:nil];
}
- (void)stopJiggling {
    [self.layer removeAllAnimations];
    self.transform = CGAffineTransformIdentity;
}


@end
