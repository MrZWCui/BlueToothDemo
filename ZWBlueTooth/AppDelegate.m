//
//  AppDelegate.m
//  ZWBlueTooth
//
//  Created by 崔先生的MacBook Pro on 2022/9/6.
//

#import "AppDelegate.h"
#import "ZWBlueToothViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ZWBlueToothViewController *vc = [ZWBlueToothViewController new];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
