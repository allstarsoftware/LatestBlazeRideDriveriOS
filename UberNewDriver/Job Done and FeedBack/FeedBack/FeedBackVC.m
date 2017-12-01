//
//  FeedBackVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//
#import "FeedBackVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import "ProviderRating.h"

@interface FeedBackVC ()
{
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    
    NSString *strTime;
    NSString *strDistance;
    NSString *strProfilePic;
    NSString *strLastName;
    NSString *strFirstName;
    int rate;
    NSUserDefaults *prefl;
}

@end

@implementation FeedBackVC

@synthesize txtComment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefl = [[NSUserDefaults alloc]init];
    
    if ([self.InstantjobStatus isEqualToString:@"YesInstantJob"])
    {
        [self.txtComment setUserInteractionEnabled:NO];
        
    }
    
    [self customFont];
    [self localizeString];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strDistance=[pref objectForKey:PREF_WALK_DISTANCE];
    strTime=[pref objectForKey:PREF_WALK_TIME];
    strProfilePic=[pref objectForKey:PREF_USER_PICTURE];
    strLastName=[pref objectForKey:PREF_USER_NAME];
    
    
    NSArray *myWords = [strLastName componentsSeparatedByString:@" "];
    
    self.lblFirstName.text=[myWords objectAtIndex:0];
    self.lblLastName.text=[myWords objectAtIndex:1];
    [self.imgProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    //self.lblDistance.text=[NSString stringWithFormat:@"%@ %@",strDistance,NSLocalizedString(@"Miles", nil)];
    self.lblDistance.text=[NSString stringWithFormat:@"%.2f %@",[[dictBillInfo valueForKey:@"distance"] floatValue],[dictBillInfo valueForKey:@"unit"]];
    self.lblTime.text=[NSString stringWithFormat:@"%@ %@",strTime,NSLocalizedStringFromTable(@"Mins",[prefl objectForKey:@"TranslationDocumentName"],nil)];
    self.lblTask1.text=@"0";
    self.lblTask2.text=@"1";
    [self.imgProfile downloadFromURL:strProfilePic withPlaceholder:nil];
    
    [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
    
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
//    ratingView=[[RatingBar alloc] initWithSize:CGSizeMake (120, 20) AndPosition:CGPointMake(178, 152)];
//    ratingView.backgroundColor=[UIColor clearColor];
//    
//    
//    [self.view addSubview:ratingView];
    
    self.viewForBill.hidden=NO;
    [self setPriceValue];
    
    // Do any additional setup after loading the view.
}

/*- (IBAction)onClickMenu:(id)sender{
    [self.revealViewController revealToggle:sender];
}*/

- (void)viewWillAppear:(BOOL)animated
{
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"Feedback",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [APPDELEGATE hideLoadingView];
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"Feedback",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)giveFeedback
{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    if (strRequsetId!=nil)
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        
        [dictparam setObject:[NSString stringWithFormat:@"%d",rate] forKey:PARAM_RATING];
        
        NSString *commt=self.txtComment.text;
        if([commt isEqualToString:NSLocalizedStringFromTable(@"COMMENTS",[prefl objectForKey:@"TranslationDocumentName"],nil)])
        {
            [dictparam setObject:@"" forKey:PARAM_COMMENT];
        }
        else
        {
            [dictparam setObject:self.txtComment.text forKey:PARAM_COMMENT];
        }
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_RATING withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 NSLog(@"Response--%@",response);
                 NSDictionary *set = response;
                 ProviderRating* tester = [RMMapper objectWithClass:[ProviderRating class] fromDictionary:set];
                 NSLog(@"Tdata: %@",tester.success);
                 [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"RATING_COMPLETED",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_REQUEST_ID];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_NAME];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PHONE];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PICTURE];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_RATING];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_START_TIME];
                 is_completed=0;
                 is_dog_rated=0;
                 is_started=0;
                 is_walker_arrived=0;
                 is_walker_started=0;
                 [self.navigationController popToRootViewControllerAnimated:YES];
                 
             }
         }];
    }
}

#pragma mark-
#pragma mark-

