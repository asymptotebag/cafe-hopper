//
//  CollectionViewController.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Collection.h"

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewController : UIViewController
@property (strong, nonatomic) Collection *collection; // the collection this VC shows

@end

NS_ASSUME_NONNULL_END
