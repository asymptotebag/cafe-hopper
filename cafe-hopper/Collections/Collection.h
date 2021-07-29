//
//  Collection.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import <Parse/Parse.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Collection : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *collectionName;
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) User *owner;

+ (void)createCollectionWithName:(NSString *)name completion:(PFBooleanResultBlock)completion;

- (void)deleteWithCompletion:(PFBooleanResultBlock)completion;

- (void)addPlaceId:(NSString *)placeId withCompletion:(PFBooleanResultBlock)completion;

- (void)removePlaceId:(NSString *)placeId withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
