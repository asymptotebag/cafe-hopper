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
@dynamic isActive;

+ (nonnull NSString *)parseClassName {
    return @"Trip";
}

+ (void)createTripWithName:(NSString *)tripName stops:(NSMutableArray<NSMutableDictionary *> *)stops completion:(PFBooleanResultBlock)completion {
    Trip *trip = [Trip new];
    trip.tripName = tripName;
    User *user = [User currentUser];
    trip.owner = user;
    trip.isActive = [NSNumber numberWithBool:NO];
    if (stops) {
        trip.stops = stops;
    } else {
        trip.stops = [NSMutableArray new];
    }

    [trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [user addTripNamed:tripName withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
            completion(true, nil);
        } else {
            NSLog(@"Error creating new trip: %@", error.localizedDescription);
            completion(false, error);
        }
    }];
}

- (void)deleteWithCompletion:(PFBooleanResultBlock)completion {
    User *user = [User currentUser];
    __weak typeof(self) weakSelf = self;
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (succeeded) {
            NSLog(@"%@ trip deleted.", strongSelf.tripName);
            [user removeTripNamed:strongSelf.tripName withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
            completion(true, nil);
        } else {
            NSLog(@"Error deleting trip: %@", error.localizedDescription);
            completion(false, error);
        }
    }];
}

- (void)changeDurationOfStopAtIndex:(NSInteger)index toDuration:(NSInteger)newDuration withCompletion:(PFBooleanResultBlock)completion {
    NSMutableDictionary *stopToChange = self.stops[index];
    stopToChange[@"minSpent"] = [NSNumber numberWithLong:newDuration];
    self[@"stops"] = self.stops;
    [self saveInBackgroundWithBlock:completion];
}

- (void)changeTravelModeOfStopAtIndex:(NSInteger)index toMode:(NSString *)newMode withCompletion:(PFBooleanResultBlock)completion {
    NSMutableDictionary *stopToChange = self.stops[index];
    stopToChange[@"travelMode"] = newMode;
    // recalculate distance to next stop using newMode
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
    NSMutableString *URLString = @"https://maps.googleapis.com/maps/api/distancematrix/json?".mutableCopy;
    
    NSMutableDictionary *nextStop = self.stops[index+1];
    NSString *originsParameter = [@"origins=place_id:" stringByAppendingString:stopToChange[@"placeId"]];
    NSString *destinationsParameter = [@"&destinations=place_id:" stringByAppendingString:nextStop[@"placeId"]];
    NSString *modeParameter = [@"&mode=" stringByAppendingString:newMode];
    NSString *keyParameter = [@"&key=" stringByAppendingString:googleAPIKey];
    [URLString appendString:originsParameter];
    [URLString appendString:destinationsParameter];
    [URLString appendString:modeParameter];
    [URLString appendString:keyParameter];
    NSLog(@"Full API request URL: %@", URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (error == nil) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *distanceMatrix = jsonDict[@"rows"];
            NSArray *elements = distanceMatrix[0][@"elements"];
            NSInteger durationSecs = [elements[0][@"duration"][@"value"] integerValue]; // value is in seconds, so convert to minutes
            NSInteger duration = durationSecs/60; // this truncates, doesn't round
            NSLog(@"duration = %li", duration);
            stopToChange[@"timeToNext"] = [NSNumber numberWithLong:duration];
        } else {
            NSLog(@"Error calling Distance Matrix API: %@", error.localizedDescription);
        }
        strongSelf[@"stops"] = strongSelf.stops;
        [strongSelf saveInBackgroundWithBlock:completion];
    }];
    [task resume];
}

