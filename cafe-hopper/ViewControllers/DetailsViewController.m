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
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "Collection.h"
#import "CarouselCell.h"

@interface DetailsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIView *buttonBorder1;
@property (weak, nonatomic) IBOutlet UIView *buttonBorder2;
@property (weak, nonatomic) IBOutlet UIView *buttonBorder3;
@property (weak, nonatomic) IBOutlet UIButton *telephoneButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;

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
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    [self.pictureView setImage:[UIImage imageNamed:@"5"]];
    self.pictureView.layer.cornerRadius = self.pictureView.frame.size.height/2;
    self.pictureView.clipsToBounds = true;
    
    [self showStarRating];
    
    CGFloat buttonRadius = 10;
    UIColor *borderColor = [UIColor systemGray5Color];
    CGFloat borderWidth = 1.f;
    UIColor *backgroundColor = [UIColor clearColor];
    self.buttonBorder1.layer.cornerRadius = buttonRadius;
    self.buttonBorder1.layer.borderColor = borderColor.CGColor;
    self.buttonBorder1.layer.borderWidth = borderWidth;
    self.buttonBorder1.layer.backgroundColor = backgroundColor.CGColor;
    self.buttonBorder2.layer.cornerRadius = buttonRadius;
    self.buttonBorder2.layer.borderColor = borderColor.CGColor;
    self.buttonBorder2.layer.borderWidth = borderWidth;
    self.buttonBorder2.layer.backgroundColor = backgroundColor.CGColor;
    self.buttonBorder3.layer.cornerRadius = buttonRadius;
    self.buttonBorder3.layer.borderColor = borderColor.CGColor;
    self.buttonBorder3.layer.borderWidth = borderWidth;
    self.buttonBorder3.layer.backgroundColor = backgroundColor.CGColor;
    
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

- (IBAction)onTapTelephone:(id)sender {
    NSString *phoneNumber = @"6507880661"; // my phone number for now
//    NSString *phoneNumber = self.place.phoneNumber;
    NSString *urlString = [@"tel://" stringByAppendingString:phoneNumber];
    NSURL *phoneURL = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:^(BOOL success) {}];
}

- (IBAction)onTapWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:self.place.website options:@{} completionHandler:^(BOOL success) {}];
}

- (IBAction)onTapDirections:(id)sender {
    NSString *baseURLString = @"https://www.google.com/maps/dir/?api=1";
    NSString *destination = [self.place.name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *destinationParameter = [@"&destination=" stringByAppendingString:destination];
    NSString *destinationPlaceIdParameter = [@"&destination_place_id=" stringByAppendingString:self.place.placeID];
    NSString *URLString = [[baseURLString stringByAppendingString:destinationParameter] stringByAppendingString:destinationPlaceIdParameter];
    NSLog(@"URL to open: %@", URLString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString] options:@{} completionHandler:^(BOOL success) {}];
}

- (void)setupMenu {
    NSMutableArray *menuItems = [NSMutableArray new];
    UIAction *savePlace = [UIAction actionWithTitle:@"Save" image:[UIImage systemImageNamed:@"heart"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self addPlaceToCollection:@"All"];
    }];
    [menuItems addObject:savePlace];
    
    for (NSString *collectionName in self.user.collectionNames) {
        NSString *actionName = [@"Save to " stringByAppendingString:collectionName];
        UIAction *saveToCollection = [UIAction actionWithTitle:actionName image:[UIImage systemImageNamed:@"bookmark"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            // these are not the All collections, so save to both collection and All
            [self addPlaceToCollection:@"All"];
            [self addPlaceToCollection:collectionName];
        }];
        [menuItems addObject:saveToCollection];
    }
    
    self.saveMenu = [UIMenu menuWithChildren:menuItems];
    [self.saveBarButton setMenu:self.saveMenu];
}

- (void)addPlaceToCollection:(NSString *)collectionName {
    PFQuery *query = [Collection query];
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"collectionName" equalTo:collectionName];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) { // should only have one item
            [Collection addPlaceId:self.place.placeID toCollection:object withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Saved place to %@", collectionName);
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
    [starRatingView setBackgroundColor:[UIColor clearColor]];
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
                            multiplier:.4f constant:0.f] setActive:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    CGFloat height = self.collectionView.frame.size.height - 1;
    CGFloat width = height;
    self.flowLayout.itemSize = CGSizeMake(width, height);
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5; // 5 images for now
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CarouselCell" forIndexPath:indexPath];
    cell.place = self.place;
    return cell;
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
