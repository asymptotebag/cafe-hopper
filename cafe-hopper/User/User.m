//
//  User.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "User.h"

@implementation User

@dynamic name;
@dynamic pfp;
@dynamic collectionNames;
@dynamic tripNames;

+ (void)addCollectionNamed:(NSString *)collectionName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion {
    [user.collectionNames addObject:collectionName];
    user[@"collectionNames"] = user.collectionNames;
    [user saveInBackgroundWithBlock:completion];
}

+ (void)removeCollectionNamed:(NSString *)collectionName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion {
    [user.collectionNames removeObject:collectionName];
    user[@"collectionNames"] = user.collectionNames;
    [user saveInBackgroundWithBlock:completion];
}

+ (void)addTripNamed:(NSString *)tripName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion {
    [user.tripNames addObject:tripName];
    user[@"tripNames"] = user.tripNames;
    [user saveInBackgroundWithBlock:completion];
}

+ (void)removeTripNamed:(NSString *)tripName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion {
    [user.tripNames removeObject:tripName];
    user[@"tripNames"] = user.tripNames;
    [user saveInBackgroundWithBlock:completion];
}

+ (void)changeNameForUser:(User *)user withName:(NSString *)name completion:(PFBooleanResultBlock)completion {
    user.name = name;
    [user saveInBackgroundWithBlock:completion];
}

+ (void)changePfpForUser:(User *)user withPfp:(UIImage *)pfp completion:(PFBooleanResultBlock)completion {
    // TODO: change pfp for user
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


@end
