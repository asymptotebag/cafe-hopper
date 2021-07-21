//
//  NewTripViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/19/21.
//

#import "NewTripViewController.h"
#import "Trip.h"

@interface NewTripViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tripNameField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *stops;

@end

@implementation NewTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stops = [NSMutableArray new];
}

- (IBAction)onTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)onTapCreate:(id)sender { // save trip to parse
    [Trip createTripWithName:self.tripNameField.text stops:self.stops completion:^(BOOL succeeded, NSError * _Nullable error) {}];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
