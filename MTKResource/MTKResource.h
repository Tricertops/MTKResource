//
//  MTKResource.h
//  MTKResource
//
//  Created by Martin Kiss on 26.4.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



#define MTKResourceLog_Error(FORMAT...)     NSLog(@"MTKResource Error: "    FORMAT)
#define MTKResourceLog_Warning(FORMAT...)   NSLog(@"MTKResource Warning: "  FORMAT)
#define MTKResourceLog_Info(FORMAT...)      NSLog(@"MTKResource Info: "     FORMAT)
#define MTKResourceLog_Debug(FORMAT...)     //NSLog(@"MTKResource Debug: "    FORMAT)



/**
 Hello, I am class designed to help you with loading any kind of resources in
 your apps. I handle different languages, devices and extensions, so you don't
 have to bother with them in code.
 **/
@interface MTKResource : NSObject

/**
 Shared single instance. Me.
 **/
+ (instancetype)shared;



#pragma mark General

/**
 By setting this property you tell me what language should I load, I do
 fallbacks to non-localized resource in case there is none for this language.
 
 Please, use ISO language codes, see +[NSLocale ISOLanguageCodes].
 
 In case you use iOS default localization mechanism, set the value to nil.
 **/
@property (nonatomic, readwrite, copy) NSString *language;



#pragma mark Paths

/**
 Universal method to find resources. You specify multiple extansions and the
 first found is returned. This method will take into account suffixes "@2x",
 "-568", "~iphone", "~ipad" and also localization subdirectories.
 
 @param file        Name for the file without the extension
 @param directory   Path to the directory, where the file should be searched.
                    Specify `nil` for bundle root.
 @param extensions  Array of all extensions to try when searching for the file.
 
 Example: This will search for "Train.png" and if that does not exist, fallbacks
 to "Train.jpg". If that does not exist, returns nil.
 @code
     [MTKResource.shared pathForFile:@"Train"
                           directory:nil
                          extensions:@[ @"png", @"jpg" ];
 @endcode
 
 If fact, this example look up these files in order (assuming iPhone 5):
 Train-568@2x~iphone.png
 Train-568@2x~iphone.jpg
 Train-568@2x.png
 Train-568@2x.jpg
 Train-568~iphone.png
 Train-568~iphone.jpg
 Train-568.png
 Train-568.jpg
 Train@2x~iphone.png
 Train@2x~iphone.jpg
 Train@2x.png
 Train@2x.jpg
 Train~iphone.png
 Train~iphone.jpg
 Train.png
 Train.jpg
 **/
- (NSString *)pathForFile:(NSString *)file directory:(NSString *)directory extensions:(NSArray *)extensions;

/**
 Convenience method for finding files. This method will split the name and
 extension, and call the above method `-pathForFile:directory:extensions:` with
 default directory as specified in -[MTKResource defaultDirectory] below.
 
 @param fileWithExtension   Full file name, e.g. "Train.png".
 
 **/
- (NSString *)pathForFile:(NSString *)fileWithExtension;

/**
 Convenience method for `-pathForFile:`.
 @code
 MTKResource.Path(@"List.txt");
 @endcode
 */
+ (NSString *(^)(NSString *file))Path;

/**
 Default directory path to be used by convenience methods. Default is nil, that means bundle's root is searched.
 **/
@property (nonatomic, readwrite, copy) NSString *defaultDirectory;





#pragma mark Strings

/**
 Loads localized string from .strings file.
 
 @param stringKey String identifier. Can be composed of multiple dot-separated
                  keys, just like key-paths.
 
 Example: If key is "MainMenu.LoginButton.Title", method searches for file
 "MainMenu.strings" and key "LoginButton.Title" inside. In case that file is not
 found, it fallbacks to `stringsDefaultTableName`, which is default
 "Localizable", and searches "Localizable.strings" for full key
 "MainMenu.LoginButton.Title".
 */
- (NSString *)stringForKey:(NSString *)stringKey;

/**
 Convenience method for `-stringForKey:`.
 @code
    MTKResource.String(@"key.of.the.string");
 @endcode
 */
+ (NSString *(^)(NSString *stringKey))String;

/**
 Default .strings file name without the extension.
 Default value is "Localizable".
 */
@property (nonatomic, readwrite, copy) NSString *stringsDefaultTableName;

/**
 Prefix you use in whole project for .strings files.
 File name pattern: <stringsPrefix><tableName><deviceSuffixes>.<extensions>
 */
@property (nonatomic, readwrite, copy) NSString *stringsPrefix;

/**
 File extensions to be treated like files for localizing strings.
 There is no need to set this property, default is [ "strings", "plist" ].
 Loading strings works with standard .strings files, but also with .plist,
 whose root object is Dictionary and contains string key-value pairs.
 */
@property (nonatomic, readwrite, copy) NSArray *stringsExtensions;





#pragma mark Images

/**
 Loads image from file.
 
 @param imageKey Image file name, without extension, device suffixes or commmon
                 prefix (after setting `imagePrefix` property).
 
 Searches for this file name pattern:
 <imagePrefix><imageKey><deviceSuffixes>.<extensions>
 
 If your image file has name "mainmenu-loginbutton@2x~iphone.png", just
 provide "mainmenu-loginbutton" as image key.
 */
- (UIImage *)imageForKey:(NSString *)imageKey;

/**
 Convenience method for `-imageForKey:`.
 @code
    MTKResource.Image(@"key.for.the.image");
 @endcode
 */
+ (UIImage *(^)(NSString *imageKey))Image;

/**
 Prefix you use in whole project for image files.
 File name pattern: <imagePrefix><imageKey><deviceSuffixes>.<extensions>
 */
@property (nonatomic, readwrite, copy) NSString *imagesPrefix;

/**
 Array of all image extensions to be searched when asked for `-imageForKey:`.
 File name comparisions are case insensitive.
 Default: [ "png", "jpg", "jpeg" ]
 
 You shouldn't have multiple images with the same file name and different extension,
 like "button.png" and "button.jpg".
 */
@property (nonatomic, readwrite, copy) NSArray *imagesExtensions;





#pragma mark Object

/**
 Loads "some object" from file. Can be used for loading .plist, .json, custom
 archives (using NSCoding).
 
 @param objectKey Base of the file name without extension, prefixes and so on.
 
 Searches for this file name pattern:
 <objectPrefix><objectKey><deviceSuffixes>.<extensions>
 
 This method supports loading of Property Lists, JSON files, NSKeyedArchiver
 files.
 
 Example: If you ask for "VideoPresets" object, this method searches for
 "VideoPresets.plist", "VideoPresets.json" (and so on, based on the allowed
 extensions) and loads the first found using appropriate deserializer. Returns
 whatever it loaded, in this case it may be NSArray from the plist.
 
 TODO: make it extensible.
 */
- (id)objectForKey:(NSString *)objectKey;

/**
 Convenience method for `-objectForKey:`.
 @code
    MTKResource.Object(@"key.for.the.object");
 @endcode
 */
+ (id(^)(NSString *objectKey))Object;

/**
 Prefix you use in whole project for image files.
 File name pattern: <imagePrefix><imageKey><deviceSuffixes>.<extensions>
 */
@property (nonatomic, readwrite, copy) NSString *objectsPrefix;

/**
 Array of all extensions to be searched when asked for `-objectForKey:`. If you
 use custom extension for archives (NSKeyedArchiver), set this property
 approapriately.
 Default: [ "plist", "json" ]
 */
@property (nonatomic, readwrite, copy) NSArray *objectsExtensions;





@end
