//
//  MHTextField.m
//
//  Created by Subin Kurian on 4/11/13.
//  Copyright (c) 2013 Subin Kurian. All rights reserved.
//

#import "MHTextField.h"
#import <Parse/Parse.h>

@interface MHTextField()
{
    UITextField *_textField;
    BOOL _disabled;
    BOOL _enabled;
}

@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic) BOOL hasScrollView;
@property (nonatomic) BOOL invalid;
@property (nonatomic, setter = setToolbarCommand:) BOOL isToolBarCommand;
@property (nonatomic, setter = setDoneCommand:) BOOL isDoneCommand;
@property (nonatomic , strong) UIBarButtonItem *previousBarButton;
@property (nonatomic , strong) UIBarButtonItem *nextBarButton;
@property (nonatomic, strong) NSMutableArray *textFields;
@property (weak) id keyboardDidShowNotificationObserver;
@property (weak) id keyboardWillHideNotificationObserver;
@property (nonatomic,assign)id<MHDelegate>delegate;
@end
@implementation MHTextField
@synthesize required;
@synthesize scrollView;
@synthesize toolbar;
@synthesize keyboardIsShown;
@synthesize keyboardSize;
@synthesize invalid;
@synthesize delegate;
- (void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self markTextFieldsWithTagInView:self.superview];  // setting text view layout
    _enabled = YES;
    if(_isDropboxField)
        [self setDropTable];    // set table frame
    
}
-(void)setDropTable // setting table
{
    CGRect rect= self.frame;
    rect.origin.x=rect.origin.x+4;
    rect.size.width=rect.size.width-8;
    //rect.size.width<260 ?rect.size.width=260 :rect.size.width; // checking whether the minimum length is 200 or not
    rect.origin.y=rect.origin.y+rect.size.height;
    rect.size.height= 44;
    self.dropTable.frame=rect;
}

-(void)initDropTable
{
    
    CGRect rect= self.frame;
    rect.origin.x=rect.origin.x+2;
    rect.size.width=rect.size.width-4;
    rect.origin.y=rect.origin.y+rect.size.height;
    rect.size.height= 44;
    self.dropTable=[[UITableView alloc]initWithFrame:rect];
    [[self superview]addSubview:self.dropTable];
    [self.dropTable setDelegate:self];
    [self.dropTable setDataSource:self];
    
}
#pragma mark DropTable
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier =@"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    UIView *view= [[UIView alloc]initWithFrame:cell.bounds];
    view.backgroundColor=[UIColor clearColor];
    [[view layer] setBorderColor:[UIColor yellowColor].CGColor];
    [[view layer]setBorderWidth:2.0f];
    [[view layer] setCornerRadius:5.0f];
    [[view layer]masksToBounds];
    cell.selectedBackgroundView=view;
 
    cell.textLabel.text=(self.dropArray)[indexPath.row];

    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.text=nil;
    [self resignFirstResponder];
    self.text=(self.dropArray)[indexPath.row];
    [self.dropTable removeFromSuperview];
     self.dropTable=nil;
     [self validate];
}
// scrolling delegate
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self resignFirstResponder];
}

// fetch data from server for drop table
- (void)fetchPlaceResult :(UITextField*)textField {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Account"];
    [query whereKey:@"CustomerNumber" equalTo:[textField.layer valueForKey:@"customerID"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
            
        } else {
            // The find succeeded.
            NSString*str=[NSString stringWithFormat:@"%@ (%@)",[object valueForKey:@"AccountHolder"],[object valueForKey:@"AccountNumber"]];
            NSArray *arr=@[str];
            self.dropArray = arr;
            }
    }];

         // setting data for drop table
        
        [self performSelectorInBackground:@selector(refreshView) withObject:Nil];
       

}
// refresh table after fetching new data
- (void)refreshView {
    dispatch_async(dispatch_get_main_queue(), ^{
  
    [self.dropTable reloadData];
    });
}

// set up the text fields
- (void)setup{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self];
    
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.window.frame.size.width, 44);
    // set style
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    self.previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous", @"Previous") style:UIBarButtonItemStylePlain target:self action:@selector(previousButtonIsClicked:)];
    self.nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next") style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[self.previousBarButton, self.nextBarButton, flexBarButton, doneBarButton];
    
    toolbar.items = barButtonItems;
    
    self.textFields = [[NSMutableArray alloc]init];

    
}

