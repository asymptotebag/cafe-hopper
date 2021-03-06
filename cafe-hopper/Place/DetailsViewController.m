//
//  DetailsViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "Collection.h"
#import "Trip.h"
#import "CarouselCell.h"
#import "ReviewCell.h"
#import <Parse/Parse.h>
#import <HCSStarRatingView/HCSStarRatingView.h>
#import <NSString_UrlEncode/NSString+URLEncode.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>

@interface DetailsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) UIMenu *saveMenu;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tripBarButton;
@property (strong, nonatomic) UIMenu *tripMenu;

@property (weak, nonatomic) IBOutlet UICollectionView *carouselCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *carouselFlowLayout;
@property (strong, nonatomic) NSArray<GMSPlacePhotoMetadata *> *placePhotos;

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;
@property (weak, nonatomic) IBOutlet UIImageView *bigHeart;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIView *telephoneButtonBackground;
@property (weak, nonatomic) IBOutlet UIView *websiteButtonBackground;
@property (weak, nonatomic) IBOutlet UIView *directionsButtonBackground;
@property (weak, nonatomic) IBOutlet UIButton *telephoneButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;

@property (weak, nonatomic) IBOutlet UICollectionView *reviewsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *reviewsFlowLayout;
@property (strong, nonatomic) NSArray<NSDictionary *> *reviews;

@end

@implementation DetailsViewController {
    GMSPlacesClient *_placesClient;
    BOOL usingRealImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User currentUser];
    _placesClient = [GMSPlacesClient sharedClient];
    usingRealImages = YES;
    self.reviews = @[];
    self.placePhotos = @[];
    
    [self setupView];
}

- (void)setupView {
    self.carouselCollectionView.dataSource = self;
    self.carouselCollectionView.delegate = self;
    self.reviewsCollectionView.dataSource = self;
    self.reviewsCollectionView.delegate = self;
    
    CGFloat fontSize = self.view.frame.size.width * 0.0851 - 5.23;
    CGFloat secondaryFontSize = self.view.frame.size.width * 0.0319 + 3.79;
    [self.nameLabel setFont:[UIFont systemFontOfSize:fontSize weight:UIFontWeightThin]];
    [self.addressLabel setFont:[UIFont systemFontOfSize:secondaryFontSize weight:UIFontWeightThin]];
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    if (usingRealImages) {
        GMSPlacePhotoMetadata *photoMetadata = self.place.photos[0];
        __weak typeof(self) weakSelf = self;
        [_placesClient loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (photo) {
                strongSelf.pictureView.alpha = 0;
                [strongSelf.pictureView setImage:photo];
                [UIView animateWithDuration:0.3 animations:^{
                    strongSelf.pictureView.alpha = 1;
                }];
            } else {
                NSLog(@"Error getting place photo: %@", error.localizedDescription);
            }
        }];
    } else {
        self.pictureView.alpha = 0;
        [self.pictureView setImage:[UIImage imageNamed:@"5"]];
        [UIView animateWithDuration:0.3 animations:^{
            self.pictureView.alpha = 1;
        }];
    }
    
    self.pictureView.layer.cornerRadius = self.pictureView.frame.size.height/2;
    self.pictureView.clipsToBounds = true;
    [self.pictureView setUserInteractionEnabled:YES];
    [self.pictureView addGestureRecognizer:self.doubleTapGesture];
    self.bigHeart.hidden = YES;
    
    [self showStarRating];
    
    CGFloat buttonRadius = 10;
    self.telephoneButtonBackground.layer.cornerRadius = buttonRadius;
    self.websiteButtonBackground.layer.cornerRadius = buttonRadius;
    self.directionsButtonBackground.layer.cornerRadius = buttonRadius;
    
    [self fetchReviews];
    [self setupMenus];
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
    NSString *destination = [self.place.name URLEncode];
    NSString *destinationParameter = [@"&destination=" stringByAppendingString:destination];
    NSString *destinationPlaceIdParameter = [@"&destination_place_id=" stringByAppendingString:self.place.placeID];
    NSString *URLString = [[baseURLString stringByAppendingString:destinationParameter] stringByAppendingString:destinationPlaceIdParameter];
    NSLog(@"URL to open: %@", URLString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString] options:@{} completionHandler:^(BOOL success) {}];
}

