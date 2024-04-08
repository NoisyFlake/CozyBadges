#import "../CozyHeaders.h"

NSString *getVersion() {
    if (FINAL == 0) {
        return @"Pre-Release Test";
    } else return PACKAGE_VERSION;
}

@implementation CozyHeader

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];
    if (self) {
        UILabel *tweakName = [[UILabel alloc] init];
        tweakName.text = @"COZYBADGES";
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:34.0f];
        tweakName.textColor = kCOZYCOLOR;
        tweakName.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:tweakName];

        UILabel *version = [[UILabel alloc] init];
        version.text = [NSString stringWithFormat:@"Version %@", getVersion()];
        version.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        version.textColor = UIColor.systemGrayColor;
        version.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:version];

        // Anchoring logic to the left side
        [NSLayoutConstraint activateConstraints:@[
            [tweakName.topAnchor constraintEqualToAnchor:self.topAnchor constant:23],
            [tweakName.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:90], // Adjust left margin here

            [version.topAnchor constraintEqualToAnchor:tweakName.bottomAnchor constant:10],
            [version.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:140] // Adjust left margin here
        ]];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return 100.0f;
}

@end