-(void)customFont
{
    self.lblTime.font=[UberStyleGuide fontRegular];
    self.lblDistance.font=[UberStyleGuide fontRegular];
    self.lblTask1.font=[UberStyleGuide fontRegular];
    self.lblTask2.font=[UberStyleGuide fontRegular];
    self.lblFirstName.font=[UberStyleGuide fontRegular];
    self.lblLastName.font=[UberStyleGuide fontRegular];
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnSubmit=[APPDELEGATE setBoldFontDiscriptor:self.btnSubmit];
}

-(void)localizeString
{
    
    self.lblInvoice.text = NSLocalizedStringFromTable(@"Invoice",[prefl objectForKey:@"TranslationDocumentName"],nil);
    self.lblTime_Cost.text = NSLocalizedStringFromTable(@"TIME COST",[prefl objectForKey:@"TranslationDocumentName"], nil);
    self.lblDist_Cost.text = NSLocalizedStringFromTable(@"DISTANCE COST",[prefl objectForKey:@"TranslationDocumentName"], nil);
    self.lblTotalDue.text = NSLocalizedStringFromTable(@"Total Due",[prefl objectForKey:@"TranslationDocumentName"], nil);
//    self.lblBase_Price.text = NSLocalizedStringFromTable(@"BASE PRICE",[prefl objectForKey:@"TranslationDocumentName"], nil);
    self.lbl_Promo.text = NSLocalizedStringFromTable(@"PROMO BONUS",[prefl objectForKey:@"TranslationDocumentName"], nil);
    self.lbl_Referrel.text = NSLocalizedStringFromTable(@"REFERRAL BONUS",[prefl objectForKey:@"TranslationDocumentName"], nil);
    
    [self.btnConfirm setTitle:NSLocalizedStringFromTable(@"CONFIRM",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateNormal];
    [self.btnSubmit setTitle:NSLocalizedStringFromTable(@"SUBMIT",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateNormal];
    [self.btnSubmit setTitle:NSLocalizedStringFromTable(@"SUBMIT",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateSelected];
    
    
    
    self.lblComment.text = NSLocalizedStringFromTable(@"COMMENT",[prefl objectForKey:@"TranslationDocumentName"], nil);
    self.txtComment.text = NSLocalizedStringFromTable(@"COMMENTS",[prefl objectForKey:@"TranslationDocumentName"], nil);
    
}
#pragma mark-
#pragma mark- Set Invoice Details

-(void)setPriceValue
{
    self.lblReferrel.text = [NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"referral_bonus"] floatValue]];
    self.lblCostPrice.text = [NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"total"] floatValue]];
    self.lblPromo.text = [NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"promo_bonus"] floatValue]];
    self.lblBasePrice.text=[NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"base_price"] floatValue]];
    self.lblDistCost.text=[NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"distance_cost"] floatValue]];
    self.lblTimeCost.text=[NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"time_cost"] floatValue]];
    self.lblTotal.text=[NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"total"] floatValue]];
    self.LblAdminCommissionValue.text=[NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"waiting_price"] floatValue]];
    
