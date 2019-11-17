#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface UINavigationItem (CozyBadges)
@property (assign,nonatomic) UINavigationBar * navigationBar;
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

@interface PSTextFieldSpecifier : PSSpecifier
- (void)setPlaceholder:(id)arg1;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(id)allInstalledApplications;
@end

@interface CozBadPerAppSettings : PSListController
@end
