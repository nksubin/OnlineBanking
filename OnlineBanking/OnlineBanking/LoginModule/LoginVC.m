//
//  LoginVC.m
//  OnlineBanking
//
//  Created by Subin Kurian on 6/26/15.
//  Copyright (c) 2015 National Plus. All rights reserved.
//

#import "LoginVC.h"
#import <Parse/Parse.h>
#import "AccountsVC.h"
@interface LoginVC ()
@property (weak, nonatomic) IBOutlet CustomTextField *CustomerIDText;
@property (weak, nonatomic) IBOutlet UIButton *proceedBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.CustomerIDText.required=YES;
    self.CustomerIDText.isNumberField=YES;

    // Do any additional setup after loading the view.
}
- (IBAction)proceedAction:(id)sender {
    
    [self.CustomerIDText resignFirstResponder];
    [self.CustomerIDText validate];
    if(self.CustomerIDText.isValid)
        [self sendToServer];
    else
        self.errorLabel.hidden=FALSE;
       
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)sendToServer
{
    
    
    
    //NSString *str=[NSString stringWithFormat:@"CustomerNumber != '%@'",self.CustomerIDText.text];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:  str];
    PFQuery *query = [PFQuery queryWithClassName:@"Account"];
    [query whereKey:@"CustomerNumber" equalTo:self.CustomerIDText.text];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
          
            if(count==1)
            { self.errorLabel.hidden=TRUE;
                
                [self performSegueWithIdentifier:@"AccountView" sender:self];
                
            }
            else
            {
                 self.errorLabel.hidden=FALSE;
            }
         
        } else {
            // The request failed
            
            
            self.errorLabel.hidden=FALSE;
          
        }
    }];
    

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    AccountsVC *accounts= [segue destinationViewController];
    accounts.customerID=self.CustomerIDText.text;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
