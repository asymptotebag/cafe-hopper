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
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *searchHistory;

- (void)addCollectionNamed:(NSString *)collectionName withCompletion:(PFBooleanResultBlock)completion;

- (void)removeCollectionNamed:(NSString *)collectionName withCompletion:(PFBooleanResultBlock)completion;

- (void)addTripNamed:(NSString *)tripName withCompletion:(PFBooleanResultBlock)completion;

- (void)removeTripNamed:(NSString *)tripName withCompletion:(PFBooleanResultBlock)completion;

- (void)changeInfoWithName:(NSString *)name username:(NSString *)username email:(NSString *)email completion:(PFBooleanResultBlock)completion;

- (void)changePfpWithPfp:(UIImage *)pfp completion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
