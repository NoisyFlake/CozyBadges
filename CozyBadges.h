@interface SBIcon : NSObject
-(BOOL)isFolderIcon;
-(long long)badgeValue;
-(UIImage*)unmaskedIconImageWithInfo:(id)info;
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

@interface CBIconLabelImageParameters : SBIconLabelImageParameters
@property (nonatomic, retain) SBIcon *folderIcon;
@property (nonatomic, retain) SBIcon *icon;
-(id)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon;
-(SBApplicationIcon *)iconForFolder:(SBIcon *)folderIcon;
-(UIColor *)focusHighlightColor;
@end

@interface _UILegibilitySettings : NSObject
@end

@interface SBIconView : UIView
@property (nonatomic,retain) SBIcon * icon;
@property (nonatomic,retain) _UILegibilitySettings * legibilitySettings;
@property (assign,getter=isLabelHidden,nonatomic) BOOL labelHidden;
-(SBIconLabelImageParameters *)_labelImageParameters;
@end

@interface _UILegibilityView : UIView
@property (nonatomic,retain) UIImageView * imageView;
@property (nonatomic,retain) UIImage * image;
@end

@interface SBIconLabelImage : UIImage
@end

@interface SBIconLabelImage (CozyBadges)
+(id)imageWithParameters:(id)arg1;
@end

@interface SBIconLabelView : _UILegibilityView
-(void)updateIconLabelWithSettings:(id)arg1 imageParameters:(id)arg2;
@end

@interface SBIconListView : UIView
-(NSArray *)icons;
@end

@interface SBDockIconListView : SBIconListView
@end

typedef struct SBIconCoordinate {
    long long row;
    long long col;
} SBIconCoordinate;

static BOOL getBool(NSString *key);
static NSString* getValue(NSString *key);
