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
@dynamic isShowingBars;
@dynamic searchHistory;

- (void)addCollectionNamed:(NSString *)collectionName withCompletion:(PFBooleanResultBlock)completion {
    [self.collectionNames addObject:collectionName];
    self[@"collectionNames"] = self.collectionNames;
    [self saveInBackgroundWithBlock:completion];
}

- (void)removeCollectionNamed:(NSString *)collectionName withCompletion:(PFBooleanResultBlock)completion {
    [self.collectionNames removeObject:collectionName];
    self[@"collectionNames"] = self.collectionNames;
    [self saveInBackgroundWithBlock:completion];
}

- (void)addTripNamed:(NSString *)tripName withCompletion:(PFBooleanResultBlock)completion {
    [self.tripNames addObject:tripName];
    self[@"tripNames"] = self.tripNames;
    [self saveInBackgroundWithBlock:completion];
}

- (void)removeTripNamed:(NSString *)tripName withCompletion:(PFBooleanResultBlock)completion {
    [self.tripNames removeObject:tripName];
    self[@"tripNames"] = self.tripNames;
    [self saveInBackgroundWithBlock:completion];
}

- (void)changeInfoWithName:(NSString *)name username:(NSString *)username email:(NSString *)email completion:(PFBooleanResultBlock)completion {
    self.name = name;
    self.username = username;
    self.email = email;
    [self saveInBackgroundWithBlock:completion];
}

- (void)changePfpWithPfp:(UIImage *)pfp completion:(PFBooleanResultBlock)completion {
    self.pfp = [self getPFFileFromImage:pfp];
    [self saveInBackgroundWithBlock:completion];
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
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
