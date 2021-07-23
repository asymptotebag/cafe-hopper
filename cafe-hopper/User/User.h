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
@property (nonatomic, strong) PFFileObject * _Nullable pfp;
@property (nonatomic, strong) NSMutableArray *collectionNames;
@property (nonatomic, strong) NSMutableArray *tripNames;
@property (nonatomic) NSNumber *timePerStop;
@property (nonatomic) NSNumber *notifsOn;

+ (void)addCollectionNamed:(NSString *)collectionName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion;

+ (void)removeCollectionNamed:(NSString *)collectionName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion;

+ (void)addTripNamed:(NSString *)tripName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion;

+ (void)removeTripNamed:(NSString *)tripName forUser:(User *)user withCompletion:(PFBooleanResultBlock)completion;

+ (void)changeInfoForUser:(User *)user withName:(NSString *)name username:(NSString *)username email:(NSString *)email completion:(PFBooleanResultBlock)completion;

+ (void)changePfpForUser:(User *)user withPfp:(UIImage *)pfp completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
