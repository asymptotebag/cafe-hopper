//
//  Collection.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "Collection.h"

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

+ (void)addPlaceId:(NSString *)placeId toCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    [collection.places addObject:placeId];
    collection[@"places"] = collection.places;
    [collection saveInBackgroundWithBlock:completion];
}

+ (void)removePlaceId:(NSString *)placeId fromCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion {
    [collection.places removeObject:placeId];
    collection[@"places"] = collection.places;
    [collection saveInBackgroundWithBlock:completion];
}

@end
