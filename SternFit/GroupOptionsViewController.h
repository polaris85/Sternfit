//
//  GroupOptionsViewController.h
//  SternFit
//
//  Created by Adam on 2/4/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupOptionsViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UIScrollView *userScrollView;
@property (nonatomic, strong) IBOutlet UILabel *labelGroupNameTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelGroupName;
@property (nonatomic, strong) IBOutlet UILabel *labelNotificationTitle;
@property (nonatomic, strong) IBOutlet UISwitch *switchNotification;
@property (nonatomic, strong) IBOutlet UILabel *labelClear;
@property (nonatomic, strong) IBOutlet UIButton *btnDelete;
@property (nonatomic, strong) IBOutlet UIButton *btnRemove;
@property (nonatomic, strong) IBOutlet UIButton *btnAdd;
@property (nonatomic, strong) IBOutlet UIImageView *imgAdd;
@property (nonatomic, strong) IBOutlet UIImageView *imgRemove;

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnAddUserClicked:(id)sender;
- (IBAction)btnDeleteUserClicked:(id)sender;
- (IBAction)btnChangeGroupNameClicked:(id)sender;
- (IBAction)btnClearHistoryClicked:(id)sender;
- (IBAction)btnLeaveClicked:(id)sender;

@end
