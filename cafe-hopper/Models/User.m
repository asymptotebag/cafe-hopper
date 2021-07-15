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
