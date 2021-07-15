//
//  DetailsViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import <HCSStarRatingView/HCSStarRatingView.h>
#import <Parse/Parse.h>
#import "User.h"
#import "Collection.h"

@interface DetailsViewController ()
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) UIMenu *saveMenu;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User currentUser];
    [self setupView];
}

- (void)setupView {
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    [self.pictureView setImage:[UIImage imageNamed:@"3"]];
    self.pictureView.layer.cornerRadius = self.pictureView.frame.size.height/2;
    self.pictureView.clipsToBounds = true;
    
    [self showStarRating];
    [self setupMenu];
    
    PFQuery *query = [Collection query];
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"collectionName" equalTo:@"All"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Collection *> * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            // there should be only one Collection in objects
            if ([objects[0].places containsObject:self.place.placeID]) {
                [self.saveBarButton setImage:[UIImage systemImageNamed:@"bookmark.fill"]];
            } else { // user has not saved this place
                [self.saveBarButton setImage:[UIImage systemImageNamed:@"bookmark"]];
            }
        } else {
            NSLog(@"Error fetching user's saved locations: %@", error.localizedDescription);
        }
    }];
}

- (void)setupMenu {
    UIAction *savePlace = [UIAction actionWithTitle:@"Save" image:[UIImage systemImageNamed:@"heart"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self addPlaceToCollection:@"All"];
    }];
    self.saveMenu = [UIMenu menuWithChildren:@[savePlace]];
    [self.saveBarButton setMenu:self.saveMenu];
}

- (void)addPlaceToCollection:(NSString *)collectionName {
    PFQuery *query = [Collection query];
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"collectionName" equalTo:collectionName];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Collection *> * _Nullable objects, NSError * _Nullable error) {
        if (objects) { // should only have one item
            [Collection addPlaceId:self.place.placeID toCollection:objects[0] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Saved place");
                } else {
                    NSLog(@"Error saving place: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error finding a collection with that name");
        }
    }];
    
    [self.saveBarButton setImage:[UIImage systemImageNamed:@"bookmark.fill"]];
}

- (void)showStarRating {
    HCSStarRatingView *starRatingView = [HCSStarRatingView new];
    starRatingView.maximumValue = 5;
    starRatingView.minimumValue = 0;
    starRatingView.tintColor = [UIColor yellowColor];
    starRatingView.allowsHalfStars = YES;
    starRatingView.accurateHalfStars = YES;
    starRatingView.value = self.place.rating;
    [starRatingView setUserInteractionEnabled:NO];
    starRatingView.emptyStarImage = [[UIImage imageNamed:@"heart-empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    starRatingView.filledStarImage = [[UIImage imageNamed:@"heart-full"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.view addSubview:starRatingView];
    
    // autolayout star rating view
    starRatingView.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeTop
                            relatedBy:NSLayoutRelationEqual
                            toItem:self.addressLabel
                            attribute:NSLayoutAttributeBottom
                            multiplier:1.f constant:15.f] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeCenterX
                            relatedBy:NSLayoutRelationEqual
                            toItem:self.view
                            attribute:NSLayoutAttributeCenterX
                            multiplier:1.f constant:0.f] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                            attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationLessThanOrEqual
                            toItem:self.view
                            attribute:NSLayoutAttributeWidth
                            multiplier:.45f constant:0.f] setActive:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
