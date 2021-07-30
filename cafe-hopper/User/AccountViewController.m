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
#import <UserNotifications/UserNotifications.h>

@interface AccountViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pfpView;
@property (weak, nonatomic) IBOutlet UIButton *changePfpButton;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIMenu *sourcePicker;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *minPerStopField;

@property (weak, nonatomic) IBOutlet UISwitch *notifSwitch;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configButton];
    [self configView];
    [self setupSourcePicker];
}

- (void)configView {
    self.user = [User currentUser];
    self.nameLabel.text = self.user.name;
    self.usernameLabel.text = [@"@" stringByAppendingString:self.user.username];

    self.pfpView.layer.cornerRadius = self.pfpView.frame.size.height/2;
    if (self.user.pfp) {
        PFFileObject *pfp = self.user.pfp;
        [pfp getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (data) {
                UIImage *pfpImg = [UIImage imageWithData:data];
                self.pfpView.alpha = 0;
                [self.pfpView setImage:pfpImg];
                [UIView animateWithDuration:0.2 animations:^{
                    self.pfpView.alpha = 1;
                }];
            } else {
                NSLog(@"Error getting pfp: %@", error.localizedDescription);
                [self.pfpView setImage:[UIImage systemImageNamed:@"person.fill"]];
            }
        }];
    } else {
        [self.pfpView setImage:[UIImage systemImageNamed:@"person.fill"]];
    }
    
    self.changePfpButton.hidden = YES;
    self.changePfpButton.showsMenuAsPrimaryAction = YES;
    
    // lock text fields
    [self.nameField setUserInteractionEnabled:NO];
    [self.usernameField setUserInteractionEnabled:NO];
    [self.emailField setUserInteractionEnabled:NO];
    [self.minPerStopField setUserInteractionEnabled:NO];
    
    self.nameField.text = self.user.name;
    self.usernameField.text = self.user.username;
    self.emailField.text = self.user.email;
    self.minPerStopField.text = [NSString stringWithFormat:@"%@", self.user.timePerStop];

    self.nameField.textColor = UIColor.lightGrayColor;
    self.usernameField.textColor = UIColor.lightGrayColor;
    self.emailField.textColor = UIColor.lightGrayColor;
    self.minPerStopField.textColor = UIColor.lightGrayColor;

    [self.notifSwitch setOn:self.user.notifsOn];
    
    self.signoutButton.layer.cornerRadius = 5;
    self.signoutButton.clipsToBounds = true;
}

- (void)configButton {
    // width of cancel button is 75
    self.cancelButton.hidden = YES;
    self.cancelButton.layer.cornerRadius = 5;
    self.cancelButton.clipsToBounds = true;
    self.cancelButton.layer.backgroundColor = UIColor.clearColor.CGColor;
    self.cancelButton.layer.borderColor = [UIColor colorNamed:@"MaximumRed"].CGColor;
    self.cancelButton.layer.borderWidth = 0.5f;
    
    self.editButton.layer.cornerRadius = 5;
    self.editButton.clipsToBounds = true;
    self.editButton.layer.backgroundColor = UIColor.clearColor.CGColor;
    self.editButton.layer.borderColor = UIColor.darkGrayColor.CGColor;
    self.editButton.layer.borderWidth = 0.5f;
    
    // set up regular view
    [self.editButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    [self.editButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    
    // set up view while editing
    [self.editButton setTitle:@"Save Changes" forState:UIControlStateSelected];
    [self.editButton setTitleColor:[UIColor colorNamed:@"PakistanGreen"] forState:UIControlStateSelected];
}

- (IBAction)onTapEditProfile:(id)sender {
    if (self.editButton.isSelected) { // done with editing, save info
        // check for valid/duplicate username (& valid email?)
        if (![self fieldsFilled]) {
            [self presentChangeUsernameErrorAlertWithTitle:@"Invalid Entry" message:@"Username cannot be blank."];
        } else if (![self isUniqueUsername]) {
            [self presentChangeUsernameErrorAlertWithTitle:@"Cannot Change Username" message:@"The username you entered is already taken."];
        } else {
            [self.editButton setSelected:NO];
            self.editButton.layer.borderColor = UIColor.darkGrayColor.CGColor;
            [UIView animateWithDuration:0.1 animations:^{
                self.cancelButton.alpha = 0;
            }];
            self.cancelButton.hidden = YES;
            self.changePfpButton.hidden = YES;
            
            // lock text fields
            [self.nameField setUserInteractionEnabled:NO];
            [self.usernameField setUserInteractionEnabled:NO];
            [self.emailField setUserInteractionEnabled:NO];
            [self.minPerStopField setUserInteractionEnabled:NO];
            self.nameField.textColor = UIColor.lightGrayColor;
            self.usernameField.textColor = UIColor.lightGrayColor;
            self.emailField.textColor = UIColor.lightGrayColor;
            self.minPerStopField.textColor = UIColor.lightGrayColor;
            
            __weak typeof(self) weakSelf = self;
            [self.user changeInfoWithName:self.nameField.text username:self.usernameField.text email:self.emailField.text completion:^(BOOL succeeded, NSError * _Nullable error) {
                __typeof__(self) strongSelf = weakSelf;
                if (strongSelf == nil) {
                    return;
                }
                if (succeeded) {
                    NSLog(@"Successfully saved user info.");
                    strongSelf.nameLabel.text = strongSelf.user.name;
                    strongSelf.usernameLabel.text = [@"@" stringByAppendingString:strongSelf.user.username];
                } else {
                    NSLog(@"Could not save info: %@", error.localizedDescription);
                }
            }];
        }
    } else { // begin editing
        [self.editButton setSelected:YES];
        self.editButton.layer.borderColor = [UIColor colorNamed:@"PakistanGreen"].CGColor;
        self.cancelButton.alpha = 0;
        self.cancelButton.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            self.cancelButton.alpha = 1;
        }];
        self.changePfpButton.hidden = NO;
        
        // unlock text fields
        [self.nameField setUserInteractionEnabled:YES];
        [self.usernameField setUserInteractionEnabled:YES];
        [self.emailField setUserInteractionEnabled:YES];
        [self.minPerStopField setUserInteractionEnabled:YES];
        self.nameField.textColor = UIColor.labelColor;
        self.usernameField.textColor = UIColor.labelColor;
        self.emailField.textColor = UIColor.labelColor;
        self.minPerStopField.textColor = UIColor.labelColor;
    }
}

