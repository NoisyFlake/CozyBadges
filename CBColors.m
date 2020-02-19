#import "CBColors.h"

@implementation Colour
@end

@implementation UIImage (CozyBadges)
- (UIColor *)averageColor {
    NSLog(@"start");

    float dimension = self.size.width / 2;
    int tolerance = 8;
    int minAlpha = 255;

    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * dimension;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
    CGContextRelease(context);

    NSMutableArray * colours = [NSMutableArray new];
    float x = 0, y = 0; //used to set coordinates
    for (int n = 0; n<(dimension*dimension); n++){

        int i = (bytesPerRow * y) + x * bytesPerPixel; //pull index

        // Ignore transparent pixels
        if (rawData[i + 3] >= minAlpha) {

            Colour * c = [Colour new];
            c.r = rawData[i];
            c.g = rawData[i + 1];
            c.b = rawData[i + 2];

            bool colorExists = false;
            for (Colour *color in colours) {
                int distance = [self colourDistance:c andB:color];

                if (distance < tolerance) {
                    color.d+= distance;

                    colorExists = true;
                }
            }

            if (!colorExists) [colours addObject:c];
        }

        //update pixel coordinate
        x = (x == dimension - 1) ? 0 : x+1;
        y = (x == 0) ? y+1 : y;

    }
    free(rawData);

    if (colours.count == 0) return [UIColor clearColor];

    NSArray * sorted = [[NSArray arrayWithArray:colours] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"d" ascending:false]]];

    Colour *mostDominant = sorted[0];
    return [UIColor colorWithRed:mostDominant.r/255.0f green:mostDominant.g/255.0f blue:mostDominant.b/255.0f alpha:1.0f];
}

-(int)colourDistance:(Colour *)a andB:(Colour *)b {
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
