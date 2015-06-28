//
//  AccountsVC.m
//  OnlineBanking
//
//  Created by Subin Kurian on 6/26/15.
//  Copyright (c) 2015 National Plus. All rights reserved.
//

#import "AccountsVC.h"
#import "CustomTextField.h"
#import "ConfirmVC.h"
@interface AccountsVC ()<UITextViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *AccountNumber;
@property (weak, nonatomic) IBOutlet UILabel *Balance;
@property (weak, nonatomic) IBOutlet CustomTextField *FromAccountTxt;
@property (weak, nonatomic) IBOutlet CustomTextField *ToAccountTxt;
@property (weak, nonatomic) IBOutlet CustomTextField *AmountTxt;
@property (weak, nonatomic) IBOutlet UITextView *NoteTxtView;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
@property(strong,nonatomic)NSString*fromaccountObjectID;
@end

@implementation AccountsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.FromAccountTxt.required=TRUE;
    [self.FromAccountTxt.layer setValue:self.customerID forKey:@"customerID"];
    self.FromAccountTxt.isDropboxField=TRUE;
    
    self.ToAccountTxt.required=TRUE;
    self.ToAccountTxt.isNumberField=TRUE;
    self.AmountTxt.required=TRUE;
    self.AmountTxt.isAmountField=TRUE;
    

   

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ToAccountTxt.text=nil;
    self.FromAccountTxt.text=nil;
    self.AmountTxt.text=nil;
    self.NoteTxtView.text=nil;
}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    PFQuery *query = [PFQuery queryWithClassName:@"Account"];
    [query whereKey:@"CustomerNumber" equalTo:self.customerID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
            
        } else {
            // The find succeeded.
            self.name.text=[NSString stringWithFormat:@"%@", [object valueForKey:@"AccountHolder"]];
            self.AccountNumber.text=[NSString stringWithFormat:@"%@", [object valueForKey:@"AccountNumber"]];
            
            float val=[[object valueForKey:@"Amount"] floatValue];
            float rounded_down = floorf(val * 100) / 100;
            
            self.Balance.text= [NSString stringWithFormat:@"%.02f", rounded_down];
            

            
            [[self.AmountTxt layer]setValue:[NSString stringWithFormat:@"%.02f", rounded_down] forKey:@"Amount"];
            self.fromaccountObjectID= [NSString stringWithFormat:@"%@",object.objectId];
            NSLog(@"%@",object);
        }
    }];


}
- (IBAction)SelectFromAccount:(id)sender {
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Account:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            self.AccountNumber.text,
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                {
                    self.FromAccountTxt.text=self.AccountNumber.text;
                    [self.FromAccountTxt validate];
                }
                break;

                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.NoteTxtView resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 50;
}
- (IBAction)proceed:(id)sender {
    
    [self.FromAccountTxt validate];
    [self.ToAccountTxt validate];
    [self.AmountTxt validate];
    PFQuery *query = [PFQuery queryWithClassName:@"Account"];
    [query whereKey:@"AccountNumber" equalTo:self.ToAccountTxt.text];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            
            if(count==1)
            {
            
                
                if([self.FromAccountTxt isValid]&&[self.ToAccountTxt isValid] &&[self.AmountTxt isValid] && ![self.ToAccountTxt.text isEqualToString:self.AccountNumber.text])
                {
                    
                    
                    
                    [self performSegueWithIdentifier:@"ConfirmPage" sender:self];
                }
                
            }
            else
            {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"To account does not exist. Please re-enter another account no" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
        
            }
            
        } else {
            // The request failed
            
            
            
        }
    }];

    
    
 
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ConfirmVC *confrm=[segue destinationViewController];
    confrm.fromStr=self.AccountNumber.text;
    confrm.toStr=self.ToAccountTxt.text;
    confrm.amountStr=self.AmountTxt.text;
    confrm.noteStr=self.NoteTxtView.text;
    confrm.fromAccountObjectID=self.fromaccountObjectID;
    confrm.currentAmountFromAccount=self.Balance.text;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
