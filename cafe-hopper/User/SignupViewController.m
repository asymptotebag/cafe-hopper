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

- (BOOL)fieldsFilled {
    if ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)isUniqueUsername {
    PFQuery *userQuery = [User query];
    [userQuery whereKey:@"username" equalTo:self.usernameField.text];
    NSArray *matchingUsers = [userQuery findObjects];
    if (matchingUsers.count > 0) {
        return NO;
    }
    return YES;
}

- (void)presentSignupErrorAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)configView {
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.clipsToBounds = true;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)tapSignup:(id)sender {
    if (![self fieldsFilled]) {
        [self presentSignupErrorAlertWithTitle:@"Invalid Entry" message:@"Username and password field cannot be blank."];
    } else if (![self isUniqueUsername]) {
        [self presentSignupErrorAlertWithTitle:@"Cannot Create Account" message:@"The username you entered is already taken."];
    } else {
        // initialize user object
        User *newUser = [User user];
        newUser.name = self.nameField.text;
        newUser.email = self.emailField.text;
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;
        newUser.pfp = nil;
        newUser.timePerStop = @20;
        newUser.notifsOn = [NSNumber numberWithBool:NO];
        newUser.searchHistory = [NSMutableArray new];
        
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

@end
