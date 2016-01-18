//
//  ChangeUsernameViewController.h
//  SternFit
//
//  Created by Adam on 1/30/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeUsernameViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UITextField *txtUsername;
@property (nonatomic, strong) IBOutlet UITextField *txtPassword;
@property (nonatomic, strong) IBOutlet UITextField *txtNewPassword;
@property (nonatomic, strong) IBOutlet UITextField *txtNewPasswordAgain;
@property (nonatomic, strong) IBOutlet UIView *viewUsername;
@property (nonatomic, strong) IBOutlet UIView *viewPassword;
@property (nonatomic, strong) IBOutlet UIView *viewAlert;
@property (nonatomic, strong) IBOutlet UILabel *labelAlert;
@property (nonatomic, strong) IBOutlet UIView *viewGroupName;
@property (nonatomic, strong) IBOutlet UITextField *txtGroupName;
@property (nonatomic, strong) IBOutlet UIImageView *imgUsername;
@property (nonatomic, strong) IBOutlet UIImageView *imgPassword;
@property (nonatomic, strong) IBOutlet UIImageView *imgNewPassword;
@property (nonatomic, strong) IBOutlet UIImageView *imgNewPasswordAgain;
@property (nonatomic, strong) IBOutlet UIView *viewFeedback;
@property (nonatomic, strong) IBOutlet UITextView *txtFeedback;
@property (nonatomic, strong) IBOutlet UILabel *labelFeedback;


@property (nonatomic) int isUsernameChange;

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnSaveUsernameClicked:(id)sender;
- (IBAction)btnSavePasswordClicked:(id)sender;
- (IBAction)btnSaveGroupNameClicked:(id)sender;
- (IBAction)btnFeedbacksendClicked:(id)sender;

@end
