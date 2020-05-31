@interface RGBPixel : NSObject
@property int r, g, b, d;
@end

@interface UIImage (CozyBadges)
- (UIColor *)cozyDominantColor;
-(int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b;
@end

@interface UIColor (CozyBadges)
+ (UIColor *)cozyRGBAColorFromHexString:(NSString *)string;
+ (NSString *)cozyHexStringFromColor:(UIColor *)color;
- (BOOL)cozyIsDarkColor;
@end
