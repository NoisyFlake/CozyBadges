@interface UIImage (CozyBadges)
- (UIColor *)averageColor;
@end

@interface UIColor (CozyBadges)
+ (UIColor *)RGBAColorFromHexString:(NSString *)string;
+ (NSString *)hexStringFromColor:(UIColor *)color;
- (BOOL)isDarkColor;
@end
