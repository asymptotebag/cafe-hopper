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
}

@end