- (IBAction)onTapCancel:(id)sender {
    [self.editButton setSelected:NO];
    self.editButton.layer.borderColor = UIColor.darkGrayColor.CGColor;
    [UIView animateWithDuration:0.1 animations:^{
        self.cancelButton.alpha = 0;
    }];
    self.cancelButton.hidden = YES;
    self.changePfpButton.hidden = YES;
    
    // lock text fields
    [self.nameField setUserInteractionEnabled:NO];
    [self.usernameField setUserInteractionEnabled:NO];
    [self.emailField setUserInteractionEnabled:NO];
    [self.minPerStopField setUserInteractionEnabled:NO];
    self.nameField.textColor = UIColor.lightGrayColor;
    self.usernameField.textColor = UIColor.lightGrayColor;
    self.emailField.textColor = UIColor.lightGrayColor;
    self.minPerStopField.textColor = UIColor.lightGrayColor;
}

- (BOOL)fieldsFilled {
    if ([self.usernameField.text isEqual:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)isUniqueUsername {
    if ([self.usernameField.text isEqualToString:self.user.username]) {
        return YES; // username wasn't changed
    }
    PFQuery *userQuery = [User query];
    [userQuery whereKey:@"username" equalTo:self.usernameField.text];
    NSArray *matchingUsers = [userQuery findObjects];
    if (matchingUsers.count > 0) {
        return NO;
    }
    return YES;
}

- (void)presentChangeUsernameErrorAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)setupSourcePicker {
    self.imagePicker = [UIImagePickerController new];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = true;
    
    UIAction *pickCamera = [UIAction actionWithTitle:@"Take picture" image:[UIImage systemImageNamed:@"camera"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Camera unavailable; option disabled");
        [pickCamera setAttributes:UIMenuElementAttributesDisabled];
    }
    UIAction *pickLibrary = [UIAction actionWithTitle:@"Select picture" image:[UIImage systemImageNamed:@"photo.on.rectangle"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    UIAction *deletePhoto = [UIAction actionWithTitle:@"Remove picture" image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self.pfpView setImage:[UIImage systemImageNamed:@"person.fill"]];
    }];
    [deletePhoto setAttributes:UIMenuElementAttributesDestructive];
    
    self.sourcePicker = [UIMenu menuWithTitle:@"Choose a source:" children:@[pickCamera, pickLibrary, deletePhoto]];
    [self.changePfpButton setMenu:self.sourcePicker];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    CGSize size = CGSizeMake(300, 300);
    UIImage *pfp = [self resizeImage:editedImage withSize:size];
    [self.pfpView setImage:pfp];
    [self.user changePfpWithPfp:pfp completion:^(BOOL succeeded, NSError * _Nullable error) {}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)onToggleNotifications:(id)sender {
    if (self.notifSwitch.on) {
        // request notifications permission
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
                self.user.notifsOn = [NSNumber numberWithBool:YES];
                [self.user saveInBackground];
                NSLog(@"Turned on user notifications!");
            }
            if (error) {
                NSLog(@"Error requesting notification authorization");
                [self.notifSwitch setOn:NO animated:YES];
            }
        }];
    } else { // turn off notifications
        self.user.notifsOn = [NSNumber numberWithBool:NO];
        [self.user saveInBackground];
    }
}

- (IBAction)onLogout:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout Confirmation" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
