//
//  ReviewCell.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/26/21.
//

#import "ReviewCell.h"

@implementation ReviewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backdropView.layer.cornerRadius = 10;
    self.backdropView.layer.masksToBounds = true;
    self.shadowView.layer.cornerRadius = 10;
    self.shadowView.layer.masksToBounds = true;
    
    [self.reviewTextView setTextContainerInset:UIEdgeInsetsZero];
    self.reviewTextView.textContainer.lineFragmentPadding = 0;
}

- (void)setReview:(NSDictionary *)review {
    _review = review;
    
    self.nameLabel.text = review[@"author_name"];
    self.ratingLabel.text = [[NSString stringWithFormat:@"%@", review[@"rating"]] stringByAppendingString:@"/5"];
    self.timestampLabel.text = review[@"relative_time_description"];
    self.reviewTextView.text = review[@"text"];
}

@end
