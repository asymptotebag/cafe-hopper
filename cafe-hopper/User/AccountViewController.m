//
//  AccountViewController.m
//  cafe-hopper
//
//  Created by Emily Jiang on 7/12/21.
//

#import "AccountViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "User.h"
#import <Parse/Parse.h>

@interface AccountViewController ()
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pfpView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (void)configView {
    self.user = [User currentUser];
    self.nameLabel.text = self.user.name;
    self.usernameLabel.text = self.user.username;
    self.emailField.text = self.user.email;
    
    self.signoutButton.layer.cornerRadius = 5;
    self.signoutButton.clipsToBounds = true;
}

- (IBAction)onLogout:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout Confirmation" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self dismissViewControllerAnimated:YES completion:^{}];
        
        [User logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:dismissAction];
                [self presentViewController:alert animated:YES completion:^{}];
            } else {
                SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                sceneDelegate.window.rootViewController = loginController;
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:logoutAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

@end
