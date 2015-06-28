//
//  ConfirmVC.h
//  OnlineBanking
//
//  Created by Subin Kurian on 6/26/15.
//  Copyright (c) 2015 National Plus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmVC : UIViewController

@property(nonatomic,strong)NSString *fromStr;
@property(nonatomic,strong)NSString *toStr;
@property(nonatomic,strong)NSString *amountStr;
@property(nonatomic,strong)NSString *noteStr;
@property(nonatomic,strong)NSString *fromAccountObjectID;
@property(nonatomic,strong)NSString *currentAmountFromAccount;
@property(nonatomic,strong)NSString *toAccountObjectID;
@property(nonatomic,strong)NSString *currentAmountToAccount;
@end
