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
@dynamic timePerStop;
@dynamic notifsOn;

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

+ (void)changeInfoForUser:(User *)user withName:(NSString *)name username:(NSString *)username email:(NSString *)email completion:(PFBooleanResultBlock)completion {
    user.name = name;
    user.username = username;
    user.email = email;
    [user saveInBackgroundWithBlock:completion];
}

+ (void)changePfpForUser:(User *)user withPfp:(UIImage *)pfp completion:(PFBooleanResultBlock)completion {
    user.pfp = [self getPFFileFromImage:pfp];
    [user saveInBackgroundWithBlock:completion];
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
