//
//  ChangeUsernameViewController.m
//  SternFit
//
//  Created by Adam on 1/30/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import "ChangeUsernameViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface ChangeUsernameViewController () {
    NSUserDefaults *defaults;
    AppDelegate *appDelegate;
    
    UIImage *usernameDefault, *usernameInvalid, *usernameValid, *passwordDefault, *passwordValid, *passwordInvalid;
}

@end

@implementation ChangeUsernameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    usernameInvalid = [UIImage imageNamed:@"account_user_invalid.png"];
    usernameValid = [UIImage imageNamed:@"account_user_valid.png"];
    passwordValid = [UIImage imageNamed:@"account_password_valid.png"];
    passwordInvalid = [UIImage imageNamed:@"account_password_invalid.png"];
    usernameDefault = [UIImage imageNamed:@"account_user.png"];
    passwordDefault = [UIImage imageNamed:@"account_password.png"];
    
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if (self.isUsernameChange == 1) {
        self.viewUsername.hidden = NO;
        self.viewPassword.hidden = YES;
        self.txtUsername.text = [defaults objectForKey:@"name"];
        self.txtUsername.textColor = [UIColor blackColor];
        self.labelTitle.text = NSLocalizedString(@"Change Username", nil);
    } else if (self.isUsernameChange == 0) {
        self.viewUsername.hidden = YES;
        self.viewPassword.hidden = NO;
        self.txtPassword.text = NSLocalizedString(@"Password", nil);
        self.txtNewPassword.text = NSLocalizedString(@"New Password", nil);
        self.txtNewPasswordAgain.text = NSLocalizedString(@"New Password, again", nil);
        self.labelTitle.text = NSLocalizedString(@"Change Password", nil);
        self.txtPassword.secureTextEntry = NO;
        self.txtNewPassword.secureTextEntry = NO;
        self.txtNewPasswordAgain.secureTextEntry = NO;
    } else if (self.isUsernameChange == 2) {
        self.viewUsername.hidden = YES;
        self.viewPassword.hidden = YES;
        self.viewGroupName.hidden = NO;
        if (![[appDelegate.groupInfo objectForKey:@"name"] isEqual:@"Group"]) {
            self.txtGroupName.text = [appDelegate.groupInfo objectForKey:@"name"];
            self.txtGroupName.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        } else {
            self.txtGroupName.text = NSLocalizedString(@"Group name", nil);
            self.txtGroupName.textColor = [UIColor blackColor];
        }
        self.labelTitle.text = NSLocalizedString(@"Change Group name", nil);
        
        self.txtGroupName.layer.cornerRadius = 3.0f;
    } else if (self.isUsernameChange == 3) { // feedback
        self.viewUsername.hidden = YES;
        self.viewPassword.hidden = YES;
        self.viewGroupName.hidden = YES;
        self.viewFeedback.hidden = NO;
        self.labelTitle.text = NSLocalizedString(@"Feedback", nil);
        
        self.labelFeedback.layer.cornerRadius = 2;
        self.labelFeedback.layer.masksToBounds = YES;
        
        self.txtFeedback.text = NSLocalizedString(@"Enter feedback here", nil);
    }
    
    self.viewAlert.hidden = YES;
    
    //self.labelTitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.0f];
    self.labelAlert.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.txtUsername) {
        if ([textField.text isEqual:NSLocalizedString(@"Username", nil)]) {
            textField.text = @"";
        }
    }
    if (textField == self.txtPassword) {
        if ([textField.text isEqual:NSLocalizedString(@"Password", nil)]) {
            textField.text = @"";
        }
        textField.secureTextEntry = NO;
    }
    if (textField == self.txtNewPasswordAgain) {
        if ([textField.text isEqual:NSLocalizedString(@"New Password, again", nil)]) {
            textField.text = @"";
        }
        textField.secureTextEntry = NO;
    }
    if (textField == self.txtNewPassword) {
        if ([textField.text isEqual:NSLocalizedString(@"New Password", nil)]) {
            textField.text = @"";
        }
        textField.secureTextEntry = NO;
    }
    
    if (textField == self.txtGroupName) {
        if ([textField.text isEqual:NSLocalizedString(@"Group name", nil)]) {
            textField.text = @"";
        }
        textField.textColor = [UIColor blackColor];
    }
    
    textField.textColor = [UIColor blackColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.txtUsername) {
        if ([textField.text isEqual:@""]) {
            self.txtUsername.text = NSLocalizedString(@"Username", nil);
            textField.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
            [self.imgUsername setImage:usernameDefault];
        }
    }
    if (textField == self.txtGroupName) {
        if ([textField.text isEqual:@""]) {
            self.txtGroupName.text = NSLocalizedString(@"Group name", nil);
            textField.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        }
    }
    if (textField == self.txtPassword) {
        if ([textField.text isEqual:@""]) {
            textField.text = NSLocalizedString(@"Password", nil);
            textField.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
            textField.secureTextEntry = NO;
            [self.imgPassword setImage:passwordInvalid];
            [self shakeControl:self.imgPassword txtField:self.txtPassword];
        } else {
            textField.secureTextEntry = YES;
            /*if ([textField.text length] < 6)
            {
                [self.imgPassword setImage:passwordInvalid];
                [self shakeControl:self.imgPassword txtField:self.txtPassword];
            } else {
                [self.imgPassword setImage:passwordValid];
            }*/
        }
    }
    if (textField == self.txtNewPasswordAgain) {
        if ([textField.text isEqual:@""]) {
            textField.text = NSLocalizedString(@"New Password, again", nil);
            textField.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
            textField.secureTextEntry = NO;
            [self.imgNewPasswordAgain setImage:passwordInvalid];
            [self shakeControl:self.imgNewPasswordAgain txtField:self.txtNewPasswordAgain];
        } else {
            textField.secureTextEntry = YES;
            if ([textField.text length] < 6)
            {
                [self.imgNewPasswordAgain setImage:passwordInvalid];
                [self shakeControl:self.imgNewPasswordAgain txtField:self.txtNewPasswordAgain];
            } else {
                [self.imgNewPasswordAgain setImage:passwordValid];
            }
        }
    }
    if (textField == self.txtNewPassword) {
        if ([textField.text isEqual:@""]) {
            textField.text = NSLocalizedString(@"New Password", nil);
            textField.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
            textField.secureTextEntry = NO;
            [self.imgNewPassword setImage:passwordInvalid];
            [self shakeControl:self.imgNewPassword txtField:self.txtNewPassword];
        } else {
            textField.secureTextEntry = YES;
            if ([textField.text length] < 6)
            {
                [self.imgNewPassword setImage:passwordInvalid];
                [self shakeControl:self.imgNewPassword txtField:self.txtNewPassword];
            } else {
                [self.imgNewPassword setImage:passwordValid];
            }
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.txtPassword) {
        [self.txtNewPassword becomeFirstResponder];
    } else if (textField == self.txtNewPassword) {
        [self.txtNewPasswordAgain becomeFirstResponder];
    }
    
    
    return YES;
}

- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnSaveUsernameClicked:(id)sender {
    [self.txtUsername resignFirstResponder];
    
    if ([self.txtUsername.text isEqual:@""] || [self.txtUsername.text isEqual:NSLocalizedString(@"Username", nil)]) {
        /*self.labelAlert.text = NSLocalizedString(@"Please type username", nil);
        self.viewAlert.hidden = NO;*/
        [self.imgUsername setImage:usernameInvalid];
        [self shakeControl:self.imgUsername txtField:self.txtUsername];
        return;
    }
    
    if ([self checkValid:self.txtUsername.text] == NO) {
        /*self.labelAlert.text = NSLocalizedString(@"Usernames can only use letters, numbers, and underscores.", nil);
        self.viewAlert.hidden = NO;*/
        [self.imgUsername setImage:usernameInvalid];
        [self shakeControl:self.imgUsername txtField:self.txtUsername];
        return;
    }
    
    if ([self.txtUsername.text length] > 30) {
        /*self.labelAlert.text = NSLocalizedString(@"Ensure the username has at most 30 characters.", nil);
        self.viewAlert.hidden = NO;*/
        [self.imgUsername setImage:usernameInvalid];
        [self shakeControl:self.imgUsername txtField:self.txtUsername];
        return;
    }
    
    
    
    [self showProgress:YES];
    
    NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?type=0&ID=%@&value=%@", SERVER_ADDRESS, CHANGE_USER_CREDENTIAL, [defaults objectForKey:@"userID"], self.txtUsername.text]];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request1 setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self showProgress:NO];
                               
                               NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                               
                               if ([[result objectForKey:@"status"] isEqual:@"success"]) {
                                   self.labelAlert.text = NSLocalizedString(@"You have successfully changed your username!", nil);
                                   self.viewAlert.hidden = NO;
                                   
                                   [defaults setObject:self.txtUsername.text forKey:@"name"];
                                   
                                   [defaults synchronize];
                               } else {
                                   self.labelAlert.text = [NSLocalizedString(@"Username XXX is not available.", nil) stringByReplacingOccurrencesOfString:@"XXX" withString:self.txtUsername.text];
                                   self.viewAlert.hidden = NO;
                                   
                                   [self.imgUsername setImage:usernameInvalid];
                                   [self shakeControl:self.imgUsername txtField:self.txtUsername];
                               }
                           }];
    
}
- (IBAction)btnSavePasswordClicked:(id)sender {
    [self.txtPassword resignFirstResponder];
    [self.txtNewPasswordAgain resignFirstResponder];
    [self.txtNewPassword resignFirstResponder];
    
    NSString *password = self.txtPassword.text;
    NSString *newPassword = self.txtNewPassword.text;
    
    if ([password isEqual:@""] || [password isEqual:NSLocalizedString(@"Password", nil)]) {
        [self.imgPassword setImage:passwordInvalid];
        [self shakeControl:self.imgPassword txtField:self.txtPassword];
        return;
    }
    if ([newPassword isEqual:@""] || [newPassword isEqual:NSLocalizedString(@"New Password", nil)]) {
        [self.imgNewPassword setImage:passwordInvalid];
        [self shakeControl:self.imgNewPassword txtField:self.txtNewPassword];
        return;
    }
    if ([self.txtNewPasswordAgain.text isEqual:@""] || [self.txtNewPasswordAgain.text isEqual:NSLocalizedString(@"New Password, again", nil)]) {
        [self.imgNewPasswordAgain setImage:passwordInvalid];
        [self shakeControl:self.imgNewPasswordAgain txtField:self.txtNewPasswordAgain];
        return;
    }
    
    if (![newPassword isEqual:self.txtNewPasswordAgain.text]) {
        /*self.labelAlert.text = NSLocalizedString(@"New password doesn't match. Please type it again!", nil);
        self.viewAlert.hidden = NO;*/
        [self.imgNewPassword setImage:passwordInvalid];
        [self shakeControl:self.imgNewPassword txtField:self.txtNewPassword];
        [self.imgNewPasswordAgain setImage:passwordInvalid];
        [self shakeControl:self.imgNewPasswordAgain txtField:self.txtNewPasswordAgain];
        return;
    }
    
    if ([self checkValid:newPassword] == NO) {
        self.labelAlert.text = NSLocalizedString(@"Password can only use letters, numbers, and underscores.", nil);
        self.viewAlert.hidden = NO;
        return;
    }
    
    if ([newPassword length] > 30) {
        self.labelAlert.text = NSLocalizedString(@"Ensure the password has at most 30 characters.", nil);
        self.viewAlert.hidden = NO;
        return;
    }
    
    [self showProgress:YES];
    NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?type=1&username=%@&password=%@&newPassword=%@", SERVER_ADDRESS, CHANGE_PASSWORD, [defaults objectForKey:@"name"], password, newPassword]];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request1 setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self showProgress:NO];
                               
                               NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                               
                               if ([[result objectForKey:@"status"] isEqual:@"success"]) {
                                   [defaults setObject:newPassword forKey:@"password"];
                                   [defaults synchronize];
                                   
                                   self.labelAlert.text = NSLocalizedString(@"You have successfully changed your password!", nil);
                                   self.viewAlert.hidden = NO;
                               } else {
                                   /*self.labelAlert.text = NSLocalizedString(@"Current password is incorrect.", nil);
                                   self.viewAlert.hidden = NO;
                                   */
                                   [self.imgPassword setImage:passwordInvalid];
                                   [self shakeControl:self.imgPassword txtField:self.txtPassword];
                               }
                           }];
}

