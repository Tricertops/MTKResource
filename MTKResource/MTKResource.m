//
//  MTKResource.m
//  MTKResource
//
//  Created by Martin Kiss on 26.4.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "MTKResource.h"





@interface MTKResource ()

@property (nonatomic, readwrite, copy) NSArray *deviceSuffixes;

@end










@implementation MTKResource





#pragma mark Creation


+ (instancetype)shared {
    static MTKResource *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MTKResource alloc] init];
    });
    return shared;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadDeviceSuffixes];
    }
    return self;
}


- (void)loadDeviceSuffixes {
    NSMutableArray *suffixes = [[NSMutableArray alloc] init];
    
    BOOL iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    BOOL fourInch = ([[UIScreen mainScreen] bounds].size.height >= 568);
    BOOL retina = ([[UIScreen mainScreen] scale] == 2);
    
    NSArray *heights = (iPhone && fourInch ? @[@"-568h", @""] : @[@""] );
    NSArray *idioms = ( iPhone ? @[@"~iphone", @""] : @[@"~ipad", @""] );
    NSArray *scales = ( retina ? @[@"@2x", @""] : @[@"", @"@2x"] );
    
    for (NSString *height in heights) {
        for (NSString *idiom in idioms) {
            for (NSString *scale in scales) {
                NSString *suffix = [NSString stringWithFormat:@"%@%@%@", height, scale, idiom];
                [suffixes addObject:suffix];
            }
        }
    }
    
    self.deviceSuffixes = suffixes;
}





#pragma mark Paths


- (NSString *)pathWithinBundle:(NSString *)path {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    return [path stringByReplacingOccurrencesOfString:bundlePath withString:@""];
}



- (NSString *)bundlePathForFile:(NSString *)file extension:(NSString *)extension directory:(NSString *)directory {
    NSString *path = nil;
    if (self.language) {
        path = [[NSBundle mainBundle] pathForResource:file ofType:extension inDirectory:directory forLocalization:self.language];
    }
    else {
        path = [[NSBundle mainBundle] pathForResource:file ofType:extension inDirectory:directory];
    }
    if ( ! path) MTKResourceLog_Debug(@"Path '%@/%@.%@' does not exist", directory ?: @"", file, extension);
    return path;
}



- (NSString *)pathForFile:(NSString *)file directory:(NSString *)directory extensions:(NSArray *)extensions {
    NSString *path = nil;
    
    MTKResourceLog_Debug(@"Finding path for file '%@' in directory '%@' with extensions '%@'", file, directory ?: @"/", [extensions componentsJoinedByString:@","]);
    
    for (NSString *suffix in self.deviceSuffixes) {
        NSString *fullFilename = [NSString stringWithFormat:@"%@%@", file, suffix];
        for (NSString *extension in extensions) {
            path = [self bundlePathForFile:fullFilename extension:extension directory:directory];
            if (path) break;
        }
        if (path) break;
    }
    
    if (path) MTKResourceLog_Info(@"File '%@' found path '%@'", file, [self pathWithinBundle:path]);
    else MTKResourceLog_Warning(@"File not found '%@'", file);
    
    return path;
}


- (NSString *)pathForFile:(NSString *)fileWithExtension {
    NSString *file = [fileWithExtension stringByDeletingPathExtension];
    NSString *extension = [fileWithExtension pathExtension];
    return [self pathForFile:file directory:self.defaultDirectory extensions:@[extension]];
}





@end
