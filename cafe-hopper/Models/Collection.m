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
    collection.owner = [User currentUser];
    collection.places = [NSMutableArray new];
    [collection saveInBackgroundWithBlock:completion];
}

+ (void)deleteCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    [Collection deleteAllInBackground:@[collection] block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"%@ collection deleted.", collection.collectionName);
            [User removeCollectionNamed:collection.collectionName forUser:[User currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
        } else {
            NSLog(@"Error deleting collection: %@", error.localizedDescription);
        }
    }];
}

+ (void)deleteCollectionWithName:(NSString *)name completion:(PFBooleanResultBlock)completion {
    PFQuery *query = [Collection query];
    [query whereKey:@"collectionName" equalTo:name];
    [query whereKey:@"owner" equalTo:[User currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            [Collection deleteAllInBackground:@[object] block:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"%@ collection deleted.", name);
                    [User removeCollectionNamed:name forUser:[User currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
                } else {
                    NSLog(@"Error deleting collection: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Couldn't find object.");
        }
    }];
}

+ (void)addPlaceId:(NSString *)placeId toCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    if (![collection.places containsObject:placeId]) { // only add if it isn't a duplicate
        [collection.places addObject:placeId];
        collection[@"places"] = collection.places;
        [collection saveInBackgroundWithBlock:completion];
    }
}

+ (void)removePlaceId:(NSString *)placeId fromCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    [collection.places removeObject:placeId];
    collection[@"places"] = collection.places;
    [collection saveInBackgroundWithBlock:completion];
}

@end
