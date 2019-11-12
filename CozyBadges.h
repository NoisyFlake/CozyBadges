@interface SBIcon : NSObject
-(BOOL)isFolderIcon;
-(long long)badgeValue;
-(UIImage*)unmaskedIconImageWithInfo:(id)info;
@end

@interface SBLeafIcon : SBIcon
@end

@interface SBApplicationIcon : SBLeafIcon
@end

@interface SBIconLabelImageParameters : NSObject
-(id)initWithParameters:(SBIconLabelImageParameters *)params;
@end

@interface CBIconLabelImageParameters : SBIconLabelImageParameters
// @property (nonatomic, retain) SBFolderIcon *folderIcon;
@property (nonatomic, retain) SBApplicationIcon *icon;
-(id)initWithParameters:(SBIconLabelImageParameters *)params icon:(SBIcon *)icon;
// -(SBApplicationIcon *)mainIconForFolder:(SBIcon *)folderIcon;
@end

@interface _UILegibilitySettings : NSObject
@end

@interface SBIconView : UIView
@property (nonatomic,retain) SBIcon * icon;
@property (nonatomic,retain) _UILegibilitySettings * legibilitySettings;
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
