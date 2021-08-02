//
//  CollectionCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "CollectionCell.h"
#import "Collection.h"
@import GooglePlaces;
#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0

@implementation CollectionCell {
    GMSPlacesClient *_placesClient;
    BOOL usingRealImages;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _placesClient = [GMSPlacesClient sharedClient];
    usingRealImages = NO;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setCollection:(Collection *)collection {
    _collection = collection;
    
    self.nameLabel.text = collection.collectionName;
    self.frameView.layer.cornerRadius = 15;
    self.frameView.clipsToBounds = YES;
    
    // images are 84 x 84
    GMSPlaceField fields = (GMSPlaceFieldPhotos);
    
    NSArray *grid = @[self.topLeftView, self.topRightView, self.bottomLeftView, self.bottomRightView];
    
    for (int i=0; i<4; i++) {
        if (collection.places.count > i) {
            [_placesClient fetchPlaceFromPlaceID:collection.places[i] placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Couldn't fetch place photos from ID: %@", error.localizedDescription);
                    // set to random placeholder
                    NSInteger randint = arc4random_uniform(6) + 1;
                    NSString *imgName = [NSString stringWithFormat:@"%li", randint];
                    [grid[i] setImage:[UIImage imageNamed:imgName]];
                } else if (place) {
                    GMSPlacePhotoMetadata *metadata = place.photos[0];
                    [self->_placesClient loadPlacePhoto:metadata constrainedToSize:CGSizeMake(200,200) scale:1.f callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                        if (photo) {
                            [grid[i] setImage:photo];
                        } else {
                            NSLog(@"Error loading photo: %@", error.localizedDescription);
                            // set to placeholder
                            [grid[i] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", i]]];
                        }
                    }];
                }
            }];
        } else { // not enough places in collection yet
            [grid[i] setImage:nil];
            [grid[i] setBackgroundColor:UIColor.systemGray6Color];
        }
         
    }

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
