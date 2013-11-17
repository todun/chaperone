//
//  ViewController.h
//  SelfControl
//
//  Created by Felix Xiao on 11/17/13.
//  Copyright (c) 2013 Felix Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) NSArray *detectedApps;

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UISlider *timeSlider;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;

- (IBAction) sliderValueChanged:(id)sender;
- (IBAction)startSelfControl:(id)sender;

@end
