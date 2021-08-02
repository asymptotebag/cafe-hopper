//
//  LoginViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "LoginViewController.h"
#import "User.h"
#import <Parse/Parse.h>
#import "NSString+EmailValidation.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAcc;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (BOOL)fieldsFilled {
    if ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
        NSLog(@"Error: One or more fields is blank");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Entry" message:@"Username and password field cannot be blank." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:^{}];
        return NO;
    }
    return YES;
}

- (void)configView {
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.clipsToBounds = true;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)tapLogin:(id)sender {
    if ([self fieldsFilled]) {
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        
        // check if username field contains an email
        if ([username isValidEmail]) { // try to log in with email
            PFQuery *query = [User query];
            [query whereKey:@"email" equalTo:username];
            User *correspondingUser = [query getFirstObject];
            if (correspondingUser) {
                [User logInWithUsernameInBackground:correspondingUser.username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                    if (error) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                        [alert addAction:dismissAction];
                        [self presentViewController:alert animated:YES completion:^{}];
                    } else {
                        NSLog(@"%@ logged in successfully", user.username);
                        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                    }
                }];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Error" message:@"The email you entered is not associated with an account." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:dismissAction];
                [self presentViewController:alert animated:YES completion:^{}];
            }
        } else {
            [User logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                if (error) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                    [alert addAction:dismissAction];
                    [self presentViewController:alert animated:YES completion:^{}];
                } else {
                    NSLog(@"%@ logged in successfully", user.username);
                    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                }
            }];
        }
    }
}

- (IBAction)tapCreateAcc:(id)sender {
    [self performSegueWithIdentifier:@"toSignupSegue" sender:nil];
}

@end