- (void)fetchReviews {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
    
    NSMutableString *URLString = @"https://maps.googleapis.com/maps/api/place/details/json?".mutableCopy;
    NSString *placeIdParam = [@"place_id=" stringByAppendingString:self.place.placeID];
    NSString *fieldsParam = @"&fields=reviews";
    NSString *keyParameter = [@"&key=" stringByAppendingString:googleAPIKey];
    [URLString appendString:placeIdParam];
    [URLString appendString:fieldsParam];
    [URLString appendString:keyParameter];
    NSLog(@"Full Places Details API request URL: %@", URLString);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *result = jsonDict[@"result"];
            self.reviews = result[@"reviews"];
            NSLog(@"%li reviews fetched", self.reviews.count);
            // reload whatever is displaying these reviews
            [self.reviewsCollectionView reloadData];
        } else {
            NSLog(@"Error calling Places Details API: %@", error.localizedDescription);
        }
    }];
    [task resume];
}

- (void)setupMenus {
    // see if collections bar button should be filled
    PFQuery *query = [Collection query];
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"collectionName" equalTo:@"All"];
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray<Collection *> * _Nullable objects, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
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
    
    // see if trips bar button should be filled
    PFQuery *tripQuery = [Trip query];
    [tripQuery whereKey:@"owner" equalTo:self.user];
    [tripQuery findObjectsInBackgroundWithBlock:^(NSArray<Trip *> * _Nullable trips, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (trips) {
            BOOL isSaved = NO;
            for (Trip *trip in trips) {
                NSMutableArray *placeIds = [NSMutableArray new]; // list of this stop's places
                for (NSMutableDictionary *stop in trip.stops) {
                    [placeIds addObject:stop[@"placeId"]];
                }
                if ([placeIds containsObject:self.place.placeID]) {
                    isSaved = YES;
                    break;
                }
            }
            if (isSaved) {
                [self.tripBarButton setImage:[UIImage systemImageNamed:@"location.fill"]];
            } else {
                [self.tripBarButton setImage:[UIImage systemImageNamed:@"location"]];
            }
        } else {
            NSLog(@"Error fetching user's trips: %@", error.localizedDescription);
        }
    }];
    
    [self setupSaveMenu];
    [self setupTripMenu]; // check if user has any trips yet?
}

- (void)setupSaveMenu {
    NSMutableArray *menuItems = [NSMutableArray new];
    UIAction *savePlace = [UIAction actionWithTitle:@"Save" image:[UIImage systemImageNamed:@"heart"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self addPlaceToCollection:@"All"];
//        [savePlace setImage:[UIImage systemImageNamed:@"heart.fill"]];
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
    
    self.saveMenu = [UIMenu menuWithTitle:@"Add to collection:" children:menuItems];
    [self.saveBarButton setMenu:self.saveMenu];
}

- (void)setupTripMenu {
    NSMutableArray *menuItems = [NSMutableArray new];
    
    for (NSString *tripName in self.user.tripNames) {
        NSString *actionName = [@"Add to " stringByAppendingString:tripName];
        UIAction *saveToTrip = [UIAction actionWithTitle:actionName image:[UIImage systemImageNamed:@"location"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [self addPlaceToTrip:tripName];
        }];
        [menuItems addObject:saveToTrip];
    }
    
    self.tripMenu = [UIMenu menuWithTitle:@"Add to trip:" children:menuItems];
    [self.tripBarButton setMenu:self.tripMenu];
}

- (void)addPlaceToCollection:(NSString *)collectionName {
    PFQuery *query = [Collection query];
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"collectionName" equalTo:collectionName];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) { // should only have one item
            Collection *collection = (Collection *)object;
            [collection addPlaceId:self.place.placeID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Saved place to %@", collectionName);
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
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

- (void)addPlaceToTrip:(NSString *)tripName {
    PFQuery *query = [Trip query];
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"tripName" equalTo:tripName];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            Trip *trip = (Trip *)object;
            [trip addStopWithPlaceId:self.place.placeID completion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Saved place to %@", tripName);
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                } else {
                    NSLog(@"Error saving place: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Error finding a trip with that name");
        }
    }];
    [self.tripBarButton setImage:[UIImage systemImageNamed:@"location.fill"]];
}

