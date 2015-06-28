//
//  MHTextField.h
//
//  Created by Subin Kurian on 4/11/13.
//  Copyright (c) 2013 Subin Kurian. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MHDelegate <NSObject>
@optional -(void)MHTextfieldEndEditing :(UITextField *)textField;   // delegate for textfield
@end

@interface MHTextField : UITextField<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) BOOL required;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *dateFormat;
@property(nonatomic,strong) NSArray *dropArray;
@property(nonatomic,strong)UITableView *dropTable;
@property (nonatomic, setter = setEmailField:) BOOL isEmailField;
@property (nonatomic, setter = setMobileField:) BOOL isMobileField;
@property (nonatomic, setter = setNumberField:) BOOL isNumberField;
@property (nonatomic, setter = setDateField:) BOOL isDateField;
@property (nonatomic, setter = setTimeField:) BOOL isTimeField;
@property (nonatomic, setter = setAmountField:) BOOL isAmountField;
@property (nonatomic, setter = setConfirmPasswordField:) BOOL isConfirmPasswordField;
@property (nonatomic, setter = setDropboxField:) BOOL isDropboxField;
@property (nonatomic, readonly) BOOL isValid;
@property(nonatomic,strong) NSString *dropUrl;
- (BOOL) validate; // validating the textfield
- (void) setDateFieldWithFormat:(NSString *)dateFormat;// setting text field as date field

/*
 Invoked when text field is disabled or input is invalid. Override to set your own tint or background color.
 */
- (void) setNeedsAppearance:(id)sender;

@end
