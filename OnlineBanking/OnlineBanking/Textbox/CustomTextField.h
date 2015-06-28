//
//  CustomTextField.h
//
//  Created by Subin Kurian on 12/3/13.
//  Copyright (c) 2013 Subin Kurian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHTextField.h"

// Application specific customization.
@interface CustomTextField : MHTextField
{
    UILabel *tootTipView; // view for tool tip
}
-(void)showTootTip:(NSString*)text; // shows the tool tip

@end
