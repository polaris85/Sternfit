//
//  SignupViewController.m
//  SternFit
//
//  Created by Adam on 12/9/14.
//  Copyright (c) 2014 com.mobile.sternfit. All rights reserved.
//

#import "SignupViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface SignupViewController () {
    BOOL isRetina;
    NSString *birthday;
    int age;
    BOOL gender;
    NSMutableArray *validValues;
    AppDelegate *appDelegate;
    NSUserDefaults *defaults;
    UIImage *imgUserValid;
    UIImage *imgUserInvalid;
    UIImage *emailValid, *emailInvalid, *passwordValid, *passwordInvalid, *imgUserDefault, *imgEmailDefault, *imgPasswordDefault;
}

@end

@implementation SignupViewController

@synthesize txtEmail, txtPassword, txtUsername, btnCreate, btnTour, scrollView;

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
    // Do any additional setup after loading the view.
    
    imgUserInvalid = [UIImage imageNamed:@"account_user_invalid.png"];
    imgUserValid = [UIImage imageNamed:@"account_user_valid.png"];
    emailValid = [UIImage imageNamed:@"account_email_valid.png"];
    emailInvalid = [UIImage imageNamed:@"account_email_invalid.png"];
    passwordValid = [UIImage imageNamed:@"account_password_valid.png"];
    passwordInvalid = [UIImage imageNamed:@"account_password_invalid.png"];
    imgUserDefault = [UIImage imageNamed:@"account_user.png"];
    imgPasswordDefault = [UIImage imageNamed:@"account_password.png"];
    imgEmailDefault = [UIImage imageNamed:@"account_email.png"];
    
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    defaults = [NSUserDefaults standardUserDefaults];
    
    [btnTour setTitle:NSLocalizedString(@"TAKE A TOUR", nil) forState:UIControlStateNormal];
    [btnCreate setTitle:NSLocalizedString(@"CREATE ACCOUNT", nil) forState:UIControlStateNormal];
    [self.btnDone setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    [self.btnMale setTitle:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"Male", nil)] forState:UIControlStateNormal];
    [self.btnFemale setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Female", nil)] forState:UIControlStateNormal];
    
    gender = NO;
    
    [self changeGender];
    
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 480)
        isRetina = true;
    else
        isRetina = false;
    
    birthday = @"0000-00-00";
    
    UITapGestureRecognizer *tapView1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap1:)];
    tapView1.delegate = self;
    [scrollView addGestureRecognizer:tapView1];
    
    self.labelAlert.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.0f];
    self.viewAlert.hidden = YES;
    
    validValues = (NSMutableArray*) [@"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,1,2,3,4,5,6,7,8,9,_" componentsSeparatedByString:@","];
    
    if (self.email != nil && ![self.email isEqual:@""]) {
        self.txtEmail.text = self.email;
        [self.txtEmail setUserInteractionEnabled:NO];
        if ([self.strGender isEqual:@"male"]) {
            gender = YES;
        } else {
            gender = NO;
        }
        
        [self.btnMale setUserInteractionEnabled:NO];
        [self.btnFemale setUserInteractionEnabled:NO];
        
        self.imgBack.hidden = YES;
        
        [self changeGender];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.viewAlert.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTourClicked:(id)sender {
    [self performSegueWithIdentifier:@"gotoTour" sender:self];
}

- (IBAction)btnCreateClicked:(id)sender {
    NSString *username = txtUsername.text;
    NSString *password = txtPassword.text;
    NSString *email = txtEmail.text;
    if ([username isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Please type username", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([password isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Please type password", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([email isEqual:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Please type email address", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (![self validateEmail:email]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Incorrect email format", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self showProgress:YES];
    int gen = 0;
    if (gender)
        gen = 1;
    NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?username=%@&password=%@&email=%@&birthday=%@&gender=%d&lat=%f&long=%f&height=187&weight=77&deviceToken=%@", SERVER_ADDRESS, REGISTER_USER, username, password, email, birthday, gen, appDelegate.currentLocation.coordinate.latitude, appDelegate.currentLocation.coordinate.longitude, appDelegate.deviceToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               @try {
                                   if (data != nil) {
                                       NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                       
                                       if ([[result objectForKey:@"status"] isEqual:@"fail"]) {
                                           self.labelAlert.text = [result objectForKey:@"response"];
                                           self.viewAlert.hidden = NO;
                                           return;
                                       } else if ([[result objectForKey:@"status"] isEqual:@"success"]){
                                           NSMutableDictionary *res = (NSMutableDictionary*) [result objectForKey:@"response"];
                                           
                                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APPTAG message:[res objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                           [alertView show];
                                           
                                           if (gender)
                                               [defaults setObject:@"male" forKey:@"gender"];
                                           else
                                               [defaults setObject:@"female" forKey:@"gender"];
                                           [defaults setObject:username forKey:@"name"];
                                           [defaults setObject:password forKey:@"password"];
                                           [defaults setObject:email forKey:@"email"];
                                           [defaults setObject:[NSString stringWithFormat:@"%d", age] forKey:@"age"];
                                           [defaults setObject:@"187" forKey:@"height"];
                                           [defaults setObject:@"77" forKey:@"weight"];
                                           [defaults setObject:@"" forKey:@"quote"];
                                           [defaults setObject:[res objectForKey:@"id"] forKey:@"userID"];
                                           [defaults setObject:@"1" forKey:@"isLogin"];
                                           [defaults removeObjectForKey:@"profile"];
                                           [defaults removeObjectForKey:@"photo2"];
                                           [defaults removeObjectForKey:@"photo3"];
                                           [defaults removeObjectForKey:@"photo4"];
                                           [defaults removeObjectForKey:@"photo5"];
                                           [defaults removeObjectForKey:@"photo1"];
                                           [defaults setObject:@"0" forKey:@"visibleMode"];
                                           [defaults setObject:@"1" forKey:@"isNotification"];
                                           // filter options
                                           NSMutableDictionary *filters = [[NSMutableDictionary alloc] init];
                                           [filters setObject:@"all" forKey:@"gender"];
                                           [filters setObject:@"19" forKey:@"age_start"];
                                           [filters setObject:@"36" forKey:@"age_end"];
                                           [filters setObject:@"3" forKey:@"appear_time"];
                                           [filters setObject:@"2" forKey:@"distance"];
                                           [defaults setObject:filters forKey:@"nearby_filters"];
                                           
                                           [defaults synchronize];
                                           
                                           appDelegate.tabIndex = 0;
                                       }
                                   }
                               }
                               @catch (NSException *exception) {
                                   
                               }
                               @finally {
                                   [self showProgress:NO];
                               }
                               
                           }];
    
}

#pragma - mark TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtUsername) {
        [self.imgUser setImage:imgUserDefault];
        if (isRetina)
            [scrollView setContentOffset:CGPointMake(0, 60) animated:YES];
        else
            [scrollView setContentOffset:CGPointMake(0, 60) animated:YES];
    } else if (textField == txtPassword) {
        [self.imgPassword setImage:imgPasswordDefault];
        [txtPassword setSecureTextEntry:YES];
        if (isRetina)
            [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
        else
            [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
    } else if (textField == txtEmail) {
        [self.imgEmail setImage:imgEmailDefault];
        if (isRetina)
            [scrollView setContentOffset:CGPointMake(0, 130) animated:YES];
        else
            [scrollView setContentOffset:CGPointMake(0, 130) animated:YES];
    } 
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length] == 0)
        return;
    if (textField == self.txtUsername) {
       //[self showProgress:YES];
        NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?username=%@&password=", SERVER_ADDRESS, REGISTER_USER, self.txtUsername.text]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
        
        [request setHTTPMethod:@"POST"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
         
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   @try {
                                       if (data != nil) {
                                           NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                           
                                           if ([[result objectForKey:@"status"] isEqual:@"fail"]) {
                                               //self.labelAlert.text = [result objectForKey:@"response"];
                                               //self.viewAlert.hidden = NO;
                                               [self.imgUser setImage:imgUserInvalid];
                                               [self shakeControl:self.imgUser txtField:self.txtUsername];
                                               
                                               return;
                                           } else if ([[result objectForKey:@"status"] isEqual:@"success"]){
                                               [self.imgUser setImage:imgUserValid];
                                               //self.viewAlert.hidden = YES;
                                           }
                                       }
                                   } @catch (NSException *exception) {
                                       
                                   }
                                   @finally {
                                       //[self showProgress:NO];
                                   }
                               }];
    }
    if (textField == txtPassword) {
        if ([textField.text length] < 6)
        {
            [self.imgPassword setImage:passwordInvalid];
            [self shakeControl:self.imgPassword txtField:self.txtPassword];
        } else {
            [self.imgPassword setImage:passwordValid];
        }
        [txtPassword setSecureTextEntry:YES];
    }
    if (textField == txtEmail) {
        if ([self validateEmail:textField.text]) {
            NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?email=%@", SERVER_ADDRESS, CHECK_EMAIL, self.txtEmail.text]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
            
            [request setHTTPMethod:@"POST"];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
             
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       @try {
                                           if (data != nil) {
                                               NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                               
                                               if ([[result objectForKey:@"status"] isEqual:@"fail"]) {
                                                   //self.labelAlert.text = [result objectForKey:@"response"];
                                                   //self.viewAlert.hidden = NO;
                                                   [self.imgEmail setImage:emailInvalid];
                                                   [self shakeControl:self.imgEmail txtField:self.txtEmail];
                                                   
                                                   return;
                                               } else if ([[result objectForKey:@"status"] isEqual:@"success"]){
                                                   [self.imgEmail setImage:emailValid];
                                                   //self.viewAlert.hidden = YES;
                                               }
                                           }
                                       } @catch (NSException *exception) {
                                           
                                       }
                                       @finally {
                                           //[self showProgress:NO];
                                       }
                                   }];
        } else {
            [self.imgEmail setImage:emailInvalid];
            [self shakeControl:self.imgEmail txtField:self.txtEmail];
        }
    }
    self.viewAlert.hidden = YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

