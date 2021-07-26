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

    self.backdropView.layer.cornerRadius = 12;
    self.backdropView.layer.masksToBounds = true;
    self.shadowView.layer.cornerRadius = 12;
    self.shadowView.layer.masksToBounds = true;
    
    [self.reviewTextView setTextContainerInset:UIEdgeInsetsZero];
    self.reviewTextView.textContainer.lineFragmentPadding = 0;
}

- (void)setReview:(NSDictionary *)review {
    _review = review;
    
    self.nameLabel.text = review[@"author_name"];
    self.ratingLabel.text = [[NSString stringWithFormat:@"%@", review[@"rating"]] stringByAppendingString:@"/5"];
    NSInteger rating = [review[@"rating"] integerValue];
    if (rating >= 4) {
        [self.ratingLabel setTextColor:[UIColor colorNamed:@"PakistanGreen"]];
    } else if (rating == 3) {
        [self.ratingLabel setTextColor:[UIColor colorNamed:@"MaizeCrayola"]];
    } else {
        [self.ratingLabel setTextColor:[UIColor colorNamed:@"MaximumRed"]];
    }
    
    self.timestampLabel.text = review[@"relative_time_description"];
    self.reviewTextView.text = review[@"text"];
}

@end