- (BOOL) checkValid:(NSString *) string {
    NSMutableArray *validValues = (NSMutableArray*) [@"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,1,2,3,4,5,6,7,8,9,_" componentsSeparatedByString:@","];
    NSString *temp;
    BOOL ret = NO;
    for (int j = 0; j < [string length] - 1; j++) {
        temp = [string substringWithRange:NSMakeRange(j, 1)];
        ret = NO;
        for (int i = 0; i < [validValues count]; i++) {
            if ([[validValues objectAtIndex:i] isEqual:temp])
            {
                ret = YES;
                break;
            }
        }
        
        if (ret == NO)
            return NO;
    }
    
    return YES;
}

- (BOOL) checkValidSeperate:(NSString *) string {
    NSMutableArray *validValues = (NSMutableArray*) [@"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,1,2,3,4,5,6,7,8,9,_" componentsSeparatedByString:@","];
    
    for (int i = 0; i < [validValues count]; i++) {
        if ([[validValues objectAtIndex:i] isEqual:string])
            return YES;
    }
    return NO;
}

- (void) showProgress:(BOOL) flag {
    if (flag) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:true];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqual:@""]) {
        self.viewAlert.hidden = YES;
        return YES;
    }
    if (textField == self.txtUsername) {
        if ([textField.text length] >= 29) {
            //self.labelAlert.text = NSLocalizedString(@"Ensure the username has at most 30 characters.", nil);
            //self.viewAlert.hidden = NO;
            [self.imgUsername setImage:usernameInvalid];
            [self shakeControl:self.imgUsername txtField:self.txtUsername];
            return NO;
        }
        
        if ([self checkValidSeperate:string] == YES) {
            self.viewAlert.hidden = YES;
            [self.imgUsername setImage:usernameDefault];
            return YES;
        } else {
            //self.labelAlert.text = NSLocalizedString(@"Usernames can only use letters, numbers, and underscores.", nil);
            //self.viewAlert.hidden = NO;
            [self.imgUsername setImage:usernameInvalid];
            [self shakeControl:self.imgUsername txtField:self.txtUsername];
            
            return NO;
        }
    }
    
    if (textField == self.txtPassword || textField == self.txtNewPassword || textField == self.txtNewPasswordAgain) {
        if ([textField.text length] >= 29) {
            if (textField == self.txtPassword) {
                [self.imgPassword setImage:passwordDefault];
                [self shakeControl:self.imgPassword txtField:self.txtPassword];
            } else if (textField == self.txtNewPassword) {
                [self.imgNewPassword setImage:passwordDefault];
                [self shakeControl:self.imgNewPassword txtField:self.txtNewPassword];
            } else if (textField == self.txtNewPasswordAgain) {
                [self.imgNewPasswordAgain setImage:passwordDefault];
                [self shakeControl:self.imgNewPasswordAgain txtField:self.txtNewPasswordAgain];
            }
            
            return NO;
        }
    }
    
    if (textField == self.txtGroupName) {
        if ([textField.text length] > 20) {
            return NO;
        }
    }
    return YES;
}

