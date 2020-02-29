@interface RGBPixel : NSObject
@property int r, g, b, d;
@end

@interface UIImage (CozyBadges)
- (UIColor *)averageColor;
-(int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b;
@end

@interface UIColor (CozyBadges)
+ (UIColor *)RGBAColorFromHexString:(NSString *)string;
+ (NSString *)hexStringFromColor:(UIColor *)color;
- (BOOL)isDarkColor;
@end
