//
//  UIDevice+ProcessesAdditions.m
//  SelfControl
//
//  Created by Felix Xiao on 11/17/13.
//  Copyright (c) 2013 Felix Xiao. All rights reserved.
//

#import "UIDevice+ProcessesAdditions.h"
#import <sys/sysctl.h>

#import <dlfcn.h>

#define SBSERVPATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

@implementation UIDevice (ProcessesAdditions)

- (NSArray *)runningProcesses {
    
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
	size_t miblen = 4;
	
	size_t size;
	int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
	
	struct kinfo_proc * process = NULL;
	struct kinfo_proc * newprocess = NULL;
	
    do {
		
        size += size / 10;
        newprocess = realloc(process, size);
		
        if (!newprocess){
			
            if (process){
                free(process);
            }
			
            return nil;
        }
		
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
		
    } while (st == -1 && errno == ENOMEM);
	
	if (st == 0){
		
		if (size % sizeof(struct kinfo_proc) == 0){
			int nprocess = size / sizeof(struct kinfo_proc);
            
			if (nprocess){
                
				NSMutableArray * array = [[NSMutableArray alloc] init];
                
				for (int i = nprocess - 1; i >= 0; i--){
                    
					NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
					NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    
					NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
																		forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
					[array addObject:dict];
				}
                
				free(process);
				return array;
			}
		}
	}
	
	return nil;
}

- (NSArray*) getActiveApps
{
    mach_port_t *port;
    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
    int (*SBSSpringBoardServerPort)() =
    dlsym(lib, "SBSSpringBoardServerPort");
    port = (mach_port_t *)SBSSpringBoardServerPort();
    dlclose(lib);
    
    
    
    void *sbserv = dlopen(SBSERVPATH, RTLD_LAZY);
    NSArray* (*SBSCopyApplicationDisplayIdentifiers)(mach_port_t* port, BOOL runningApps,BOOL debuggable) =
    dlsym(sbserv, "SBSCopyApplicationDisplayIdentifiers");
    //SBDisplayIdentifierForPID - protype assumed,verification of params done
    void* (*SBDisplayIdentifierForPID)(mach_port_t* port, int pid,char * result) =
    dlsym(sbserv, "SBDisplayIdentifierForPID");
    //SBFrontmostApplicationDisplayIdentifier - prototype assumed,verification of params done,don't call this TOO often(every second on iPod touch 4G is 'too often,every 5 seconds is not)
    void* (*SBFrontmostApplicationDisplayIdentifier)(mach_port_t* port,char * result) =
    dlsym(sbserv, "SBFrontmostApplicationDisplayIdentifier");
    
    
    
    //Get frontmost application
    char frontmostAppS[256];
    memset(frontmostAppS,sizeof(frontmostAppS),0);
    SBFrontmostApplicationDisplayIdentifier(port,frontmostAppS);
    NSString * frontmostApp=[NSString stringWithFormat:@"%s",frontmostAppS];
    //NSLog(@"Frontmost app is %@",frontmostApp);
    //get list of running apps from SpringBoard
    NSArray *allApplications = SBSCopyApplicationDisplayIdentifiers(port,NO, NO);
    //Really returns ACTIVE applications(from multitasking bar)
    /*   NSLog(@"Active applications:");
     for(NSString *identifier in allApplications) {
     // NSString * locName=SBSCopyLocalizedApplicationNameForDisplayIdentifier(p,identifier);
     NSLog(@"Active Application:%@",identifier);
     }
     */
    
    //get list of all apps from kernel
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    int ruid=process[i].kp_eproc.e_pcred.p_ruid;
                    int uid=process[i].kp_eproc.e_ucred.cr_uid;
                    //short int nice=process[i].kp_proc.p_nice;
                    //short int u_prio=process[i].kp_proc.p_usrpri;
                    short int prio=process[i].kp_proc.p_priority;
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    
                    
                    BOOL systemProcess=YES;
                    if (ruid==501)
                        systemProcess=NO;
                    
                    
                    
                    char * appid[256];
                    memset(appid,sizeof(appid),0);
                    int intID,intID2;
                    intID=process[i].kp_proc.p_pid,appid;
                    SBDisplayIdentifierForPID(port,intID,appid);
                    
                    NSString * appId=[NSString stringWithFormat:@"%s",appid];
                    
                    if (systemProcess==NO)
                    {
                        if ([appId isEqualToString:@""])
                        {
                            //final check.if no appid this is not springboard app
                            //NSLog(@"(potentially system)Found process with PID:%@ name %@,isSystem:%d,Priority:%d",processID,processName,systemProcess,prio);
                        }
                        else
                        {
                            
                            BOOL isFrontmost=NO;
                            if ([frontmostApp isEqualToString:appId])
                            {
                                isFrontmost=YES;
                            }
                            NSNumber *isFrontmostN=[NSNumber numberWithBool:isFrontmost];
                            NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName,appId,isFrontmostN, nil] 
                                                                                forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName",@"AppID",@"isFrontmost", nil]];
                            
                            ///NSLog(@"PID:%@, name: %@, AppID:%@,isFrontmost:%d",processID,processName,appId,isFrontmost);
                            [array addObject:dict];
                        }
                    }
                }
                
                free(process);
                return array;
            }
        }
        
    }
    
    dlclose(sbserv);
    return nil;
}

@end
