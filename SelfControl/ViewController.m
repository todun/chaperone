//
//  ViewController.m
//  SelfControl
//
//  Created by Felix Xiao on 11/17/13.
//  Copyright (c) 2013 Felix Xiao. All rights reserved.
//

#import "ViewController.h"
#import "UIDevice+ProcessesAdditions.h"
#import "iHasApp.h"
#import "AppDelegate.h"
#import "MZTimerLabel.h"

@interface ViewController ()
@property (strong, nonatomic) AppDelegate *appDelegate;
@end

@implementation ViewController

@synthesize detectedApps,timerLabel,timeSlider,startButton,appDelegate,countdownLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startButton setImage:[UIImage imageNamed:@"startbutton.png"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startSelfControl:) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.alpha = 1.0;
    self.timeSlider.alpha = 1.0;
    self.startButton.clipsToBounds = YES;
    
    self.startButton.layer.cornerRadius = 50;//half of the width
    self.countdownLabel.alpha = 0.0;
    
    if (appDelegate.currentlyActive == YES) {
        self.startButton.alpha = 0.0;
        self.timeSlider.hidden = YES;
        
        self.countdownLabel.hidden = NO;
        //show the countdown timer instead
        MZTimerLabel *timer = [[MZTimerLabel alloc] initWithLabel:countdownLabel andTimerType:MZTimerLabelTypeTimer];
        [timer setCountDownTime:(self.appDelegate.expirationTimestamp - [[NSDate date] timeIntervalSince1970]/1)];
        [timer start];
    } else {
        
    }
    
    
     // the interval is in seconds...
    //[self detectApps];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startSelfControl:(id)sender
{
    NSLog(@"started");
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(testMethod:) userInfo:nil repeats:YES];
    
    int expirationInt = (self.timeSlider.value/1) + [[NSDate date] timeIntervalSince1970];
    NSString *myExp = [NSString stringWithFormat:@"%i",expirationInt];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myExp forKey:@"expiration"];
    
    self.appDelegate.expirationTimestamp = expirationInt;
    self.appDelegate.currentlyActive = YES;
    
    //show the countdown timer instead
    MZTimerLabel *timer = [[MZTimerLabel alloc] initWithLabel:countdownLabel andTimerType:MZTimerLabelTypeTimer];
    [timer setCountDownTime:(self.appDelegate.expirationTimestamp - [[NSDate date] timeIntervalSince1970]/1)];
    [timer start];
    self.countdownLabel.alpha = 1.0;
    [[self.view viewWithTag:256] removeFromSuperview];
    self.timeSlider.alpha = 0.0;
    self.timerLabel.alpha = 0.0;
    [self.view setNeedsDisplay];
}
- (void)detectApps
{
    iHasApp *detectionObject = [[iHasApp alloc] init];
    [detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
        //NSLog(@"Incremental appDictionaries.count: %i", appDictionaries.count);
    } withSuccess:^(NSArray *appDictionaries) {
        //NSLog(@"Successful appDictionaries.count: %i", appDictionaries.count);
        self.detectedApps = appDictionaries;
        //NSLog(@"%@",self.detectedApps);
    } withFailure:^(NSError *error) {
        //NSLog(@"Failure: %@", error.localizedDescription);
    }];
}

- (void)testMethod:(NSTimer *)timer
{
    int currentTime = [[NSDate date] timeIntervalSince1970]/1;
    if (currentTime > appDelegate.expirationTimestamp && appDelegate.expirationTimestamp > 100000) {
        [timer invalidate];
    }
    
    NSLog(@"called");
    NSArray * processes = [[UIDevice currentDevice] getActiveApps];
    //NSArray * processes = [[UIDevice currentDevice] runningProcesses];
    NSArray *keywords = [NSArray arrayWithObjects:@"Facebook",@"Twitter",@"Instagram", nil];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (NSDictionary * dict in processes){
        NSLog(@"%@",dict);
        NSString *processName = [dict objectForKey:@"ProcessName"];
        //NSLog(@"%@",processName);
        if ([keywords containsObject:processName] && [[dict objectForKey:@"isFrontmost"] integerValue] ==1) {
            
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

- (IBAction)sliderValueChanged:(id)sender
{
    int value = [(UISlider*)sender value];
    NSString *labelText = @"";
    if (value < 60) {
        labelText = [labelText stringByAppendingFormat:@"%i min",value%60];
    } else if (value < 120) {
        labelText = [labelText stringByAppendingFormat:@"%i hour %i min",value/60,value%60];
    } else {
        labelText = [labelText stringByAppendingFormat:@"%i hours %i min",value/60,value%60];
    }
    timerLabel.text = labelText;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
