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

+ (void)addPlaceId:(NSString *)placeId toCollection:(Collection *)collection withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