- (void)markTextFieldsWithTagInView:(UIView*)view{
    int index = 0;
    if ([self.textFields count] == 0){
        for(UIView *subView in view.subviews){
            if ([subView isKindOfClass:[MHTextField class]]){
                MHTextField *textField = (MHTextField*)subView;
                textField.tag = index;
                textField.backgroundColor=[UIColor whiteColor];
//                if(textField.tag%2)
//                {
//                     textField.backgroundColor=[UIColor colorWithRed:.94 green:.94 blue:.94 alpha:.9];
//                }
//                else
//                {
//                     textField.backgroundColor=[UIColor colorWithRed:.94 green:1 blue:1 alpha:.9];
//                    
//                }

                [self.textFields addObject:textField];
                index++;
            }
        }
    }
}

- (void) doneButtonIsClicked:(id)sender{
    [self setDoneCommand:YES];
    [self resignFirstResponder];
    [self setToolbarCommand:YES];
}

- (void) nextButtonIsClicked:(id)sender{
    NSInteger tagIndex = self.tag;
    MHTextField *textField =  [self.textFields objectAtIndex:++tagIndex];
    
    while (!textField.isEnabled && tagIndex < [self.textFields count])
        textField = [self.textFields objectAtIndex:++tagIndex];
    
    [self becomeActive:textField];
}

- (void) previousButtonIsClicked:(id)sender{
    NSInteger tagIndex = self.tag;
    
    MHTextField *textField =  [self.textFields objectAtIndex:--tagIndex];
    
    while (!textField.isEnabled && tagIndex < [self.textFields count])
        textField = [self.textFields objectAtIndex:--tagIndex];
    
    [self becomeActive:textField];
}

- (void)becomeActive:(UITextField*)textField{
    [self setToolbarCommand:YES];
    [self resignFirstResponder];
    [textField becomeFirstResponder];
}

- (void)setBarButtonNeedsDisplayAtTag:(NSInteger)tag{
    BOOL previousBarButtonEnabled = NO;
    BOOL nexBarButtonEnabled = NO;
    
    for (int index = 0; index < [self.textFields count]; index++) {
        
        UITextField *textField = [self.textFields objectAtIndex:index];
        
        if (index < tag)
            previousBarButtonEnabled |= textField.isEnabled;
        else if (index > tag)
            nexBarButtonEnabled |= textField.isEnabled;
    }
    
    self.previousBarButton.enabled = previousBarButtonEnabled;
    self.nextBarButton.enabled = nexBarButtonEnabled;
}

