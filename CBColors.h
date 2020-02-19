@interface Colour : NSObject
@property int r, g, b, d;
@end

@interface UIImage (CozyBadges)
- (UIColor *)averageColor;
-(int)colourDistance:(Colour *)a andB:(Colour *)b;
@end

@interface UIColor (CozyBadges)
+ (UIColor *)RGBAColorFromHexString:(NSString *)string;
+ (NSString *)hexStringFromColor:(UIColor *)color;
- (BOOL)isDarkColor;
@end