- (void) shakeControl:(UIImageView *) imageView txtField:(UITextField*) txtField {
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = imageView.frame;
                         frame.origin.x += 10.0f;
                         imageView.frame = frame;
                         
                         CGRect frame1 = txtField.frame;
                         frame1.origin.x += 10.0f;
                         txtField.frame = frame1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGRect frame = imageView.frame;
                                              frame.origin.x -= 10.0f;
                                              imageView.frame = frame;
                                              
                                              CGRect frame1 = txtField.frame;
                                              frame1.origin.x -= 10.0f;
                                              txtField.frame = frame1;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.1f
                                                                    delay:0.0f
                                                                  options:UIViewAnimationOptionCurveEaseIn
                                                               animations:^{
                                                                   CGRect frame = imageView.frame;
                                                                   frame.origin.x += 10.0f;
                                                                   imageView.frame = frame;
                                                                   
                                                                   CGRect frame1 = txtField.frame;
                                                                   frame1.origin.x += 10.0f;
                                                                   txtField.frame = frame1;
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.1f
                                                                                         delay:0.0f
                                                                                       options:UIViewAnimationOptionCurveEaseIn
                                                                                    animations:^{
                                                                                        CGRect frame = imageView.frame;
                                                                                        frame.origin.x -= 10.0f;
                                                                                        imageView.frame = frame;
                                                                                        
                                                                                        CGRect frame1 = txtField.frame;
                                                                                        frame1.origin.x -= 10.0f;
                                                                                        txtField.frame = frame1;
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        
                                                                                    }];
                                                               }];
                                          }];
                     }];
}

