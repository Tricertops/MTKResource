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
        self.language = nil;
        [self loadDeviceSuffixes];
        self.defaultDirectory = nil;
        self.stringsDefaultTableName = nil;
        self.stringsPrefix = nil;
        self.stringsExtensions = @[ @"strings", @"plist" ];
        self.imagesPrefix = nil;
        self.imagesExtensions = @[ @"png", @"jpg", @"jpeg" ];
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


- (void)setDeviceSuffixes:(NSArray *)deviceSuffixes {
    self->_deviceSuffixes = deviceSuffixes ?: @[@""];
    MTKResourceLog_Info(@"Using device suffixes: '%@'", [self->_deviceSuffixes componentsJoinedByString:@", "]);
}


- (void)setLanguage:(NSString *)language {
    self->_language = language;
    MTKResourceLog_Info(@"Using language: '%@'", self->_language ?: @"(system)");
}





#pragma mark Paths


/// Used for printing paths so bundle path is ommited.
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
    if ( ! path) MTKResourceLog_Debug(@"Path does not exist: '%@/%@.%@'", directory ?: @"", file, extension);
    return path;
}


- (NSString *)pathForFile:(NSString *)file directory:(NSString *)directory extensions:(NSArray *)extensions {
    NSString *path = nil;
    
    MTKResourceLog_Debug(@"Finding path for file '%@' in directory '%@' with extensions '%@'", file, directory ?: @"/", [extensions componentsJoinedByString:@", "]);
    
    for (NSString *suffix in self.deviceSuffixes) {
        NSString *fullFilename = [NSString stringWithFormat:@"%@%@", file, suffix];
        for (NSString *extension in extensions) {
            path = [self bundlePathForFile:fullFilename extension:extension directory:directory];
            if (path) break;
        }
        if (path) break;
    }
    
    if (path) MTKResourceLog_Info(@"File '%@' found at path '%@'", file, [self pathWithinBundle:path]);
    else MTKResourceLog_Warning(@"File not found: '%@'", file);
    
    return path;
}


- (NSString *)pathForFile:(NSString *)fileWithExtension {
    NSString *file = [fileWithExtension stringByDeletingPathExtension];
    NSString *extension = [fileWithExtension pathExtension];
    return [self pathForFile:file directory:self.defaultDirectory extensions:@[extension]];
}


+ (NSString *(^)(NSString *))Path {
    return ^NSString *(NSString *file) {
        return [[self shared] pathForFile:file];
    };
}


- (void)setDefaultDirectory:(NSString *)defaultDirectory {
    self->_defaultDirectory = defaultDirectory;
    MTKResourceLog_Info(@"Using default directory: '%@'", self->_defaultDirectory ?: @"(root)");
}





#pragma mark Strings


- (NSString *)pathForStringsTable:(NSString *)tableName {
    if ( ! tableName.length) return nil;
    NSString *dedicatedFile = [NSString stringWithFormat:@"%@%@", (self.stringsPrefix ?: @""), tableName];
    return [self pathForFile:dedicatedFile directory:self.defaultDirectory extensions:self.stringsExtensions];
}


- (NSString *)stringForKey:(NSString *)stringKey {
    if ( ! stringKey.length) return nil;
    MTKResourceLog_Debug(@"Localizing string for key '%@'", stringKey);
    
    NSString *path = nil;
    
    NSArray *keyComponents = [stringKey componentsSeparatedByString:@"."];
    if (keyComponents.count > 1) {
        // Try dedicated table
        path = [self pathForStringsTable:keyComponents.firstObject];
        
        if (path) {
            // If exist, continue with the rest of the key
            keyComponents = [keyComponents subarrayWithRange:NSMakeRange(1, keyComponents.count - 1)];
            stringKey = [keyComponents componentsJoinedByString:@"."];
        }
    }
    
    if ( ! path) path = [self pathForStringsTable:self.stringsDefaultTableName];
    
    NSDictionary *table = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *string = [table objectForKey:stringKey];
    
    if (string) MTKResourceLog_Info(@"String '%@' localized to '%@'", stringKey, string);
    else MTKResourceLog_Warning(@"String not found '%@'", stringKey);
    
    return string;
}


+ (NSString *(^)(NSString *))String {
    return ^NSString *(NSString *stringKey) {
        return [[self shared] stringForKey:stringKey];
    };
}


- (void)setStringsDefaultTableName:(NSString *)stringsDefaultTableName {
    self->_stringsDefaultTableName = stringsDefaultTableName ?: @"Localizable";
    MTKResourceLog_Info(@"Using strings default table name: '%@'", self->_stringsDefaultTableName);
}


- (void)setStringsPrefix:(NSString *)stringsPrefix {
    self->_stringsPrefix = stringsPrefix;
    MTKResourceLog_Info(@"Using strings prefix: '%@'", self->_stringsPrefix ?: @"(none)");
}


- (void)setStringsExtensions:(NSArray *)stringsExtensions {
    self->_stringsExtensions = stringsExtensions ?: @[@""];
    MTKResourceLog_Info(@"Using strings extensions: '%@'", [self->_stringsExtensions componentsJoinedByString:@", "]);
}





#pragma mark Images


- (UIImage *)imageForKey:(NSString *)imageKey {
    NSString *dedicatedFile = [NSString stringWithFormat:@"%@%@", (self.imagesPrefix ?: @""), imageKey];
    NSString *path = [self pathForFile:dedicatedFile directory:self.defaultDirectory extensions:self.imagesExtensions];
    return [UIImage imageWithContentsOfFile:path];
}


+ (UIImage *(^)(NSString *))Image {
    return ^UIImage *(NSString *imageKey) {
        return [[self shared] imageForKey:imageKey];
    };
}


- (void)setImagesPrefix:(NSString *)imagesPrefix {
    self->_imagesPrefix = imagesPrefix ?: @"";
    MTKResourceLog_Info(@"Using images prefix: '%@'", self->_imagesPrefix);
}


- (void)setImagesExtensions:(NSArray *)imagesExtensions {
    self->_imagesExtensions = imagesExtensions ?: @[@""];
    MTKResourceLog_Info(@"Using images extensions: '%@'", [self->_imagesExtensions componentsJoinedByString:@", "]);
}






@end
