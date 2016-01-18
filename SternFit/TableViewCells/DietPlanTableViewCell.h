//
//  DietPlanTableViewCell.h
//  SternFit
//
//  Created by Adam on 1/30/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "DietPlanViewController.h"

@interface DietPlanTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet AsyncImageView *imgIcon;
@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelDetail1;
@property (nonatomic, strong) IBOutlet UILabel *labelDetail2;
@property (nonatomic, strong) IBOutlet UILabel *labelDetail3;
@property (nonatomic, strong) IBOutlet UIButton *btnTap;
@property (nonatomic, strong) IBOutlet UIButton *btnDelete;
@property (nonatomic, strong) IBOutlet UIButton *btnTap1;
@property (nonatomic, retain) IBOutlet UIImageView *imgSeperate;
@property (nonatomic, retain) IBOutlet UIImageView *imgSeperate1;

@property (nonatomic) int index;
@property (nonatomic, strong) DietPlanViewController *controller;
- (void)imageresize;

- (void)setData:(NSMutableArray*) weekday;

@end