- (void) selectInputView:(UITextField *)textField{
    if (_isDateField || _isTimeField){
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        if (_isDateField)
            datePicker.datePickerMode = UIDatePickerModeDate;
        else
            datePicker.datePickerMode = UIDatePickerModeTime;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        if (![textField.text isEqualToString:@""]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if (self.dateFormat) {
                [dateFormatter setDateFormat:self.dateFormat];
            } else {
                [dateFormatter setDateFormat:@"MM-dd-YYYY"];
            }
            
            [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            
            NSDate *selectedDate = [dateFormatter dateFromString:textField.text];
            
            if (selectedDate != nil)
                [datePicker setDate:selectedDate];
        }
        [textField setInputView:datePicker];
    }
}

- (void)datePickerValueChanged:(id)sender{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (self.dateFormat) {
        [dateFormatter setDateFormat:self.dateFormat];
    } else {
        [dateFormatter setDateFormat:@"MM-dd-YYYY"];
    }
    
    [_textField setText:[dateFormatter stringFromDate:selectedDate]];
    
    [self validate];
}

- (void)scrollToField
{
    CGRect textFieldRect = [[_textField superview] convertRect:_textField.frame toView:self.window];
    CGRect aRect = self.window.bounds;
    
    aRect.origin.y = -scrollView.contentOffset.y;
    aRect.size.height -= keyboardSize.height + self.toolbar.frame.size.height + 50;
    
    CGPoint textRectBoundary = CGPointMake(textFieldRect.origin.x, textFieldRect.origin.y + textFieldRect.size.height);
    
    if (!CGRectContainsPoint(aRect, textRectBoundary) || scrollView.contentOffset.y > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, self.superview.frame.origin.y + _textField.frame.origin.y + _textField.frame.size.height - aRect.size.height);
        
        if (scrollPoint.y < 0) scrollPoint.y = 0;
        
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (BOOL) validate{
    
    _isValid = YES;
    
    if (required && [self.text isEqualToString:@""]){
        _isValid = NO;
    }
    else if (_isEmailField){
        NSString *emailRegEx =
        @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
        @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if (![emailTest evaluateWithObject:self.text]&&[self.text length]!=0){
            _isValid = NO;
        }
    }
    else if (_isMobileField){
        NSString *emailRegEx =
        @"^(\\+){0,1}\\d{6,13}$";
        
        NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if (![mobileTest evaluateWithObject:self.text]&&[self.text length]!=0){
          
            _isValid = NO;
        }
    }
    else if (_isNumberField){
        NSString *emailRegEx = @"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$";
        
        NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if (![mobileTest evaluateWithObject:self.text]&&[self.text length]!=0){
            
            _isValid = NO;
        }
    }
    
    else if (_isAmountField){
        float amount= [[[self layer]valueForKey:@"Amount"] floatValue];
        float  enterdAmount=[self.text floatValue];
        
        NSString *amountRegEx = @"^\\d+(?:\\.\\d{0,2})?$";
        
        NSPredicate *amountTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", amountRegEx];
        NSString *str=self.text;
        if(amount<enterdAmount)
        {
            _isValid=NO;
        }
        
        if(![amountTest evaluateWithObject:str] )
        {
            
           
            _isValid=NO;
        }
    
            
        }
    else if( _isConfirmPasswordField)
    {
      
        MHTextField *password=[self.textFields objectAtIndex:self.tag-1];
      
        if (![password.text isEqualToString:self.text]){
            
            _isValid = NO;
        }
        
    }
    
    else if (_isDropboxField)
    {
         _isValid = YES;
    }
    
    
    
    
    [self setNeedsAppearance:self];
    
    return _isValid;
}

- (void)setDateFieldWithFormat:(NSString *)dateFormat
{
    self.isDateField = YES;
    self.dateFormat = dateFormat;
}

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    
    _enabled = enabled;
    
    [self setNeedsAppearance:self];
}

- (void)setNeedsAppearance:(id)sender
{
    // override in child class.
}

#pragma mark - UIKeyboard notifications

- (void) keyboardDidShow:(NSNotification *) notification{
    if (_textField== nil) return;
    if (keyboardIsShown) return;
    if (![_textField isKindOfClass:[MHTextField class]]) return;
    
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardSize = [aValue CGRectValue].size;
    
    [self scrollToField];
    
    self.keyboardIsShown = YES;
}

- (void) keyboardWillHide:(NSNotification *) notification{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (_isDoneCommand){
              [self.scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:NO];
        }
    }];
    
    keyboardIsShown = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardDidShowNotificationObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

#pragma mark - UITextField notifications

- (void)textFieldDidBeginEditing:(NSNotification *) notification{
    UITextField *textField = (UITextField*)[notification object];
    
    _textField = textField;
    
    [self setKeyboardDidShowNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardDidShow:notification];
    }]];
    
    [self setKeyboardWillHideNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardWillHide:notification];
    }]];
    
    [self setBarButtonNeedsDisplayAtTag:textField.tag];
    
    if ([self.superview.superview isKindOfClass:[UIScrollView class]] && self.scrollView == nil){
        self.scrollView = (UIScrollView*)[[self superview] superview];
    }
    
    [self selectInputView:textField];
    [self setInputAccessoryView:toolbar];
    
    [self setToolbarCommand:NO];
    

}


- (void)textFieldDidEndEditing:(NSNotification *) notification{
    UITextField *textField = (UITextField*)[notification object];

    [[self delegate] MHTextfieldEndEditing:textField];
    
    if ((_isDateField || _isTimeField) && [textField.text isEqualToString:@""] && _isDoneCommand){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        if (self.dateFormat) {
            [dateFormatter setDateFormat:self.dateFormat];
        } else {
            [dateFormatter setDateFormat:@"MM-dd-YYYY"];
        }
        
        [textField setText:[dateFormatter stringFromDate:[NSDate date]]];
    }
   
    
    [self validate];
    
    [self setDoneCommand:NO];
    
    _textField = nil;
}

- (void)textFieldDidChange:(NSNotification *) notification{
    /*
    UITextField *textField = (UITextField*)[notification object];
  if(_isDropboxField)
  {
    
  if  ([textField.text length]==0)
    {
        [[self dropTable]removeFromSuperview];
        self.dropTable=nil;
        
    }
    else
    {
        
         if(!self.dropTable)[self initDropTable];
        
        [self fetchPlaceResult:textField];
        
    }
  }
     */
}



@end