- (IBAction)btnSaveGroupNameClicked:(id)sender {
    if ([self.txtGroupName.text isEqual:@""] || [self.txtGroupName.text isEqual:NSLocalizedString(@"Group name", nil)]) {
        self.labelAlert.text = NSLocalizedString(@"Please type the group name.", nil);
        self.viewAlert.hidden = NO;
    } else {
        [self showProgress:YES];
        
        NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?ID=%@&name=%@&mute=%@&cID=%@", SERVER_ADDRESS, CHANGE_GROUP_CHAT_OPTIONS, [defaults objectForKey:@"userID"], [self.txtGroupName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [appDelegate.groupInfo objectForKey:@"mute"], [appDelegate.groupInfo objectForKey:@"ID"]]];
        NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
        
        [request1 setHTTPMethod:@"POST"];
        
        [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
         
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   [self showProgress:NO];
                                   
                                   [appDelegate.groupInfo setObject:self.txtGroupName.text forKey:@"name"];
                                   [self.navigationController popViewControllerAnimated:YES];
                               }];
    }
}


- (IBAction)btnFeedbacksendClicked:(id)sender {
    [self showProgress:YES];
    
    NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?username=%@&email=%@&content=%@", SERVER_ADDRESS, SEND_FEEDBACK, [defaults objectForKey:@"name"], [defaults objectForKey:@"email"], [self.txtFeedback.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request1 setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self showProgress:NO];
                               
                               [self.navigationController popViewControllerAnimated:YES];
                           }];
}

#pragma - mark TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqual:NSLocalizedString(@"Enter feedback here", nil)])
        textView.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@""]) {
        textView.text = NSLocalizedString(@"Enter feedback here", nil);
    }
}


- (BOOL)textViewShouldReturn:(UITextField *)textField
{
    [self.txtFeedback resignFirstResponder];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@""]) {
        int length = 300 - (int)self.txtFeedback.text.length + 1;
        self.labelFeedback.text = [NSString stringWithFormat:@"%d", length];
        
        return YES;
    } else if ([text isEqual:@"\n"]) {
        [self.txtFeedback resignFirstResponder];
        return NO;
    } else if ([textView.text length] == 300) {
        return NO;
    }
    
    int length = 300 - (int)self.txtFeedback.text.length - 1;
    self.labelFeedback.text = [NSString stringWithFormat:@"%d", length];
    
    return YES;
}

@end
