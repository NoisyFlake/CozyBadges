#import "CBColors.h"

@implementation Colour
@end

@implementation UIImage (CozyBadges)
- (UIColor *)averageColor {
    NSLog(@"start");

    //1. set vars
    float dimension = 20;
    int edge = 5;

    //2. resize image and grab raw data
    //this part pulls the raw data from the image
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

    int countedPixels = 0;

    //3. create colour array
    NSMutableArray * colours = [NSMutableArray new];
    float x = 0, y = 0; //used to set coordinates
    float eR = 0, eB = 0, eG = 0; //used for mean edge colour
    for (int n = 0; n<(dimension*dimension); n++){

        Colour * c = [Colour new]; //create colour
        int i = (bytesPerRow * y) + x * bytesPerPixel; //pull index
        c.r = rawData[i]; //set red
        c.g = rawData[i + 1]; //set green
        c.b = rawData[i + 2]; //set blue
        if (rawData[i + 3] > 127) {
            [colours addObject:c]; //add colour

            //add to edge if true
            if ((edge == 0 && y == 0) || //top
                (edge == 1 && x == 0) || //left
                (edge == 2 && y == dimension-1) || //bottom
                (edge == 3 && x == dimension-1) ||
                edge == 5) { //right
                eR+=c.r; eG+=c.g; eB+=c.b; //add the colours
                countedPixels++;
            }
        }

        //update pixel coordinate
        x = (x == dimension - 1) ? 0 : x+1;
        y = (x == 0) ? y+1 : y;

    }
    free(rawData);

    NSLog(@"CozyBadges got here");

    //4. calculate edge colour
    Colour * e = [Colour new];
    e.r = eR/countedPixels;
    e.g = eG/countedPixels;
    e.b = eB/countedPixels;

    //5. calculate the frequency of colour
    NSMutableArray * accents = [NSMutableArray new]; //holds valid accents

    float minContrast = 1; //play with this value
    while (accents.count < 1) { //minimum number of accents
        for (Colour * a in colours){

            //NSLog(@"contrast value is %f", [self contrastValueFor:a andB:e]);

            //5.1 ignore if it does not contrast with edge
            if ([self contrastValueFor:a andB:e] < minContrast){ continue;}

            //5.2 set distance (frequency)
            for (Colour * b in colours){
                a.d += [self colourDistance:a andB:b];
            }

            //5.3 add colour to accents
            [accents addObject:a];
        }

        minContrast-=0.1f;
    }

    NSLog(@"CozyBadges got here too");

    //6. sort colours by the most common
    NSArray * sorted = [[NSArray arrayWithArray:accents] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"d" ascending:true]]];

    //6.1 set primary colour (most common)
    Colour * p = sorted[0];

    //7. get most contrasting colour
    float high = 0.0f; //the high
    int index = 0; //the index
    for (int n = 1; n < sorted.count; n++){

        Colour * c = sorted[n];
        float contrast = [self contrastValueFor:c andB:p];
        //float sat = [self saturationValueFor:c andB:p];

        if (contrast > high){
            high = contrast;
            index = n;
        }
    }
    //7.1 set secondary colour (most contrasting)
    Colour * s = sorted[index];

    NSMutableDictionary * result = [NSMutableDictionary new];
    [result setValue:[UIColor colorWithRed:e.r/255.0f green:e.g/255.0f blue:e.b/255.0f alpha:1.0f] forKey:@"background"];
    [result setValue:[UIColor colorWithRed:p.r/255.0f green:p.g/255.0f blue:p.b/255.0f alpha:1.0f] forKey:@"primary"];
    [result setValue:[UIColor colorWithRed:s.r/255.0f green:s.g/255.0f blue:s.b/255.0f alpha:1.0f] forKey:@"secondary"];

    // return [UIColor colorWithRed:e.r/255.0f green:e.g/255.0f blue:e.b/255.0f alpha:1.0f];
    // return [UIColor colorWithRed:p.r/255.0f green:p.g/255.0f blue:p.b/255.0f alpha:1.0f];
    // return [UIColor colorWithRed:s.r/255.0f green:s.g/255.0f blue:s.b/255.0f alpha:1.0f];

    UIColor *average = [UIColor colorWithRed:e.r/255.0f green:e.g/255.0f blue:e.b/255.0f alpha:1.0f];
    UIColor *contrast = [UIColor colorWithRed:s.r/255.0f green:s.g/255.0f blue:s.b/255.0f alpha:1.0f];

    CGFloat averageSat;
    CGFloat contrastSat;
    CGFloat averageBr;
    CGFloat contrastBr;



    [average getHue:nil saturation:&averageSat brightness:&averageBr alpha:nil];
    [contrast getHue:nil saturation:&contrastSat brightness:&contrastBr alpha:nil];

    NSLog(@"CozyBadges contrastSat: %f avgSat: %f", contrastSat, averageSat);

    // return average;

    return (contrastSat > averageSat && contrastBr > 0.2) ? contrast : average;

}

-(float)contrastValueFor:(Colour *)a andB:(Colour *)b {
    float aL = 0.2126 * a.r + 0.7152 * a.g + 0.0722 * a.b;
    float bL = 0.2126 * b.r + 0.7152 * b.g + 0.0722 * b.b;
    return (aL>bL) ? (aL + 0.05) / (bL + 0.05) : (bL + 0.05) / (aL + 0.05);
}
-(float)saturationValueFor:(Colour *)a andB:(Colour *)b {
    float min = MIN(a.r, MIN(a.g, a.b)); //grab min
    float max = MAX(b.r, MAX(b.g, b.b)); //grab max
    return (max - min)/max;
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

    return (colorBrightness < 0.55);
}
@end
