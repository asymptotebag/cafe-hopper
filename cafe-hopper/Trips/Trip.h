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
@property (strong, nonatomic) NSMutableArray<NSMutableDictionary *> *stops;
@property (strong, nonatomic) NSNumber *duration; // duration in MINUTES

+ (void)createTripWithName:(NSString *)tripName stops:(NSMutableArray<NSMutableDictionary *> * _Nullable)stops completion:(PFBooleanResultBlock)completion;

+ (void)deleteTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion;

+ (void)addStopWithPlaceId:(NSString *)placeId toTrip:(Trip *)trip completion:(PFBooleanResultBlock)completion;

//+ (void)removeStopWithPlaceId:(NSString *)placeId fromTrip:(Trip *)trip completion:(PFBooleanResultBlock)completion;

+ (void)removeStopAtIndex:(NSInteger)index fromTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion;

+ (void)changeDurationOfStopAtIndex:(NSInteger)index toDuration:(NSInteger)newDuration forTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
