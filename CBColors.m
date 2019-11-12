#import "CBColors.h"

@implementation UIImage (CozyBadges)
- (UIColor *)averageColor {

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                        green:((CGFloat)rgba[1])*multiplier
                        blue:((CGFloat)rgba[2])*multiplier
                        alpha:alpha];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                        green:((CGFloat)rgba[1])/255.0
                        blue:((CGFloat)rgba[2])/255.0
                        alpha:((CGFloat)rgba[3])/255.0];
    }
}
@end

@implementation UIColor (CozyBadges)
+(UIColor *)RGBAColorFromHexString:(NSString *)string {
    if(string.length == 0) {
        return [UIColor blackColor];
    }

    CGFloat alpha = 1.0;
    NSUInteger location = [string rangeOfString:@":"].location;
    NSString *hexString;

    if(location != NSNotFound) {
        alpha = [[string substringFromIndex:(location + 1)] floatValue];
        hexString = [string substringWithRange:NSMakeRange(0, location)];
    } else {
        hexString = [string copy];
    }

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];

    if([hexString rangeOfString:@"#"].location == 0) {
        [scanner setScanLocation:1];
    }

    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
                    green:((rgbValue & 0xFF00) >> 8) / 255.0
                    blue:(rgbValue & 0xFF) / 255.0
                    alpha:alpha];
}
@end
