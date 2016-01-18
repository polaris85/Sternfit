//
//  AppDelegate.m
//  SternFit
//
//  Created by Adam on 12/9/14.
//  Copyright (c) 2014 com.mobile.sternfit. All rights reserved.
//

#import "AppDelegate.h"
#import "DBManager.h"

@implementation AppDelegate {
    int loadIndex;
}

-(void)setupAppearance {
    UIImage *minImage = [[UIImage imageNamed:@"filter_progress_max.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"filter_progress_min.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"filter_progress_icon.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //[FBLoginView class];
    
    [self setupAppearance];
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [self startStandardUpdates];
    
    self.messageNum = 0;
    
    self.silenceTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                       selector:@selector(listenForNotification) userInfo:nil repeats:YES];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[FBSession activeSession] handleDidBecomeActive];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if ([self.currentViewController isKindOfClass:[MessageViewController class]]) {
        [((MessageViewController*)self.currentViewController) loadMessages];
    } else {
        if ([self.friends count] > 0)
            [self checkChatRoom:0];
    }
    
    [self refreshNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.silenceTimer invalidate];
    [self.session close];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.deviceToken = [self stringWithDeviceToken:deviceToken];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"isLogin"] && [[defaults objectForKey:@"isLogin"] isEqual:@"1"]) {
        NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?username=%@&deviceToken=%@", SERVER_ADDRESS, UPDATE_USER, [defaults objectForKey:@"name"],self.deviceToken]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
        
        [request setHTTPMethod:@"POST"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
         
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (NSString*)stringWithDeviceToken:(NSData*)deviceToken
{
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy] ;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSMutableDictionary *dict=[[userInfo valueForKey:@"aps"] mutableCopy];
    
    BOOL isVibrate = YES;
    
    [dict setValue:
     [[dict valueForKey:@"message"] stringByRemovingPercentEncoding]
            forKey:@"message"];
    
    int NotiType=[[[userInfo valueForKey:@"aps"] valueForKey:@"type"] intValue];
    
    if (NotiType == 3) {
      // int secondsFromGMT = (int)[[NSTimeZone localTimeZone] secondsFromGMT];
        
        int time = [[[dict objectForKey:@"lastupdatetime"] description] intValue];
        //time += secondsFromGMT;
        NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:time];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        NSString *date = [dateFormatter stringFromDate: currentTime];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *message = [dict objectForKey:@"message"];
        if ([[dict objectForKey:@"messagetype"] intValue] == 100 && [[dict objectForKey:@"subtype"] intValue] == 2 && [message rangeOfString:[defaults objectForKey:@"name"]].location != NSNotFound) {
            [dict setObject:[NSString stringWithFormat:@"%@ invited you in group chat.", [dict objectForKey:@"senderName"]] forKey:@"message"];
        }
        
        [[DBManager getSharedInstance] addMessage:[dict objectForKey:@"chatroomID"] senderID:[dict objectForKey:@"senderID"] message:[dict objectForKey:@"message"] type:[dict objectForKey:@"messagetype"] lastupdatetime:[dict objectForKey:@"lastupdatetime"] created_at:date updated_at:date status:@"0"];
        
        NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?mID=%@&userID=%@", SERVER_ADDRESS, ACCEPT_MESSAGE, [dict objectForKey:@"messageID"], [defaults objectForKey:@"userID"]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
        
        [request setHTTPMethod:@"POST"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
         
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               }];
        
        if ([self.currentViewController isKindOfClass:[ChatViewController class]]) {
            if ([((ChatViewController*)self.currentViewController).chatroomID intValue] == [[dict objectForKey:@"chatroomID"] intValue]) {
                [((ChatViewController*)self.currentViewController) refreshChat:dict];
                [[DBManager getSharedInstance] updateMessage:[dict objectForKey:@"chatroomID"]];
                
                if (self.groupInfo != nil) {
                    if ([[self.groupInfo objectForKey:@"ID"] intValue] == [[dict objectForKey:@"chatroomID"] intValue] && [[self.groupInfo objectForKey:@"mute"] intValue] == 1) {
                        isVibrate = NO;
                    }
                }
            } else {
                self.messageNum++;
                [self.tabBarController updateMessageNum:self.messageNum];
            }
        } else if ([self.currentViewController isKindOfClass:[MessageViewController class]]) {
            self.messageNum++;
            //[[DBManager getSharedInstance] updateMessage:[dict objectForKey:@"chatroomID"]];
            [((MessageViewController*)self.currentViewController) loadMessages];
        } else {
            self.messageNum++;
            [self.tabBarController updateMessageNum:self.messageNum];
        }
    } else {
        [self refreshFriends];
        [self refreshNotifications];
    }
    
    if (isVibrate)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void) refreshNotifications {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?ID=%@", SERVER_ADDRESS, GET_NOTIFICATIONS, [defaults objectForKey:@"userID"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               self.notificationNum = 0;
                               self.notifications = [[NSMutableArray alloc] init];
                               @try {
                                   if (data != nil) {
                                       NSMutableArray *result = (NSMutableArray*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                       
                                       if (result != nil && [result count] > 0) {
                                           for (int i = 0; i < [result count]; i++) {
                                               NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
                                               NSMutableDictionary *temp = (NSMutableDictionary*) [result objectAtIndex:i];
                                               [notification setObject:[temp objectForKey:@"image"] forKey:@"image"];
                                               [notification setObject:[temp objectForKey:@"ID"] forKey:@"userid"];
                                               [notification setObject:[temp objectForKey:@"username"] forKey:@"name"];
                                               [notification setObject:[temp objectForKey:@"onlinestatus"] forKey:@"onlinestatus"];
                                               [notification setObject:[temp objectForKey:@"status"] forKey:@"status"];
                                               [notification setObject:[temp objectForKey:@"lastupdatetime"] forKey:@"sharetime"];
                                               [notification setObject:[temp objectForKey:@"notificationID"] forKey:@"ID"];
                                               
                                               if ([[temp objectForKey:@"gender"] intValue] == 1)
                                                   [notification setObject:@"male" forKey:@"gender"];
                                               else
                                                   [notification setObject:@"female" forKey:@"gender"];
                                               if ([[temp objectForKey:@"type"] intValue] == 0)
                                                   [notification setObject:@"1" forKey:@"friendrequest"];
                                               else
                                                   [notification setObject:@"0" forKey:@"friendrequest"];
                                               //[notification setObject:@"Hey Nice to meet you" forKey:@"message"];
                                               
                                               [self.notifications addObject:notification];
                                               
                                               if ([[temp objectForKey:@"status"] intValue] == 0)
                                                   self.notificationNum++;
                                           }
                                       }
                                   }
                                   
                                   [self.tabBarController updateNotificationNum:self.notificationNum];
                                   
                                   if ([self.currentViewController isKindOfClass:[NotificationViewController class]]) {
                                       [((NotificationViewController*) self.currentViewController) reloadTable];
                                   } else if ([self.currentViewController isKindOfClass:[NearbyViewController class]]) {
                                       [((NearbyViewController*) self.currentViewController) refreshUsers];
                                   } else if ([self.currentViewController isKindOfClass:[FriendsViewController class]]) {
                                       [((FriendsViewController*) self.currentViewController) refreshFriends];
                                   }
                               } @catch( NSException *e) {
                                   [self.tabBarController updateNotificationNum:self.notificationNum];
                                   
                                   if ([self.currentViewController isKindOfClass:[NotificationViewController class]]) {
                                       [((NotificationViewController*) self.currentViewController) reloadTable];
                                   } else if ([self.currentViewController isKindOfClass:[NearbyViewController class]]) {
                                       [((NearbyViewController*) self.currentViewController) refreshUsers];
                                   } else if ([self.currentViewController isKindOfClass:[FriendsViewController class]]) {
                                       [((FriendsViewController*) self.currentViewController) refreshFriends];
                                   }
                               }
                               
                           }];
    
}

