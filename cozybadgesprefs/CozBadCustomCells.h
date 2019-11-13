#import <Preferences/PSTableCell.h>

@interface PSControlTableCell : PSTableCell
@property (nonatomic, retain) UIControl *control;
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface CozBadSwitchTableCell : PSSwitchTableCell
@end

@interface CozBadButtonCell : PSTableCell
@end
