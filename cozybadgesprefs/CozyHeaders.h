#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define kCOZYCOLOR [UIColor colorWithRed:0.58 green:0.44 blue:0.75 alpha:1.0]

@interface NSTask : NSObject
- (instancetype)init;
- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)setStandardOutput:(id)output;
- (void)launch;
- (void)waitUntilExit;
@end

@interface UINavigationItem (CozyBadges)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface UIColor (CozyBadgesPrefs)
@property(class, nonatomic, readonly) UIColor *labelColor;
@property(class, nonatomic, readonly) UIColor *systemGrayColor;
@end

@interface LSApplicationProxy
@property (nonatomic,readonly) NSString * applicationType;
@property (nonatomic,readonly) NSString * applicationIdentifier;
@property (getter=isRestricted,nonatomic,readonly) BOOL restricted;
@property (nonatomic,readonly) NSArray * appTags;
@property (getter=isLaunchProhibited,nonatomic,readonly) BOOL launchProhibited;
@property (getter=isPlaceholder,nonatomic,readonly) BOOL placeholder;
@property (getter=isRemovedSystemApp,nonatomic,readonly) BOOL removedSystemApp;
-(id)localizedNameForContext:(id)arg1 ;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(id)allInstalledApplications;
@end

@interface PSTextFieldSpecifier : PSSpecifier
- (void)setPlaceholder:(id)arg1;
@end

@interface PSListController (CozyBadges)
- (void)_returnKeyPressed:(id)arg1;
@end

@interface CozyBaseController : PSListController
- (NSMutableArray *)dynamicSpecifiersFromPlist:(NSString *)plist;
@end

@interface CozyPerAppSettings : CozyBaseController
@end

@interface CozyRegularController : CozyBaseController
@end

@interface CozyNotificationController : CozyBaseController
@end

@interface CozyRootListController : CozyBaseController
@end

@interface CozyColorPickerCell : PSTableCell
@end