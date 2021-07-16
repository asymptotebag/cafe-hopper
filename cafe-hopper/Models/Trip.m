//
//  Trip.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/16/21.
//

#import "Trip.h"
#import "User.h"
#import <Parse/Parse.h>

@implementation Trip
@dynamic tripName;
@dynamic stops;
@dynamic owner;

+ (nonnull NSString *)parseClassName {
    return @"Trip";
}

+ (void)createTripWithName:(NSString *)tripName stops:(NSMutableArray<NSString *> *)stops completion:(PFBooleanResultBlock)completion {
    Trip *trip = [Trip new];
    trip.tripName = tripName;
    trip.owner = [User currentUser];
    if (stops) {
        trip.stops = stops;
    } else {
        trip.stops = [NSMutableArray new];
    }

    [trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [User addTripNamed:tripName forUser:[User currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
            completion(true, nil);
        } else {
            NSLog(@"Error creating new trip: %@", error.localizedDescription);
            completion(false, error);
        }
    }];
}

+ (void)deleteTripWithName:(NSString *)tripName withCompletion:(PFBooleanResultBlock)completion {
    
}

+ (void)deleteTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion {
    [Trip deleteAllInBackground:@[trip] block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"%@ trip deleted.", trip.tripName);
            [User removeTripNamed:trip.tripName forUser:[User currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
            completion(true, nil);
        } else {
            NSLog(@"Error deleting trip: %@", error.localizedDescription);
            completion(false, error);
        }
    }];
}

+ (void)addStopWithPlaceId:(NSString *)placeId toTrip:(Trip *)trip completion:(PFBooleanResultBlock)completion {
    // duplicates are okay here
    [trip.stops addObject:placeId];
    trip[@"stops"] = trip.stops;
    [trip saveInBackgroundWithBlock:completion];
}

+ (void)removeStopAtIndex:(NSInteger)index fromTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion {
    NSString *stopToRemove = trip.stops[index];
    [trip.stops removeObject:stopToRemove];
    trip[@"stops"] = trip.stops;
    [trip saveInBackgroundWithBlock:completion];
}

@end
