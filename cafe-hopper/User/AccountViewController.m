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

@interface AccountViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pfpView;
@property (weak, nonatomic) IBOutlet UIButton *changePfpButton;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIMenu *sourcePicker;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

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
                [self.pfpView setImage:pfpImg];
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

//    [self.notifSwitch setOn:self.user.notifsOn];
    [self.notifSwitch setOn:NO]; // default no for now
    
    self.signoutButton.layer.cornerRadius = 5;
    self.signoutButton.clipsToBounds = true;
}

- (void)configButton {
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
    [self.editButton setTitleColor:UIColor.systemGreenColor forState:UIControlStateSelected];
}

- (IBAction)onTapEditProfile:(id)sender {
    if (self.editButton.isSelected) { // done with editing, save info
        // check for valid/duplicate username (& valid email?)
        if ([self fieldsFilled] && [self uniqueUsername]) {
            [self.editButton setSelected:NO];
            self.editButton.layer.borderColor = UIColor.darkGrayColor.CGColor;
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
            
            [User changeInfoForUser:self.user withName:self.nameField.text username:self.usernameField.text email:self.emailField.text completion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"Successfully saved user info.");
                    self.nameLabel.text = self.user.name;
                    self.usernameLabel.text = [@"@" stringByAppendingString:self.user.username];
                } else {
                    NSLog(@"Could not save info: %@", error.localizedDescription);
                }
            }];
        }
    } else { // begin editing
        [self.editButton setSelected:YES];
        self.editButton.layer.borderColor = UIColor.systemGreenColor.CGColor;
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

- (BOOL)fieldsFilled {
    if ([self.usernameField.text isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Entry" message:@"Username cannot be blank." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:^{}];
        return NO;
    }
    return YES;
}

- (BOOL)uniqueUsername { // check for duplicate usernames
    if ([self.usernameField.text isEqualToString:self.user.username]) {
        return YES; // username wasn't changed
    }
    PFQuery *userQuery = [User query];
    [userQuery whereKey:@"username" equalTo:self.usernameField.text];
    NSArray *matchingUsers = [userQuery findObjects];
    if (matchingUsers.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Change Username" message:@"The username you entered is already taken." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:^{}];
        return NO;
    }
    return YES;
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
    [User changePfpForUser:self.user withPfp:pfp completion:nil];
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