- (IBAction)viewTap1:(UITapGestureRecognizer*)recognizer {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtEmail resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)btnBackClicked:(id)sender {
    if (self.imgBack.hidden == YES)
        return;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; //  return 0;
    return [emailTest evaluateWithObject:candidate];
}

- (IBAction)btnBirthdayClicked:(id)sender {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtEmail resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.overlayView.hidden = NO;
                         self.pickerView.hidden = NO;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL) checkValid:(NSString *) string {
    for (int i = 0; i < [validValues count]; i++) {
        if ([[validValues objectAtIndex:i] isEqual:string])
            return YES;
    }
    return NO;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqual:@""]) {
        self.viewAlert.hidden = YES;
        return YES;
    }
    if (textField == self.txtUsername) {
        if ([textField.text length] >= 29) {
           // self.labelAlert.text = NSLocalizedString(@"Ensure the username has at most 30 characters.", nil);
            //self.viewAlert.hidden = NO;
            [self.imgUser setImage:imgUserInvalid];
            [self shakeControl:self.imgUser txtField:self.txtUsername];
            return NO;
        }
        
        if ([self checkValid:string] == YES) {
            [self.imgUser setImage:imgUserDefault];
            self.viewAlert.hidden = YES;
            return YES;
        } else {
            //self.labelAlert.text = NSLocalizedString(@"Usernames can only use letters, numbers, and underscores.", nil);
            //self.viewAlert.hidden = NO;
            [self.imgUser setImage:imgUserInvalid];
            [self shakeControl:self.imgUser txtField:self.txtUsername];
            
            return NO;
        }
    }
    
    if (textField == self.txtPassword) {
        if ([textField.text length] >= 29) {
            //self.labelAlert.text = NSLocalizedString(@"Ensure the password has at most 30 characters.", nil);
            //self.viewAlert.hidden = NO;
            [self.imgPassword setImage:passwordInvalid];
            [self shakeControl:self.imgPassword txtField:self.txtPassword];
            return NO;
        } else {
            [self.imgPassword setImage:imgPasswordDefault];
        }
        /*
        if ([self checkValid:string] == YES) {
            self.viewAlert.hidden = YES;
            return YES;
        } else {
            self.labelAlert.text = NSLocalizedString(@"Password can only use letters, numbers, and underscores.", nil);
            self.viewAlert.hidden = NO;
            return NO;
        }*/
    }
    return YES;
}

