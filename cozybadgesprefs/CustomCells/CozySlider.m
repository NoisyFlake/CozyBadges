#import "../CozyHeaders.h"
#import <Preferences/PSSliderTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface UIView (Private)
-(UIViewController *)_viewControllerForAncestor;
@end

@interface CozySlider : PSSliderTableCell
- (NSNumber *)controlValue;
@end


@interface UITextField (NumericInput)
- (void)addNumericAccessory:(BOOL)addPlusMinus;
- (void)plusMinusPressed;
@end

NSString *stringFromFloatRoundedToDecimalPlaces(NSUInteger decimalPlaces, float floatValue) {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = decimalPlaces;
    formatter.roundingMode = NSNumberFormatterRoundUp;

    return [formatter stringFromNumber:@(floatValue)];
}

@implementation CozySlider

- (void)layoutSubviews {
    [super layoutSubviews];

    UILabel *label = (UILabel *)self.subviews[0].subviews[0].subviews[0].subviews[0];
    label.translatesAutoresizingMaskIntoConstraints = false;
    [label.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [label.rightAnchor constraintEqualToAnchor: self.contentView.rightAnchor constant: -10].active = true;

}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    NSMutableArray *gestureRecognizers = [self.control valueForKey:@"_gestureRecognizers"];
    if (gestureRecognizers == nil) {
        gestureRecognizers = [NSMutableArray array];
        [self.control setValue:gestureRecognizers forKey:@"_gestureRecognizers"];
    }

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // Setting minimum track color
    UISlider *slider = (UISlider *)self.control;
    slider.minimumTrackTintColor = kCOZYCOLOR;
}

- (void)tapped {

    UISlider *slider = (UISlider *)self.control;
    NSString *minVal = stringFromFloatRoundedToDecimalPlaces(2, slider.minimumValue);
    NSString *maxVal = stringFromFloatRoundedToDecimalPlaces(2, slider.maximumValue);

    // Change text format to "Min Value: x • Max Value: y"
    NSString *message = [NSString stringWithFormat:@"Min Value: %@ • Max Value: %@", minVal, maxVal];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Slider Value" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = stringFromFloatRoundedToDecimalPlaces(2, [self.controlValue floatValue]);
        textField.placeholder = stringFromFloatRoundedToDecimalPlaces(2, [self.controlValue floatValue]);
        textField.keyboardType = UIKeyboardTypeDecimalPad;

        [textField addNumericAccessory: true];
    }];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputText = [[alertController textFields][0] text];
        float textFieldValue = [[inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        UISlider *slider = (UISlider *)self.control;

        if (!isnan(textFieldValue)) {
            if (textFieldValue >= slider.minimumValue && textFieldValue <= slider.maximumValue) {
                [slider setValue:textFieldValue animated: true];
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.noisyflake.cozybadgesprefs"];
                [userDefaults setObject:@(textFieldValue) forKey:self.specifier.identifier];
                [userDefaults synchronize];
            } else {
                UIAlertController *invalidValueAlert = [UIAlertController alertControllerWithTitle:@"Invalid Value"
                                                                                           message:@"Entered value is outside the valid range."
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                [invalidValueAlert addAction:okAction];
                [self._viewControllerForAncestor presentViewController:invalidValueAlert animated:YES completion:nil];
            }
        } else {
            UIAlertController *invalidInputAlert = [UIAlertController alertControllerWithTitle:@"Invalid Input"
                                                                                       message:@"Please enter a valid number."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [invalidInputAlert addAction:okAction];
            [self._viewControllerForAncestor presentViewController:invalidInputAlert animated:YES completion:nil];
        }
    }];

    [alertController addAction:confirmAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    [self._viewControllerForAncestor presentViewController:alertController animated:YES completion:nil];
}

@end

@implementation UITextField (NumericAccessory)

- (void)addNumericAccessory:(BOOL)addPlusMinus {
    UIToolbar *numberToolbar = [[UIToolbar alloc] init];
    numberToolbar.barStyle = UIBarStyleDefault;

    NSMutableArray *accessories = [[NSMutableArray alloc] init];

    if (addPlusMinus) {
        [accessories addObject:[[UIBarButtonItem alloc] initWithTitle:@"+/-"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(plusMinusPressed)]];
        [accessories addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil]]; // add padding after
    }

    [numberToolbar setItems:accessories];
    [numberToolbar sizeToFit];

    [self setInputAccessoryView:numberToolbar];
}

- (void)plusMinusPressed {
    NSString *currentText = [self text];
    if (currentText) {
        if ([currentText hasPrefix:@"-"]) {
            NSString *substring = [currentText substringFromIndex:1];
            [self setText:substring];
        } else {
            NSString *newText = [NSString stringWithFormat:@"-%@", currentText];
            [self setText:newText];
        }
    }
}

@end
