//
//  ViewController.m
//  SelfControl
//
//  Created by Felix Xiao on 11/17/13.
//  Copyright (c) 2013 Felix Xiao. All rights reserved.
//

#import "ViewController.h"
#import "UIDevice+ProcessesAdditions.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(testMethod:) userInfo:nil repeats:YES]; // the interval is in seconds...
    
    //[self testMethod];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)testMethod:(NSTimer *)timer
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
            
            //
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
