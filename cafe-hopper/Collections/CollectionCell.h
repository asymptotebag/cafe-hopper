//
//  CollectionCell.h
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Collection.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CollectionCellDelegate
- (void)didTapDelete:(UICollectionViewCell *)cell;

@end

@interface CollectionCell : UICollectionViewCell
@property (strong, nonatomic) Collection *collection;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *frameView;
@property (weak, nonatomic) IBOutlet UIImageView *topLeftView;
@property (weak, nonatomic) IBOutlet UIImageView *topRightView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLeftView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomRightView;

@property (nonatomic, weak) id<CollectionCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic) BOOL inEditingMode;

@end

NS_ASSUME_NONNULL_END
