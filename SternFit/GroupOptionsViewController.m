//
//  GroupOptionsViewController.m
//  SternFit
//
//  Created by Adam on 2/4/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import "GroupOptionsViewController.h"
#import "ChangeUsernameViewController.h"
#import "AppDelegate.h"
#import "DBManager.h"

@interface GroupOptionsViewController () {
    NSUserDefaults *defaults;
    AppDelegate *appDelegate;
}

@end

@implementation GroupOptionsViewController

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
    
    defaults = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    self.labelGroupNameTitle.font = [UIFont fontWithName:@"Lato-Bold" size:17.0f];
    //self.labelTitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18.0f];
    self.labelNotificationTitle.font = [UIFont fontWithName:@"Lato-Bold" size:17.0f];
    self.labelClear.font = [UIFont fontWithName:@"Lato-Bold" size:17.0f];
    self.btnDelete.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16.0f];
    self.labelGroupName.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0f];
    
    self.labelGroupName.text = NSLocalizedString(@"This group name", nil);
    self.labelGroupNameTitle.text = NSLocalizedString(@"Group name", nil);
    self.labelNotificationTitle.text = NSLocalizedString(@"Mute Notifications", nil);
    self.labelClear.text = NSLocalizedString(@"Clear Chat History", nil);
    [self.btnDelete setTitle:NSLocalizedString(@"DELETE AND LEAVE", nil) forState:UIControlStateNormal];
    
    if (![[appDelegate.groupInfo objectForKey:@"owner"] isEqual:[defaults objectForKey:@"userID"]]) {
        self.imgRemove.hidden = YES;
        self.btnRemove.hidden = YES;
        CGRect frame = self.imgAdd.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        self.imgAdd.frame = frame;
        
        frame = self.btnAdd.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        self.btnAdd.frame = frame;
    }

    [self.switchNotification addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[appDelegate.groupInfo objectForKey:@"name"] isEqual:@"Group"]) {
        self.labelGroupName.text = [appDelegate.groupInfo objectForKey:@"name"];
    }
    
    if ([[appDelegate.groupInfo objectForKey:@"mute"] intValue] == 0) {
        [self.switchNotification setOn:NO];
    }
    
    self.labelTitle.text = [NSString stringWithFormat:@"%@(%@)", [appDelegate.groupInfo objectForKey:@"name"], [appDelegate.groupInfo objectForKey:@"memberNum"]];
    
    [self loadScrollView];
}

- (void) loadScrollView {
    NSArray *views = [self.userScrollView subviews];
    for (int i = 0; i < [views count]; i++) {
        [((UIView*) [views objectAtIndex:i]) removeFromSuperview];
    }
    UIColor *borderColor1 = [UIColor colorWithRed:44.0f/255.0f green:44.0f/255.0f blue:44.0f/255.0f alpha:1];
    UIColor *borderColor2 = [UIColor colorWithRed:247.0f/255.0f green:27.0f/255.0f blue:90.0f/255.0f alpha:1];
    for (int i = 0; i < [appDelegate.groupUsers count]; i++) {
        Friend *temp = (Friend*) [appDelegate.groupUsers objectAtIndex:i];
        AsyncImageView *imageView = [[AsyncImageView alloc] init];
        [imageView setActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [imageView setImageURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGE_URL, temp.image]]];
        imageView.layer.cornerRadius = 40.0f;
        if (temp.gender == YES)
            imageView.layer.borderColor = [borderColor1 CGColor];
        else
            imageView.layer.borderColor = [borderColor2 CGColor];
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.masksToBounds = YES;
        imageView.tag = i;
        imageView.frame = CGRectMake(10 + i * 100, 10, 80, 80);
        
        [self.userScrollView addSubview:imageView];
        
        UIImageView *imgDelete = [[UIImageView alloc] init];
        [imgDelete setImage:[UIImage imageNamed:@"group_removeuser.png"]];
        imgDelete.frame = CGRectMake(10 + i * 100, 10, 30, 30);
        imgDelete.hidden = YES;
        imgDelete.tag = i;
        [self.userScrollView addSubview:imgDelete];
        
        UITapGestureRecognizer *tapView8 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteUser:)];
        tapView8.delegate = self;
        [imgDelete addGestureRecognizer:tapView8];
        [imgDelete setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapView1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUser:)];
        tapView1.delegate = self;
        [imageView addGestureRecognizer:tapView1];
        [imageView setUserInteractionEnabled:YES];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:17.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = temp.name;
        label.numberOfLines = 2;
        label.frame = CGRectMake(i * 100, 90, 100, 40);
    }
    
    [self.userScrollView setContentSize:CGSizeMake([appDelegate.groupUsers count] * 100, 100)];
}

