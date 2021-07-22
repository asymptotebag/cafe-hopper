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

+ (void)changeDurationOfStopAtIndex:(NSInteger)index toDuration:(NSInteger)newDuration forTrip:(Trip *)trip withCompletion:(PFBooleanResultBlock)completion {
    NSMutableDictionary *stopToChange = trip.stops[index];
    trip.duration = [NSNumber numberWithLong:[trip.duration integerValue] - [stopToChange[@"minSpent"] integerValue] + newDuration];
    stopToChange[@"minSpent"] = [NSNumber numberWithLong:newDuration];
    trip[@"stops"] = trip.stops;
    [trip saveInBackgroundWithBlock:completion];
}

+ (void)addStopWithPlaceId:(NSString *)placeId toTrip:(Trip *)trip completion:(PFBooleanResultBlock)completion {
    // duplicates are okay here
    NSMutableDictionary *newStop = [NSMutableDictionary new];
    [newStop setValue:placeId forKey:@"placeId"];
    [newStop setObject:@20 forKey:@"minSpent"]; // default 20 min per cafe
    [newStop setObject:[NSNumber numberWithUnsignedLong:trip.stops.count] forKey:@"index"];
    NSLog(@"newStop = %@", newStop);
    [trip.stops addObject:newStop];
    
    trip.duration = [NSNumber numberWithUnsignedLong:[trip.duration integerValue]+20];
    
    if (trip.stops.count < 2) {
        trip[@"stops"] = trip.stops;
        [trip saveInBackgroundWithBlock:completion];
        return;
    }
    
    // get driving distance between stops
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
    // TODO: fix deletion (this is going to be hard lol)
    
    // if first element, don't need to change anything, new duration = prev duration - minSpent[index] - timeToNext[index]
    // if last element, delete timeToNext of previous, new duration = prev duration - minSpent[index] - timeToNext[index-1]
    // otherwise:
    // recalculate timeToNext from index-1 to index+1, set to prev stop's timeToNext
    // duration: prev duration - minSpent[index] - timetoNext[index] - timetoNext[index-1] + new timeToNext[index-1 to index+1]
    
    NSMutableDictionary *stopToRemove = trip.stops[index];
    
    if (index == 0) { // first stop
        trip.duration = [NSNumber numberWithLong:[trip.duration integerValue] - [stopToRemove[@"minSpent"] integerValue]];
        if (stopToRemove[@"timeToNext"]) {
            trip.duration = [NSNumber numberWithLong:[trip.duration integerValue] - [stopToRemove[@"timeToNext"] integerValue]];
        }
        // decrement index of all future stops
        for (int i=1; i<trip.stops.count; i++) {
            NSMutableDictionary *currentStop = trip.stops[i];
            currentStop[@"index"] = [NSNumber numberWithLong:[currentStop[@"index"] integerValue]-1];
        }
        [trip.stops removeObject:stopToRemove];
        trip[@"stops"] = trip.stops;
        [trip saveInBackgroundWithBlock:completion];
        return;
    } else if (index == trip.stops.count - 1) { // last stop, trip necessarily has >1 stop
        NSMutableDictionary *prevStop = trip.stops[index - 1];
        trip.duration = [NSNumber numberWithLong:[trip.duration integerValue] - [stopToRemove[@"minSpent"] integerValue] - [prevStop[@"timeToNext"] integerValue]];
        [prevStop removeObjectForKey:@"timeToNext"];
        
        [trip.stops removeObject:stopToRemove];
        trip[@"stops"] = trip.stops;
        [trip saveInBackgroundWithBlock:completion];
        return;
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
        
        NSMutableString *URLString = @"https://maps.googleapis.com/maps/api/distancematrix/json?".mutableCopy;
        
        NSMutableDictionary *prevStop = trip.stops[index - 1];
        NSMutableDictionary *nextStop = trip.stops[index + 1];
        
        NSString *originsParameter = [@"origins=place_id:" stringByAppendingString:prevStop[@"placeId"]];
        NSString *destinationsParameter = [@"&destinations=place_id:" stringByAppendingString:nextStop[@"placeId"]];
        NSString *keyParameter = [@"&key=" stringByAppendingString:googleAPIKey];
        [URLString appendString:originsParameter];
        [URLString appendString:destinationsParameter];
        [URLString appendString:keyParameter];
        NSLog(@"Full API request URL: %@", URLString);
        
        NSURL *url = [NSURL URLWithString:URLString];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error == nil) {
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *distanceMatrix = jsonDict[@"rows"];
                NSArray *elements = distanceMatrix[0][@"elements"];
                NSInteger durationSecs = [elements[0][@"duration"][@"value"] integerValue]; // value is in seconds, so convert to minutes
                NSInteger duration = durationSecs/60; // this truncates, doesn't round
                NSLog(@"new duration = %li", duration);
                
                trip.duration = [NSNumber numberWithLong:[trip.duration integerValue] - [stopToRemove[@"minSpent"] integerValue] - [stopToRemove[@"timeToNext"] integerValue] - [prevStop[@"timeToNext"] integerValue] + duration];

                prevStop[@"timeToNext"] = [NSNumber numberWithUnsignedLong:duration];
                // decrement index of all future stops
                for (int i=index+1; i<trip.stops.count; i++) {
                    NSMutableDictionary *currentStop = trip.stops[i];
                    currentStop[@"index"] = [NSNumber numberWithLong:[currentStop[@"index"] integerValue]-1];
                }
                [trip.stops removeObject:stopToRemove];
            } else {
                NSLog(@"Error calling Distance Matrix API: %@", error.localizedDescription);
            }
            trip[@"stops"] = trip.stops;
            [trip saveInBackgroundWithBlock:completion];
        }];
        [task resume];
    }
}

@end
