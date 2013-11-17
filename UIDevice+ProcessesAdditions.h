//
//  UIDevice+ProcessesAdditions.h
//  SelfControl
//
//  Created by Felix Xiao on 11/17/13.
//  Copyright (c) 2013 Felix Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (ProcessesAdditions)

- (NSArray *)runningProcesses;
- (NSArray *)getActiveApps;
@end
