//
//  MTKAppDelegate.m
//  Example
//
//  Created by Martin Kiss on 26.4.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "MTKResourceExampleAppDelegate.h"

#import "MTKResource.h"




@implementation MTKResourceExampleAppDelegate





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    MTKResource *resourcer = [[MTKResource alloc] init];
    
    
    return YES;
}





@end


