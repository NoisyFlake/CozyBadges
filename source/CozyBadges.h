#define isIconInDock ([self.location isEqual:@"SBIconLocationDock"] || [self.location isEqual:@"SBIconLocationFloatingDock"] || [self.location isEqual:@"SBIconLocationFloatingDockSuggestions"])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

typedef struct SBIconImageInfo {
    CGSize size;
    CGFloat optionA;
    CGFloat optionB;
} SBIconImageInfo;

@interface CozyPrefs : NSObject
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) NSDictionary *defaultSettings;
+ (id)sharedInstance;
- (id)init;
-(BOOL)boolForKey:(NSString *)key;
-(NSString *)valueForKey:(NSString *)key;
@end

@interface NSObject (Velvet)
- (id)safeValueForKey:(id)arg1;
@end

@interface UIView (CozyBadges)
-(id)_viewControllerForAncestor;
@end

@interface SBRootFolderController : NSObject
-(id)dockIconListView;
@end

@interface SBFloatingDockViewController : NSObject
-(id)currentIconListView;
@end

@interface SBIcon : NSObject
@property (nonatomic,copy,readonly) NSString * applicationBundleID;
-(BOOL)isFolderIcon;
-(long long)badgeValue;
-(UIImage*)unmaskedIconImageWithInfo:(struct SBIconImageInfo)info;
@end

@interface SBLeafIcon : SBIcon
@end

@interface SBApplicationIcon : SBLeafIcon
@end

@interface SBFolder : NSObject
-(id)allIcons;
@end

@interface SBFolderIcon : SBIcon
@property (nonatomic,readonly) SBFolder * folder;
@end

@interface SBIconLabelImageParameters : NSObject
-(id)initWithParameters:(SBIconLabelImageParameters *)params;
@end

@interface _UILegibilitySettings : NSObject
@end

@interface _UILegibilityView : UIView
@property (nonatomic,retain) UIImageView * shadowImageView;
@property (nonatomic,retain) UIImage * shadowImage;
@property (nonatomic,retain) UIImageView * imageView;
@property (nonatomic,retain) UIImage * image;
@end

@interface SBIconLabelView : _UILegibilityView
-(void)updateIconLabelWithSettings:(id)arg1 imageParameters:(id)arg2;
@end

@interface SBIconView : UIView
@property (nonatomic,retain) SBIcon * icon;
@property (nonatomic,retain) _UILegibilitySettings * legibilitySettings;
@property (nonatomic,copy) NSString * location;
@property (nonatomic, assign) BOOL allowsLabelArea;
@property (nonatomic, assign) BOOL labelHidden;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) SBIconLabelView *labelView;
@property (nonatomic, retain) SBFolderIcon *folderIcon;
-(SBIconLabelImageParameters *)_labelImageParameters;
-(BOOL)isLabelHidden;
@end

@interface SBIconLegibilityLabelView : _UILegibilityView
@property (assign,nonatomic) SBIconView * iconView;
@end

@interface SBIconSimpleLabelView : UIImageView
@property (assign,nonatomic) SBIconView * iconView;
@end

@interface CBIconLabelImageParameters : SBIconLabelImageParameters
@property (nonatomic, retain) SBIcon *folderIcon;
@property (nonatomic, retain) SBIcon *icon;
@property (nonatomic, assign) BOOL hasNotification;
@property (nonatomic, assign) int folderNotificationApps;
@property (nonatomic, retain) UIColor *dominantColor;
-(id)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon;
-(SBApplicationIcon *)iconForFolder:(SBIcon *)folderIcon;
-(UIColor *)cozyColorFor:(NSString *)mode;
-(UIColor *)focusHighlightColor;
@end

@interface SBIconLabelImage : UIImage
@end

@interface SBIconLabelImage (CozyBadges)
+(id)imageWithParameters:(id)arg1;
@end

@interface SBIconListView : UIView
-(NSArray *)icons;
-(void)setIconsNeedLayout;
@end

@interface SBDockIconListView : SBIconListView
@end

@interface SBFloatingDockController : NSObject
+(BOOL)isFloatingDockSupported;
@end

@interface SBIconController : UIViewController
+(id)sharedInstance;
-(BOOL)allowsBadgingForIcon:(id)arg1 ;
@end

typedef struct SBIconCoordinate {
    long long row;
    long long col;
} SBIconCoordinate;
