#import "CBColors.h"

@implementation RGBPixel
@end

@implementation UIImage (CozyBadges)
- (UIColor *)averageColor {

    int width = self.size.width;
    int height = self.size.height;

    int limit = 2000;

    if (width * height > limit) {
        float ratio = width / height;
        float maxWidth = sqrtf(ratio * limit);

        width = (int)maxWidth;
        height = (int)(limit / maxWidth);
    }

    int tolerance = 27;

    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;

    unsigned char *rawData = calloc(bytesPerRow * height, sizeof(unsigned char));

    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);


    NSMutableArray *imageColors = [NSMutableArray new];

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {

            int i = (bytesPerRow * y) + x * bytesPerPixel;

            if (rawData[i + 3] < 128) continue;

            RGBPixel *pixel = [RGBPixel new];
            pixel.r = rawData[i];
            pixel.g = rawData[i + 1];
            pixel.b = rawData[i + 2];

            BOOL colorExists = false;
            for (RGBPixel *color in imageColors) {
                int distance = [self colourDistance:pixel andB:color];

                if (distance < tolerance) {
                    colorExists = true;

                    color.r = (int) ((color.r + pixel.r) / 2);
                    color.g = (int) ((color.g + pixel.g) / 2);
                    color.b = (int) ((color.b + pixel.b) / 2);
                    color.d+= distance > 0 ? distance : 1;

                    break;
                }
            }

            if (!colorExists) [imageColors addObject:pixel];

        }
    }

    free(rawData);

    if (imageColors.count == 0) return [UIColor redColor];

    NSArray *sorted = [[NSArray arrayWithArray:imageColors] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"d" ascending:false]]];
    RGBPixel *mostDominant = sorted[0];

    return [UIColor colorWithRed:mostDominant.r/255.0f green:mostDominant.g/255.0f blue:mostDominant.b/255.0f alpha:1.0f];
}

-(int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b {
    return abs(a.r-b.r)+abs(a.g-b.g)+abs(a.b-b.b);
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

+(NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}

- (BOOL)isDarkColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;

    return (colorBrightness < 0.58);
}
@end
