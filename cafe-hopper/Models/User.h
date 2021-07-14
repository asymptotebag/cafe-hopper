//
//  User.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : PFUser <PFSubclassing>
// already has fields email, username, password
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PFFileObject *pfp;
@property (nonatomic, strong) NSMutableDictionary *collections;
@property (nonatomic, strong) NSMutableDictionary *trips;

+ (void)changeNameForUser: (User *)user withName:(NSString * _Nullable)name completion:(PFBooleanResultBlock _Nullable)completion;

+ (void)changePfpForUser: (User *)user withPfp:(UIImage *)pfp completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