- (IBAction)deleteUser:(UITapGestureRecognizer*)recognizer {
    int index = (int) recognizer.view.tag;
    Friend *friend = (Friend*) [appDelegate.groupUsers objectAtIndex:index];
    NSDate *currentTime = [NSDate date];
    long time = (long) [currentTime timeIntervalSince1970];
    
    [self showProgress:YES];
    NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?cID=%@&removeUserID=%d&username=%@&removeuser=%@&senderID=%@&lastupdatetime=%ld", SERVER_ADDRESS, DELETE_USER_FROMGROUP, [appDelegate.groupInfo objectForKey:@"ID"], friend.userId, [defaults objectForKey:@"name"], friend.name, [defaults objectForKey:@"userID"], time]];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request1 setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [appDelegate.groupUsers removeObjectAtIndex:index];
                               NSString *members = [appDelegate.groupInfo objectForKey:@"members"];
                               members = [members stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@", friend.name] withString:@""];
                               members = [members stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", friend.name] withString:@""];
                               [appDelegate.groupInfo setObject:members forKey:@"members"];
                               int memberNum = [[appDelegate.groupInfo objectForKey:@"memberNum"] intValue];
                               memberNum--;
                               [appDelegate.groupInfo setObject:[NSString stringWithFormat:@"%d", memberNum] forKey:@"memberNum"];
                               
                               [self loadScrollView];
                               [self showProgress:NO];
                           }];
}

- (IBAction)tapUser:(UITapGestureRecognizer*)recognizer {
    int index = (int) recognizer.view.tag;
    appDelegate.selectOtherUser = (Friend*) [appDelegate.groupUsers objectAtIndex:index];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OtherProfileViewController *controller = (OtherProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"OtherProfileViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnAddUserClicked:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StartGroupViewController *controller = (StartGroupViewController *)[storyboard instantiateViewControllerWithIdentifier:@"StartGroupViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)btnDeleteUserClicked:(id)sender {
    NSArray *views = [self.userScrollView subviews];
    for (int i = 0; i < [views count]; i++) {
        if ([[views objectAtIndex:i] isKindOfClass:[UIImageView class]] && ![[views objectAtIndex:i] isKindOfClass:[AsyncImageView class]]) {
            UIImageView *imgDelete = (UIImageView*) [views objectAtIndex:i];
            if (imgDelete.hidden == YES)
                imgDelete.hidden = NO;
            else
                imgDelete.hidden = YES;
        }
    }
}
- (IBAction)btnChangeGroupNameClicked:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChangeUsernameViewController *controller = (ChangeUsernameViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChangeUsernameViewController"];
    controller.isUsernameChange = 2;
    [self.navigationController pushViewController:controller animated:YES];
   
}

- (IBAction)btnClearHistoryClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Are you sure to clear chat history?", nil) delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag = 1;
    [alertView show];

}
- (IBAction)btnLeaveClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Are you sure to leave this group?", nil) delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag = 2;
    [alertView show];
}

- (void) setState:(id)sender {
    int value = 0;
    if (self.switchNotification.isOn) {
        value = 1;
    }
    
    [appDelegate.groupInfo setObject:[NSString stringWithFormat:@"%d", value] forKey:@"mute"];
    
    NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?ID=%@&name=%@&mute=%d&cID=%@", SERVER_ADDRESS, CHANGE_GROUP_CHAT_OPTIONS, [defaults objectForKey:@"userID"], [[appDelegate.groupInfo objectForKey:@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], value, [appDelegate.groupInfo objectForKey:@"ID"]]];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request1 setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                           }];
}

- (void)alertView:(UIAlertView *)localAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (localAlertView.tag == 1) {
        if (buttonIndex == 1) {
            [[DBManager getSharedInstance] deleteMessages:[appDelegate.groupInfo objectForKey:@"ID"]];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SternFit", nil) message:NSLocalizedString(@"Successfully cleared", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    } else if (localAlertView.tag == 2) {
        if (buttonIndex == 1) {
            [self showProgress:YES];
            [[DBManager getSharedInstance] deleteMessages:[appDelegate.groupInfo objectForKey:@"ID"]];
            
            NSDate *currentTime = [NSDate date];
            long time = (long) [currentTime timeIntervalSince1970];
            
            NSURL *myURL1 = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?cID=%@&userID=%@&username=%@&lastupdatetime=%ld", SERVER_ADDRESS, LEAVE_GROUP_CHAT, [appDelegate.groupInfo objectForKey:@"ID"], [defaults objectForKey:@"userID"], [defaults objectForKey:@"name"], time]];
            NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:myURL1 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
            
            [request1 setHTTPMethod:@"POST"];
            
            [NSURLConnection sendAsynchronousRequest:request1 queue:[NSOperationQueue mainQueue]
             
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       [self showProgress:NO];
                                       NSArray *array = [self.navigationController viewControllers];
                                       for (int i = (int)[array count] - 1; i >= 0; i--) {
                                           if ([[array objectAtIndex:i] isKindOfClass:[MHCustomTabBarController class]]) {
                                               appDelegate.tabIndex = 1;
                                               [self.navigationController popToViewController:[array objectAtIndex:i] animated:YES];
                                               return;
                                           }
                                       }
                                   }];
        }
    }
}

- (void) showProgress:(BOOL) flag {
    if (flag) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:true];
    }
}


@end
