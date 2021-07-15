//
//  SignupViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "SignupViewController.h"
#import "User.h"
#import "Collection.h"
#import <Parse/Parse.h>

@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *haveAcc;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (BOOL)fieldsFilled { // TODO: need to check for duplicate usernames
    if ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Entry" message:@"Username and password field cannot be blank." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:^{}];
        return NO;
    }
    return YES;
}

- (void)configView {
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.clipsToBounds = true;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)tapSignup:(id)sender {
    if ([self fieldsFilled]) {
        // initialize user object
        User *newUser = [User user];
        newUser.name = self.nameField.text;
        newUser.email = self.emailField.text;
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;

//        NSMutableArray *all = [NSMutableArray new];
//        NSMutableArray *favorites = [NSMutableArray new];
//        NSMutableArray *wantToVisit = [NSMutableArray new];
//        newUser.collections = [[NSMutableArray alloc] initWithObjects:all, favorites, wantToVisit, nil];
//        NSMutableDictionary *collections = @{
//            @"All":all,
//            @"Favorites":favorites,
//            @"Want to Visit":wantToVisit
//        }.mutableCopy;
//        newUser.collections = collections;
        
//        newUser.trips = [NSMutableArray new];
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Signup error: %@", error.localizedDescription);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Signup Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:dismissAction];
                [self presentViewController:alert animated:YES completion:^{}];
            } else { // transition screen
                NSLog(@"%@ registered successfully", newUser.username);
                [Collection createCollectionWithName:@"All" completion:^(BOOL succeeded, NSError * _Nullable error){}];
                [Collection createCollectionWithName:@"Favorites" completion:^(BOOL succeeded, NSError * _Nullable error){}];
                [Collection createCollectionWithName:@"Want to Visit" completion:^(BOOL succeeded, NSError * _Nullable error){}];
                [self performSegueWithIdentifier:@"signupSegue" sender:nil];
            }
        }];
    }
}

- (IBAction)tapLoginInstead:(id)sender {
    [self performSegueWithIdentifier:@"toLoginSegue" sender:nil];
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
