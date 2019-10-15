//
//  AppDelegate.m
//  addContactDemo
//
//  Created by haohao on 2019/10/8.
//  Copyright © 2019 haohao. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@interface AppDelegate ()
 
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
 
@property (nonatomic, strong) NSTimer   *   myTimer;        // 循环请求计数，后台开启，前台关闭。

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    ViewController* vc = [[ViewController alloc]init];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav;
    // 显示窗口
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
  {
      [self beingBackgroundUpdateTask];
      
      //[[NSNotificationCenter defaultCenter] postNotificationName:@"addContact" object:nil];
       
      
      [self endBackgroundUpdateTask];
      
  }

 
-(void)beingBackgroundUpdateTask{
    self.backgroundTaskIdentifier  = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [self endBackgroundUpdateTask];
    }];
}



-(void)endBackgroundUpdateTask{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

@end
