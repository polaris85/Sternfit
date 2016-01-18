//
//  TrainingPlan.h
//  SternFit
//
//  Created by Adam on 1/19/15.
//  Copyright (c) 2015 com.mobile.sternfit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Exercise.h"

@interface TrainingPlan : NSObject

@property (nonatomic, strong) NSString *ID;
@property int weekday;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) Exercise *exercise;
@end
