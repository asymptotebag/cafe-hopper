//
//  Collection.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "Collection.h"
#import "User.h"
#import <Parse/Parse.h>

@implementation Collection
@dynamic collectionName;
@dynamic places;
@dynamic owner;

+ (NSString *)parseClassName {
    return @"Collection";
}

+ (void)createCollectionWithName:(NSString *)name completion:(PFBooleanResultBlock)completion {
    Collection *collection = [Collection new];
    collection.collectionName = name;
    User *user = [User currentUser];
    collection.owner = user;
    collection.places = [NSMutableArray new];
    [collection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Created new collection successfully.");
            if (![name isEqualToString:@"All"]) {
                [user addCollectionNamed:name withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
            }
            completion(true, nil);
        } else {
            NSLog(@"Error creating collection: %@", error.localizedDescription);
            completion(false, error);
        }
    }];
}

- (void)deleteWithCompletion:(PFBooleanResultBlock)completion {
    User *user = [User currentUser];
    [Collection deleteAllInBackground:@[self] block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"%@ collection deleted.", self.collectionName);
            [user removeCollectionNamed:self.collectionName withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
            completion(true, nil);
        } else {
            NSLog(@"Error deleting collection: %@", error.localizedDescription);
            completion(false, error);
        }
    }];
}

- (void)addPlaceId:(NSString *)placeId withCompletion:(PFBooleanResultBlock)completion {
    if (![self.places containsObject:placeId]) {
        [self.places addObject:placeId];
        self[@"places"] = self.places;
        [self saveInBackgroundWithBlock:completion];
    }
}

+ (void)addPlaceId:(NSString *)placeId toCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    if (![collection.places containsObject:placeId]) { // only add if it isn't a duplicate
        [collection.places addObject:placeId];
        collection[@"places"] = collection.places;
        [collection saveInBackgroundWithBlock:completion];
    }
}

- (void)removePlaceId:(NSString *)placeId withCompletion:(PFBooleanResultBlock)completion {
    [self.places removeObject:placeId];
    self[@"places"] = self.places;
    [self saveInBackgroundWithBlock:completion];
}

+ (void)removePlaceId:(NSString *)placeId fromCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    [collection.places removeObject:placeId];
    collection[@"places"] = collection.places;
    [collection saveInBackgroundWithBlock:completion];
}

@end
