//
//  DetailsViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import <HCSStarRatingView/HCSStarRatingView.h>

@interface DetailsViewController ()
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
    [self setupView];
}

- (void)setupView {
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    self.pictureView.layer.cornerRadius = self.pictureView.frame.size.height/2;
    self.pictureView.clipsToBounds = true;
    
    [self showStarRating];
    [self setupMenu];
}

- (void)setupMenu {
    UIAction *savePlace = [UIAction actionWithTitle:@"Save" image:[UIImage systemImageNamed:@"heart"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSLog(@"Tapped save button");
    }];
    self.saveMenu = [UIMenu menuWithChildren:@[savePlace]];
    [self.saveBarButton setMenu:self.saveMenu];
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
