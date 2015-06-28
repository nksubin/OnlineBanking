//
//  ConfirmVC.m
//  OnlineBanking
//
//  Created by Subin Kurian on 6/26/15.
//  Copyright (c) 2015 National Plus. All rights reserved.
//

#import "ConfirmVC.h"
#import <Parse/Parse.h>
@interface ConfirmVC ()
@property (weak, nonatomic) IBOutlet UILabel *from;
@property (weak, nonatomic) IBOutlet UILabel *to;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *note;


@end

@implementation ConfirmVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.from.text=self.fromStr;
    self.to.text=self.toStr;
    self.amount.text=self.amountStr;
    self.note.text=self.noteStr;
    [self fetchPlaceResult];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Cancel:(id)sender {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSArray *array = [self.navigationController viewControllers];
        
        [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
    });
}
-(IBAction)confirm:(id)sender
{
    [self performSelectorInBackground:@selector(dotransaction) withObject:nil];
}

-(void)dotransaction
{
    
    
    float currentamount=[self.currentAmountFromAccount floatValue];
     currentamount = floorf(currentamount * 100) / 100;

    float nowamount=[self.amountStr floatValue];
      nowamount = floorf(nowamount * 100) / 100;
    
    float tocurrentamount=[self.currentAmountToAccount floatValue];
     tocurrentamount = floorf(tocurrentamount * 100) / 100;
    
    
    NSString *newfromamount=[NSString stringWithFormat:@"%.02f",currentamount-nowamount];
    NSString *newtoamount=[NSString stringWithFormat:@"%.02f",tocurrentamount+nowamount];
    PFObject *userStats = [PFObject objectWithoutDataWithClassName:@"Account" objectId:self.fromAccountObjectID];
    
    // Set a new value on quantity
    [userStats setObject:newfromamount forKey:@"Amount"];
    
    // Save
    [userStats save];
    
    PFObject *touserStats = [PFObject objectWithoutDataWithClassName:@"Account" objectId:self.toAccountObjectID];
    
    // Set a new value on quantity
    [touserStats setObject:newtoamount forKey:@"Amount"];
    
    // Save
    [touserStats save];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    NSArray *array = [self.navigationController viewControllers];
    
    [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
   });
}

- (void)fetchPlaceResult{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Account"];
    [query whereKey:@"AccountNumber" equalTo:self.toStr];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
            
        } else {
            // The find succeeded.
            self.toAccountObjectID=object.objectId;
            self.currentAmountToAccount= [NSString stringWithFormat:@"%@", [object valueForKey:@"Amount"]];

            
                 }
    }];
    
    // setting data for drop table
    
  
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
