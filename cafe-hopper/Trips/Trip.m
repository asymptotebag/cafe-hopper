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
@dynamic duration;

+ (nonnull NSString *)parseClassName {
    return @"Trip";
}

+ (void)createTripWithName:(NSString *)tripName stops:(NSMutableArray<NSMutableDictionary *> *)stops completion:(PFBooleanResultBlock)completion {
    Trip *trip = [Trip new];
    trip.tripName = tripName;
    trip.owner = [User currentUser];
    if (stops) {
        trip.stops = stops;
    } else {
        trip.stops = [NSMutableArray new];
    }
    trip.duration = [NSNumber numberWithUnsignedLong:20*stops.count];

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
    NSMutableDictionary *newStop = [NSMutableDictionary new];
    [newStop setValue:placeId forKey:@"placeId"];
    [newStop setObject:@20 forKey:@"minSpent"]; // default 20 min per cafe
    NSLog(@"newStop = %@", newStop);
    [trip.stops addObject:newStop];
    
    trip.duration = [NSNumber numberWithUnsignedLong:[trip.duration intValue]+20];
    
    if (trip.stops.count < 2) {
        trip[@"stops"] = trip.stops;
        [trip saveInBackgroundWithBlock:completion];
        return;
    }
    
    // TODO: get walking distance between stops
    // example: https://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&key=YOUR_API_KEY
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
    
    NSMutableString *URLString = @"https://maps.googleapis.com/maps/api/distancematrix/json?".mutableCopy;
    
    NSMutableDictionary *prevStop = trip.stops[trip.stops.count - 2]; // get the last-added stop
    NSString *prevPlaceId = prevStop[@"placeId"];
    NSString *originsParameter = [@"origins=place_id:" stringByAppendingString:prevPlaceId];
    NSString *destinationsParameter = [@"&destinations=place_id:" stringByAppendingString:placeId];
    NSString *keyParameter = [@"&key=" stringByAppendingString:googleAPIKey];
    [URLString appendString:originsParameter];
    [URLString appendString:destinationsParameter];
    [URLString appendString:keyParameter];
    NSLog(@"Full API request URL: %@", URLString);
    
    // make actual network request:
    NSURL *url = [NSURL URLWithString:URLString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *distanceMatrix = jsonDict[@"rows"];
            NSArray *elements = distanceMatrix[0][@"elements"];
            NSInteger durationSecs = [elements[0][@"duration"][@"value"] integerValue]; // value is in seconds, so convert to minutes
            NSInteger duration = durationSecs/60; // this truncates, doesn't round
            NSLog(@"duration = %li", duration);
            prevStop[@"timeToNext"] = [NSNumber numberWithUnsignedLong:duration];
            trip.duration = [NSNumber numberWithUnsignedLong:[trip.duration intValue]+duration];
        } else {
            NSLog(@"Error calling Distance Matrix API: %@", error.localizedDescription);
        }
        trip[@"stops"] = trip.stops;
        [trip saveInBackgroundWithBlock:completion];
    }];
    [task resume];
}

+ (void)removeStopAtIndex:(NSInteger)index fromTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion {
    NSMutableDictionary *stopToRemove = trip.stops[index];
    [trip.stops removeObject:stopToRemove];
    trip[@"stops"] = trip.stops;
    [trip saveInBackgroundWithBlock:completion];
}

@end