- (void) listenForNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"isLogin"] && [[defaults objectForKey:@"isLogin"] isEqual:@"1"]) {
        if (self.currentLocation.coordinate.latitude != 0.0f) {
            NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?username=%@&lat=%f&long=%f", SERVER_ADDRESS, UPDATE_USER, [defaults objectForKey:@"name"], self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
            
            [request setHTTPMethod:@"POST"];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
             
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   }];
        }
    }
}

- (void) updateCurrentLocation {
    // call the same method on a background thread
    dispatch_queue_t unsyncNamesQueue =
    dispatch_queue_create("UnsyncNamesFromServer", DISPATCH_QUEUE_SERIAL);
    //....
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                   unsyncNamesQueue, ^{
                       
                       [self updateCurrentLocation];
                   }
                   );
}

- (void) startLocationServices {
    self.currentLocation = self.locationManager.location;
}

- (void)startStandardUpdates {
	if (nil == self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
	}
	
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Set a movement threshold for new events.
	self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
    [self.locationManager startUpdatingLocation];
    
    self.currentLocation = self.locationManager.location;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
}

- (void) checkChatRoom:(int) index {
    Friend *friend;
   // long secondsFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT];
    friend = (Friend*) [self.friends objectAtIndex:index];
    loadIndex = index;
    NSString *lastupdatetime = [[DBManager getSharedInstance] getLastUpdateTime:friend.chatroomID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?cID=%@&lastupdatetime=%@&userID=%@", SERVER_ADDRESS, GET_PRIVATE_MESSAGE, friend.chatroomID, lastupdatetime, [defaults objectForKey:@"userID"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               @try {
                                   if (data != nil) {
                                       NSMutableArray *result = (NSMutableArray*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                       
                                       if (result != nil && [result count] > 0) {
                                           NSMutableDictionary *temp;
                                           for (int i = 0; i < [result count]; i++) {
                                               temp = (NSMutableDictionary*) [result objectAtIndex:i];
                                               
                                               long time = [[temp objectForKey:@"lastupdatetime"] longValue];// + secondsFromGMT;
                                               NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:time];
                                               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                               [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
                                               NSString *date = [dateFormatter stringFromDate: currentTime];
                                               
                                               [[DBManager getSharedInstance] addMessage:[temp objectForKey:@"chatroomID"] senderID:[temp objectForKey:@"senderID"] message:[temp objectForKey:@"message"] type:[temp objectForKey:@"type"] lastupdatetime:[temp objectForKey:@"lastupdatetime"] created_at:date updated_at:date status:@"0"];
                                               
                                               self.messageNum++;
                                           }
                                       }
                                   }
                               }
                               @catch (NSException *exception) {
                                   
                               }
                               @finally {
                                   loadIndex++;
                                   if (loadIndex >= [self.friends count]) {
                                       [self.tabBarController updateMessageNum:self.messageNum];
                                   } else {
                                       [self checkChatRoom:loadIndex];
                                   }
                               }
                           }];
}

