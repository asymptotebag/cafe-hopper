//
//  Trip.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/16/21.
//

#import <Parse/Parse.h>
#import "User.h"
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface Trip : PFObject <PFSubclassing>
@property (strong, nonatomic) NSString *tripName;
@property (strong, nonatomic) User *owner;
@property (nonatomic) NSNumber *isActive; // boolean
@property (strong, nonatomic) NSMutableArray<NSMutableDictionary *> *stops;

+ (void)createTripWithName:(NSString *)tripName stops:(NSMutableArray<NSMutableDictionary *> * _Nullable)stops completion:(PFBooleanResultBlock)completion;

- (void)deleteWithCompletion:(PFBooleanResultBlock)completion;

- (void)addStopWithPlaceId:(NSString *)placeId completion:(PFBooleanResultBlock)completion;

- (void)removeStopAtIndex:(NSInteger)index withCompletion:(PFBooleanResultBlock)completion;

- (void)changeDurationOfStopAtIndex:(NSInteger)index toDuration:(NSInteger)newDuration withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
