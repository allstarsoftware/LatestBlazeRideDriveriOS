//
//  LoginVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "JVFloatLabeledTextField.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface LoginVC : BaseVC <UITextFieldDelegate>

- (IBAction)onClickSignIn:(id)sender;
- (IBAction)googleBtnPressed:(id)sender;
- (IBAction)facebookBtnPressed:(id)sender;
- (IBAction)forgotBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtEmail;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtPassword;
@property(nonatomic,weak)IBOutlet UIScrollView *scrLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPsw;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;


@end
