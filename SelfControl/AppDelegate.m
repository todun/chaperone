//
//  AppDelegate.m
//  SelfControl
//
//  Created by Felix Xiao on 11/17/13.
//  Copyright (c) 2013 Felix Xiao. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+ProcessesAdditions.h"

@implementation AppDelegate
@synthesize myVC,currentlyActive,expirationTimestamp;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:@"expiration"] isEqualToString:@""]) {
        self.expirationTimestamp = [[defaults objectForKey:@"expiration"] integerValue];
        
        int currentTime = [[NSDate date] timeIntervalSince1970]/1;
        
        if (currentTime < self.expirationTimestamp) {
            self.currentlyActive = YES;
        } else {
            self.currentlyActive = NO;
        }
    }
    return YES;

    //myVC = [[ViewController alloc] init];
    //[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(testMethod:) userInfo:nil repeats:YES];
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication* myApplication = [UIApplication sharedApplication];
    [myApplication beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(testMethod:) userInfo:nil repeats:YES];
        
    }];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)testMethod:(NSTimer*)timer
{
    NSLog(@"called");
    NSArray * processes = [[UIDevice currentDevice] getActiveApps];
    //NSArray * processes = [[UIDevice currentDevice] runningProcesses];
    NSArray *keywords = [NSArray arrayWithObjects:@"Facebook",@"Twitter",@"Instagram", nil];
    
    for (NSDictionary * dict in processes){
        //NSLog(@"%@",dict);
        NSString *processName = [dict objectForKey:@"ProcessName"];
        //NSLog(@"%@",processName);
        if ([keywords containsObject:processName]) {
            NSLog(@"%@ is currently running.",processName);
            
            UILocalNotification *local = [[UILocalNotification alloc] init];
            
            // create date/time information
            local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1]; //time in seconds
            local.timeZone = [NSTimeZone defaultTimeZone];
            
            // set notification details
            local.alertBody = [NSString stringWithFormat:@"Close %@!",processName];
            local.alertAction = @"Okay!";
            
            
            local.soundName = [NSString stringWithFormat:@"Default.caf"];
            
            // Gather any custom data you need to save with the notification
            NSDictionary *customInfo =
            [NSDictionary dictionaryWithObject:@"ABCD1234" forKey:@"yourKey"];
            local.userInfo = customInfo;
            
            // Schedule it!
            [[UIApplication sharedApplication] scheduleLocalNotification:local];
        }
        //NSLog(@"%@ - %@", [dict objectForKey:@"ProcessID"], [dict objectForKey:@"ProcessName"]);
    }
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