- (void)addStopWithPlaceId:(NSString *)placeId completion:(PFBooleanResultBlock)completion {
    // duplicates are okay here
    NSMutableDictionary *newStop = [NSMutableDictionary new];
    [newStop setValue:placeId forKey:@"placeId"];
    [newStop setObject:@20 forKey:@"minSpent"]; // default 20 min per cafe
    [newStop setObject:[NSNumber numberWithUnsignedLong:self.stops.count] forKey:@"index"];
    [newStop setObject:@"driving" forKey:@"travelMode"];
    NSLog(@"newStop = %@", newStop);
    [self.stops addObject:newStop];
    
    if (self.stops.count < 2) {
        self[@"stops"] = self.stops;
        [self saveInBackgroundWithBlock:completion];
        return;
    }
    
    // get driving distance between stops
    // example: https://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&key=YOUR_API_KEY
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
    
    NSMutableString *URLString = @"https://maps.googleapis.com/maps/api/distancematrix/json?".mutableCopy;
    
    NSMutableDictionary *prevStop = self.stops[self.stops.count - 2]; // get the last-added stop
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
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (error == nil) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *distanceMatrix = jsonDict[@"rows"];
            NSArray *elements = distanceMatrix[0][@"elements"];
            NSInteger durationSecs = [elements[0][@"duration"][@"value"] integerValue]; // value is in seconds, so convert to minutes
            NSInteger duration = durationSecs/60; // this truncates, doesn't round
            NSLog(@"duration = %li", duration);
            prevStop[@"timeToNext"] = [NSNumber numberWithLong:duration];
        } else {
            NSLog(@"Error calling Distance Matrix API: %@", error.localizedDescription);
        }
        strongSelf[@"stops"] = strongSelf.stops;
        [strongSelf saveInBackgroundWithBlock:completion];
    }];
    [task resume];
}

- (void)removeStopAtIndex:(NSInteger)index withCompletion:(PFBooleanResultBlock)completion {
    // if first element, don't need to change anything
    // if last element, delete timeToNext of previous
    // otherwise, recalculate timeToNext from index-1 to index+1, set to prev stop's timeToNext
    
    NSMutableDictionary *stopToRemove = self.stops[index];
    
    if (index == 0) { // first stop
        // decrement index of all future stops
        for (int i=1; i<self.stops.count; i++) {
            NSMutableDictionary *currentStop = self.stops[i];
            currentStop[@"index"] = [NSNumber numberWithLong:[currentStop[@"index"] integerValue]-1];
        }
        [self.stops removeObject:stopToRemove];
        self[@"stops"] = self.stops;
        [self saveInBackgroundWithBlock:completion];
        return;
    } else if (index == self.stops.count - 1) { // last stop, trip necessarily has >1 stop
        NSMutableDictionary *prevStop = self.stops[index - 1];
        [prevStop removeObjectForKey:@"timeToNext"];
        [self.stops removeObject:stopToRemove];
        self[@"stops"] = self.stops;
        [self saveInBackgroundWithBlock:completion];
        return;
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *googleAPIKey = [dict objectForKey:@"googleMapsAPIKey"];
        
        NSMutableString *URLString = @"https://maps.googleapis.com/maps/api/distancematrix/json?".mutableCopy;
        
        NSMutableDictionary *prevStop = self.stops[index - 1];
        NSMutableDictionary *nextStop = self.stops[index + 1];
        
        NSString *originsParameter = [@"origins=place_id:" stringByAppendingString:prevStop[@"placeId"]];
        NSString *destinationsParameter = [@"&destinations=place_id:" stringByAppendingString:nextStop[@"placeId"]];
        NSString *keyParameter = [@"&key=" stringByAppendingString:googleAPIKey];
        [URLString appendString:originsParameter];
        [URLString appendString:destinationsParameter];
        [URLString appendString:keyParameter];
        NSLog(@"Full API request URL: %@", URLString);
        
        NSURL *url = [NSURL URLWithString:URLString];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        __weak typeof(self) weakSelf = self;
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (error == nil) {
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *distanceMatrix = jsonDict[@"rows"];
                NSArray *elements = distanceMatrix[0][@"elements"];
                NSInteger durationSecs = [elements[0][@"duration"][@"value"] integerValue]; // value is in seconds, so convert to minutes
                NSInteger duration = durationSecs/60; // this truncates, doesn't round
                NSLog(@"new duration = %li", duration);
                prevStop[@"timeToNext"] = [NSNumber numberWithUnsignedLong:duration];
                
                // decrement index of all future stops
                for (long i=index+1; i<strongSelf.stops.count; i++) {
                    NSMutableDictionary *currentStop = strongSelf.stops[i];
                    currentStop[@"index"] = [NSNumber numberWithLong:[currentStop[@"index"] integerValue]-1];
                }
                [strongSelf.stops removeObject:stopToRemove];
            } else {
                NSLog(@"Error calling Distance Matrix API: %@", error.localizedDescription);
            }
            strongSelf[@"stops"] = strongSelf.stops;
            [strongSelf saveInBackgroundWithBlock:completion];
        }];
        [task resume];
    }
}

@end
