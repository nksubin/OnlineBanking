//
//  CustomTextField.m
//
//
//  Created by Subin Kurian on 12/3/13.
//  Copyright (c) 2013 Subin Kurian. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
        [self applyStyle];
    
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self applyStyle];
}

- (void)applyStyle  //set style of text field
{
    [self setFont: [UIFont fontWithName:@"System" size:16]];
    [self setClearButtonMode:UITextFieldViewModeWhileEditing];
    
}

-(void)showTootTip:(NSString*)text  // show tool tip above text view
{
    [tootTipView removeFromSuperview];
    tootTipView =[[UILabel alloc]initWithFrame:self.frame];
    tootTipView.backgroundColor=[UIColor colorWithRed:0.37f green:0.70f blue:0.85f alpha:1];
    [[tootTipView layer]setCornerRadius:5];
    [[tootTipView layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[tootTipView layer]setBorderWidth:1];
    tootTipView.clipsToBounds=YES;
    tootTipView.text=[NSString stringWithFormat:@"  %@", text];
    tootTipView.textColor=[UIColor blackColor];
    [self.superview insertSubview:tootTipView aboveSubview:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.0f animations:^{
                [tootTipView setAlpha:0.0f];
            } completion:^(BOOL finished){
                [tootTipView removeFromSuperview]; // removing after showing the tool tip
            }];
    });

}

- (void)setNeedsAppearance:(id)sender // setting background of text field
{
    MHTextField *textField = (MHTextField*)sender;
    if (![textField isEnabled])
        [self setBackgroundColor:[UIColor colorWithRed:.66 green:.66 blue:.66 alpha:.9]];    // if not enabled
    else if (![textField isValid])
        [self setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:.9]];  // if not valid
    else
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:.9]]; // default
}

// setting the rectangle of text field
- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 10, 2);
}
- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 10, 2);
}



@end