//    self.LblDriverCommissionvalue.text=[NSString stringWithFormat:@"$ %.2f",[[dictBillInfo valueForKey:@"driver_per_payment"] floatValue]];
    
    float totalDist=[[dictBillInfo valueForKey:@"distance_cost"] floatValue];
    float Dist=[[dictBillInfo valueForKey:@"distance"]floatValue];
    float NetDistance = Dist - 1.0;
    NSLog(@"Net Distance=%f",NetDistance);
    NSLog(@"Bill Dictionarye=%@",dictBillInfo);
    NSLog(@"Distance Price=%f",[[dictBillInfo valueForKey:@"distance_price"] floatValue]);
    NSLog(@"Set Base Distance=%f",[[dictBillInfo valueForKey:@"setbase_distance"] floatValue]);
    NSLog(@"Price Per Unit Time=%f",[[dictBillInfo valueForKey:@"price_per_unit_time"] floatValue]);
    NSString *Distance_Price = [dictBillInfo valueForKey:@"distance_price"];
    NSString *SetBaseDistance = [dictBillInfo valueForKey:@"setbase_distance"];
    NSString *PricePerUnitTime = [dictBillInfo valueForKey:@"price_per_unit_time"];
    
    if ([[dictBillInfo valueForKey:@"unit"]isEqualToString:NSLocalizedStringFromTable(@"kms",[prefl objectForKey:@"TranslationDocumentName"],nil)])
    {
        totalDist=totalDist*0.621317;
        Dist=Dist*0.621371;
    }
    if(Dist!=0)
    {
//        self.lblPerDist.text=[NSString stringWithFormat:@"%.2f$ %@",(totalDist/Dist),NSLocalizedStringFromTable(@"per mile",[prefl objectForKey:@"TranslationDocumentName"],nil)];
        if (Dist<[SetBaseDistance doubleValue])
        {
            self.lblBase_Price.text=[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"BASE PRICE",[prefl objectForKey:@"TranslationDocumentName"], nil)];
            
            self.lblDist_Cost.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"DISTANCE COST", nil)];
            
            self.lblPerDist.text=[NSString stringWithFormat:@"%.2f$ %@",[Distance_Price floatValue],NSLocalizedStringFromTable(@"per mile",[prefl objectForKey:@"TranslationDocumentName"],nil)];
            NSLog(@" IF Calling Label Value1 =%@",self.lblPerDist.text);
        }
        else
        {
            self.lblBase_Price.text=[NSString stringWithFormat:@"%@ (%.2f KM)",NSLocalizedStringFromTable(@"BASE PRICE",[prefl objectForKey:@"TranslationDocumentName"], nil),[SetBaseDistance floatValue]];
            
            self.lblDist_Cost.text = [NSString stringWithFormat:@"%@ (%.2f KM)",NSLocalizedString(@"DISTANCE COST", nil),NetDistance];
           
            self.lblPerDist.text=[NSString stringWithFormat:@"%.2f$ %@",[Distance_Price floatValue],NSLocalizedStringFromTable(@"per mile",[prefl objectForKey:@"TranslationDocumentName"],nil)];
            NSLog(@"Else Calling Label Value2 =%@",self.lblPerDist.text);
        }

    }
    else
    {
        self.lblBase_Price.text=NSLocalizedStringFromTable(@"BASE PRICE",[prefl objectForKey:@"TranslationDocumentName"], nil);
        self.lblPerDist.text=[NSString stringWithFormat:@"0$ %@",NSLocalizedStringFromTable(@"per mile",[prefl objectForKey:@"TranslationDocumentName"],nil)];
    }
    
    float totalTime=[[dictBillInfo valueForKey:@"time_cost"] floatValue];
    float Time=[[dictBillInfo valueForKey:@"time"]floatValue];
    if(Time!=0)
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"%.2f$ %@",[PricePerUnitTime floatValue],NSLocalizedStringFromTable(@"per mins",[prefl objectForKey:@"TranslationDocumentName"],nil)];
        NSLog(@"Label Value3 =%@",self.lblPerTime.text);
        //(totalTime/Time)
    }
    else
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"0$ %@",NSLocalizedStringFromTable(@"per mins",[prefl objectForKey:@"TranslationDocumentName"],nil)];
        NSLog(@"Label Value4 =%@",self.lblPerTime.text);
    }
    
//    self.lblPerTime.text=[NSString stringWithFormat:@"%.2f$ per Mins",[[dictBillInfo valueForKey:@"price_per_unit_time"] floatValue]];
//    
//    float unitTime=[[dictBillInfo valueForKey:@"price_per_unit_time"] floatValue];
//    float Time=[[dictBillInfo valueForKey:@"time"]floatValue];
//    if(Time!=0)
//    {
//        self.lblTimeCost.text=[NSString stringWithFormat:@"$ %.2f",(unitTime*Time)];
//    }
//    else
//    {
//        self.lblTimeCost.text=[NSString stringWithFormat:@"$ %.2f",(unitTime*Time)];
//    }

    
}