- (IBAction)onDoubleTap:(id)sender {
    NSLog(@"double tap detected");
    [self addPlaceToCollection:@"All"];
    [self animateHeart];
}

- (void)animateHeart {
    self.bigHeart.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.bigHeart.alpha = 0;
    self.bigHeart.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.bigHeart.transform = CGAffineTransformMakeScale(1, 1);
        self.bigHeart.alpha = 0.9;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0.4 options:UIViewAnimationOptionPreferredFramesPerSecondDefault
         animations:^{
            self.bigHeart.transform = CGAffineTransformMakeScale(0.7, 0.7);
            self.bigHeart.alpha = 0;
        } completion:^(BOOL finished) {
            self.bigHeart.hidden = YES;
        }];
    }];
}

- (void)showStarRating {
    HCSStarRatingView *starRatingView = [HCSStarRatingView new];
    starRatingView.maximumValue = 5;
    starRatingView.minimumValue = 0;
    starRatingView.tintColor = [UIColor colorNamed:@"MaizeCrayola"];
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
                            multiplier:1.f constant:12.f] setActive:YES];
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
    
    self.carouselFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.carouselFlowLayout.minimumLineSpacing = 0;
    self.carouselFlowLayout.minimumInteritemSpacing = 0;
    CGFloat height = self.carouselCollectionView.frame.size.height;
    CGFloat width = height;
    self.carouselFlowLayout.itemSize = CGSizeMake(width, height);
    self.carouselFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.carouselCollectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.reviewsFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.reviewsFlowLayout.minimumLineSpacing = 0;
    self.reviewsFlowLayout.minimumInteritemSpacing = 0;
    CGFloat reviewHeight = self.reviewsCollectionView.frame.size.height;
    CGFloat reviewWidth = self.reviewsCollectionView.frame.size.width;
    self.reviewsFlowLayout.itemSize = CGSizeMake(reviewWidth, reviewHeight);
    self.reviewsFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.reviewsCollectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.carouselCollectionView) {
        if (self.place.photos.count > 5) {
            return 5;
        } else {
            return self.place.photos.count - 1; // 1st photo is the center pic
        }
    } else { // reviews collection view
        if (self.reviews.count >= 5) { // google returns max 5, but just in case
            return 5;
        } else {
            return self.reviews.count;
        }
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.carouselCollectionView) {
        CarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CarouselCell" forIndexPath:indexPath];
        if (usingRealImages) {
            GMSPlacePhotoMetadata *photoMetadata = self.place.photos[indexPath.item+1];
            __weak typeof(self) weakSelf = self;
            [_placesClient loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                __typeof__(self) strongSelf = weakSelf;
                if (strongSelf == nil) {
                    return;
                }
                if (photo) {
                    cell.photo = photo;
                } else {
                    NSLog(@"Error getting place photo: %@", error.localizedDescription);
                }
            }];
        } else { // use random placeholder image
            NSInteger randint = arc4random_uniform(6) + 1;
            NSString *imgName = [NSString stringWithFormat:@"%li", randint];
            cell.photo = [UIImage imageNamed:imgName];
        }
        return cell;
    }
    ReviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReviewCell" forIndexPath:indexPath];
    NSDictionary *review = self.reviews[indexPath.item];
    cell.review = review;
    return cell;
}

@end
