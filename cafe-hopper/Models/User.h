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
@property (nonatomic, strong) NSMutableArray *collectionNames;
//@property (nonatomic, strong) NSMutableArray *collections;
//@property (nonatomic, strong) NSMutableArray *trips;

+ (void) addCollectionNamed:(NSString *)collectionName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion;

+ (void) removeCollectionNamed:(NSString *)collectionName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion;

+ (void)changeNameForUser: (User *)user withName:(NSString * _Nullable)name completion:(PFBooleanResultBlock _Nullable)completion;

+ (void)changePfpForUser: (User *)user withPfp:(UIImage *)pfp completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
