//
//  CollectionCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/14/21.
//

#import "CollectionCell.h"
#import "Collection.h"

@implementation CollectionCell

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setCollection:(Collection *)collection {
    _collection = collection;
    
    self.nameLabel.text = collection.collectionName;
    self.frameView.layer.cornerRadius = 15;
    self.frameView.clipsToBounds = YES;
    [self.topLeftView setImage:[UIImage imageNamed:@"1"]];
    [self.topRightView setImage:[UIImage imageNamed:@"2"]];
    [self.bottomLeftView setImage:[UIImage imageNamed:@"3"]];
    [self.bottomRightView setImage:[UIImage imageNamed:@"4"]];
    
    if (self.inEditingMode && ![self.collection.collectionName isEqualToString:@"All"]) {
        // you can't delete the All collection
        self.deleteButton.hidden = NO;
    } else {
        self.deleteButton.hidden = YES; // hide X when not editing
    }
}

- (IBAction)tapDelete:(id)sender {
    [self.delegate didTapDelete:self]; // handle deletion in delegate method
}


@end
