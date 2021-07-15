//
//  CollectionCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "CollectionCell.h"

@implementation CollectionCell

- (void)setCollection:(Collection *)collection {
    _collection = collection;
    self.nameLabel.text = collection.collectionName;
    self.frameView.layer.cornerRadius = 15;
    self.frameView.clipsToBounds = YES;
    [self.topLeftView setImage:[UIImage imageNamed:@"1"]];
    [self.topRightView setImage:[UIImage imageNamed:@"2"]];
    [self.bottomLeftView setImage:[UIImage imageNamed:@"3"]];
    [self.bottomRightView setImage:[UIImage imageNamed:@"4"]];
}

@end
