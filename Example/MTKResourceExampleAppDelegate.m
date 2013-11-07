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
    
    NSArray *array = @[@"a1",@"b2",@"c3",@"d4",@"f5",@"g6"];
    [NSKeyedArchiver archiveRootObject:array toFile:@"/Users/Martin/Development/Objective-C/MTKResource/Example/Resources/Object.XMLArchive.plist"];
    
//    NSMutableData *archive = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archive];
//    archiver.outputFormat = NSPropertyListBinaryFormat_v1_0;
//    [archiver encodeRootObject:array];
//    [archiver finishEncoding];
//    [archive writeToFile:@"/Users/Martin/Desktop/archive.plist" atomically:YES];
    
    
    
    [[MTKResource shared] pathForFile:@"File" directory:nil extensions:@[@"data",@"txt"]];
    
    MTKResource.shared.stringsPrefix = @"Prefix.";
    MTKResource.String(@"Resource.Message");
    
    MTKResource.shared.imagesPrefix = @"Image.";
    MTKResource.Image(@"Square");
    
    MTKResource.shared.objectsPrefix = @"Object.";
    MTKResource.Object(@"XMLArchive");
    
    return YES;
}





@end