- (IBAction)btnDoneClicked:(id)sender {
    //format date
    NSDateFormatter *FormatDate = [[NSDateFormatter alloc] init];
    [FormatDate setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    
    //set date format
    [FormatDate setDateFormat:@"MM/dd/YYYY"];
    //update date textfield
    self.labelBirthday.text = [FormatDate stringFromDate:[self.datePicker date]];
    self.labelBirthday.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    
    [FormatDate setDateFormat:@"YYYY-MM-dd"];
    
    //update date textfield
    birthday = [FormatDate stringFromDate:[self.datePicker date]];
    
    [FormatDate setDateFormat:@"YYYY"];
    int birthYear = [[FormatDate stringFromDate:[self.datePicker date]] intValue];
    int currentYear = [[FormatDate stringFromDate:[NSDate date]] intValue];
    age = currentYear - birthYear;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.overlayView.hidden = YES;
                         self.pickerView.hidden = YES;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)btnCloseClicked:(id)sender {
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.overlayView.hidden = YES;
                         self.pickerView.hidden = YES;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) showProgress:(BOOL) flag {
    if (flag) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:true];
    }
}

- (void)alertView:(UIAlertView *)localAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"gotoNearbyFromSignup" sender:self];
}

- (void) changeGender {
    if (gender) {
        [self.imgMale setImage:[UIImage imageNamed:@"account_gender_check.png"]];
        [self.imgFemale setImage:[UIImage imageNamed:@"account_gender_uncheck.png"]];
    } else {
        [self.imgFemale setImage:[UIImage imageNamed:@"account_gender_check.png"]];
        [self.imgMale setImage:[UIImage imageNamed:@"account_gender_uncheck.png"]];
    }
}

- (IBAction)btnMaleClicked:(id)sender {
    gender = YES;
    [self changeGender];
}

- (IBAction)btnFemaleClicked:(id)sender {
    gender = NO;
    [self changeGender];
}
@end