- (void) refreshFriends {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSURL *myURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@?ID=%@&lat=%f&lon=%f", SERVER_ADDRESS, GET_FRIENDS, [defaults objectForKey:@"userID"], self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:360];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
     
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               @try {
                                   if (data != nil) {
                                       self.friends = [[NSMutableArray alloc] init];
                                       self.messageNum = 0;
                                       
                                       NSMutableDictionary *result1 = (NSMutableDictionary*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                       NSMutableArray *result = (NSMutableArray*) [result1 objectForKey:@"friends"];
                                       
                                       self.groupChatIDs = (NSMutableArray*) [result1 objectForKey:@"group"];
                                       
                                       if (result != nil && [result count] > 0) {
                                           NSMutableDictionary *temp;
                                           for (int i = 0; i < [result count]; i++) {
                                               temp = (NSMutableDictionary*) [result objectAtIndex:i];
                                               Friend *user = [[Friend alloc] init];
                                               user.image = [temp objectForKey:@"image"];
                                               user.photo1 = [temp objectForKey:@"photo1"];
                                               user.photo2 = [temp objectForKey:@"photo2"];
                                               user.photo3 = [temp objectForKey:@"photo3"];
                                               user.photo4 = [temp objectForKey:@"photo4"];
                                               user.photo5 = [temp objectForKey:@"photo5"];
                                               user.distance = [[temp objectForKey:@"distance"] doubleValue] * 1.60934f;
                                               user.userId = [[temp objectForKey:@"ID"] intValue];
                                               user.name = [temp objectForKey:@"username"];
                                               user.message = [temp objectForKey:@"quote"];
                                               user.status = [[temp objectForKey:@"status"] intValue];
                                               user.chatroomID = [temp objectForKey:@"chatroomID"];
                                               user.lastupdatetime = (int)([[temp objectForKey:@"lastupdatetime"] intValue] / 60);
                                               if ([[temp objectForKey:@"gender"] intValue] == 1)
                                                   user.gender = YES;
                                               else
                                                   user.gender = NO;
                                               
                                               user.isFriend = [[temp objectForKey:@"isFriend"] intValue];
                                               
                                               int birthYear = [[[temp objectForKey:@"birthday"] substringToIndex:4] intValue];
                                               NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                               [formatter setDateFormat:@"yyyy"];
                                               int currentYear = [[formatter stringFromDate:[NSDate date]] intValue];
                                               int age = currentYear - birthYear;
                                               user.age = age;
                                               
                                               user.height = [[temp objectForKey:@"height"] intValue];
                                               user.weight = [[temp objectForKey:@"weight"] intValue];
                                               
                                               [self.friends addObject:user];
                                               
                                               self.messageNum += [[DBManager getSharedInstance] getLastUnreadMessageNum:user.chatroomID];
                                           }
                                       }
                                   }
                                   
                                   
                               }
                               @catch (NSException *exception) {
                                   
                               }
                               @finally {
                               }
                               
                           }];
}


@end