#pragma mark-
#pragma mark- Bytton Methods
- (IBAction)submitBtnPressed:(id)sender
{
    if (![self.InstantjobStatus isEqualToString:@"YesInstantJob"])
    {
        [self.txtComment setUserInteractionEnabled:YES];
        RBRatings rating=[ratingView getcurrentRatings];
        rate=rating/2.0;
        if (rate==0)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromTable(@"PLEASE_RATINGS",[prefl objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[prefl objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:Nil, nil];
            [alert show];
        }
        else
        {
            [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_FOR_FEEDBACK",[prefl objectForKey:@"TranslationDocumentName"],nil)];
            [txtComment resignFirstResponder];
            [self giveFeedback];
        }
    }
    else
    {
        [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_FOR_FEEDBACK",[prefl objectForKey:@"TranslationDocumentName"],nil)];
        [txtComment resignFirstResponder];
        [self giveFeedback];
    }
    
    
    
}

- (IBAction)confirmBtnPressed:(id)sender
{
    if (![self.InstantjobStatus isEqualToString:@"YesInstantJob"])
    {
        self.viewForBill.hidden=YES;
        ratingView=[[RatingBar alloc] initWithSize:CGSizeMake(120, 20) AndPosition:CGPointMake(145, 150)];
        ratingView.backgroundColor=[UIColor clearColor];
        [self.view addSubview:ratingView];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_REQUEST_ID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_NAME];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PHONE];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PICTURE];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_RATING];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_START_TIME];
        is_completed=0;
        is_dog_rated=0;
        is_started=0;
        is_walker_arrived=0;
        is_walker_started=0;
        [self.navigationController popToRootViewControllerAnimated:YES];

    }
    
}

#pragma mark-
#pragma mark- Text Field Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtComment resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField     //Hide the keypad when we pressed return
{
    [textField resignFirstResponder];
    return YES;
}

// *************** Custom Done Button for Keyboard ********************
-(void)CustomKeybrdDonebtn
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(yourTextViewDoneButtonPressed)];
    [doneBarButton setTintColor:[UIColor blackColor]];
    UIBarButtonItem *flexBarButton2 = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                       target:nil action:nil];
    keyboardToolbar.items = @[flexBarButton,doneBarButton,flexBarButton2];
    self.txtComment.inputAccessoryView = keyboardToolbar;
}
-(void)yourTextViewDoneButtonPressed
{
    [self.txtComment resignFirstResponder];
}
// ********* Custom Done Button for Keyboard ********************

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self CustomKeybrdDonebtn];
    self.txtComment.text=@"";
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComment)
            {
                UITextPosition *beginning = [self.txtComment beginningOfDocument];
                [self.txtComment setSelectedTextRange:[self.txtComment textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComment)
            {
                UITextPosition *beginning = [self.txtComment beginningOfDocument];
                [self.txtComment setSelectedTextRange:[self.txtComment textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
//                [UIView animateWithDuration:0.3 animations:^{
//                    
//                    self.view.frame = CGRectMake(0, -210, 320, 480);
//                    
//                } completion:^(BOOL finished) { }];
            }
        }
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComment)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComment)
            {
//                [UIView animateWithDuration:0.3 animations:^{
//                    
//                    self.view.frame = CGRectMake(0, 0, 320, 480);
//                    
//                } completion:^(BOOL finished) { }];
            }
        }
    }
    if ([txtComment.text isEqualToString:@""])
    {
        txtComment.text=NSLocalizedStringFromTable(@"COMMENTS",[prefl objectForKey:@"TranslationDocumentName"],nil);
    }
    
}

/*- (void)textFieldDidBeginEditing:(UITextField *)textField
 
 {
 if(textField == self.txtComment)
 {
 UITextPosition *beginning = [self.txtComment beginningOfDocument];
 [self.txtComment setSelectedTextRange:[self.txtComment textRangeFromPosition:beginning
 toPosition:beginning]];
 [UIView animateWithDuration:0.3 animations:^{
 
 self.view.frame = CGRectMake(0, -120, 320, 480);
 
 } completion:^(BOOL finished) { }];
 }
 }
 
 - (void)textFieldDidEndEditing:(UITextField *)textField
 {
 UIDevice *thisDevice=[UIDevice currentDevice];
 if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
 {
 CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
 
 if (iOSDeviceScreenSize.height == 568)
 {
 if(textField == self.txtComment)
 {
 [UIView animateWithDuration:0.3 animations:^{
 
 self.view.frame = CGRectMake(0, 0, 320, 568);
 
 } completion:^(BOOL finished) { }];
 }
 }
 else
 {
 if(textField == self.txtComment)
 {
 [UIView animateWithDuration:0.3 animations:^{
 
 self.view.frame = CGRectMake(0, 0, 320, 480);
 
 } completion:^(BOOL finished) { }];
 }
 }
 }
 }
 */



@end
