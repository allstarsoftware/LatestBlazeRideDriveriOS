//
//  SettingVC.m
//  UberforX Provider
//
//  Created by My Mac on 11/15/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "SettingVC.h"
#import "PickMeUpMapVC.h"
#import "ArrivedMapVC.h"
#import "FeedBackVC.h"
#import "ProviderCheckState.h"

@interface SettingVC ()
{
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSUserDefaults *pref;
    NSArray *languagearray;
}

@end

@implementation SettingVC
@synthesize swAvailable,swSound;

- (void)viewDidLoad
{
    pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    [super viewDidLoad];
    [self checkState];
    [super setBackBarItem];
    [self.tblLanguageList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
     languagearray = [NSArray arrayWithObjects:@"English", nil]; //@"Spanish",@"Portuguese",
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"Setting", [pref objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"Setting",[pref objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
    [self CustomFormat];
    [self customFont];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- customFont

-(void)customFont
{
//    self.lblAvailable.font=[UberStyleGuide fontRegular];
//    self.lblYes.font=[UberStyleGuide fontRegular];
//    self.lblSound.font=[UberStyleGuide fontRegular];
    //self..font=[UberStyleGuide fontRegular];
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    [self.viewSelection setBackgroundColor:[UberStyleGuide colorSecondary]];
    [self.imgLine1 setBackgroundColor:[UberStyleGuide colorDefault]];
    [self.imgLine2 setBackgroundColor:[UberStyleGuide colorDefault]];
    [self.viewSelection1 setBackgroundColor:[UberStyleGuide colorSecondary]];
    [self.viewSelection2 setBackgroundColor:[UberStyleGuide colorSecondary]];
    [self.viewSelection.layer setCornerRadius:5.0];
    [self.viewSelection1.layer setCornerRadius:5.0];
    [self.viewSelection2.layer setCornerRadius:5.0];
    [self.BgViewforTblview.layer setCornerRadius:5.0];

}

-(void)CustomFormat
{
  
    if ([[pref objectForKey:@"TranslationDocumentName"] isEqualToString:@"LocalizationSpanish"])
    {
        _lbl_languagetitle.text=@"Idioma";
        _lbl_languageabbrv.text = @"SP";
        [self.lb_language setText:@"Spanish"];
    }
    else if ([[pref objectForKey:@"TranslationDocumentName"] isEqualToString:@"LocalizationPortuguese" ])
    {
        _lbl_languagetitle.text=@"Língua";
        _lbl_languageabbrv.text = @"PT";
        [self.lb_language setText:@"Portuguese"];
    }
    else
    {
        _lbl_languagetitle.text=@"Language";
        _lbl_languageabbrv.text = @"EN";
        [self.lb_language setText:@"English"];
    }
    
    self.lblAvailable.text = NSLocalizedStringFromTable(@"Available to drive?",[pref objectForKey:@"TranslationDocumentName"],nil);
    self.lblSoundtext.text = NSLocalizedStringFromTable(@"Sound",[pref objectForKey:@"TranslationDocumentName"],nil);
    self.lblYes.text = NSLocalizedStringFromTable(@"YES",[pref objectForKey:@"TranslationDocumentName"],nil);
    if ([[pref valueForKey:@"SOUND"] isEqualToString:@"off"])
    {
        self.lblSound.text=NSLocalizedStringFromTable(@"OFF",[pref objectForKey:@"TranslationDocumentName"],nil);
        [swSound setOn:NO animated:NO];
    }
    else
    {
        self.lblSound.text=NSLocalizedStringFromTable(@"ON",[pref objectForKey:@"TranslationDocumentName"],nil);
        [swSound setOn:YES animated:NO];
        [pref setObject:@"on" forKey:@"SOUND"];
    }

    
}

-(void)checkState
{
    if([APPDELEGATE connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_CHECKSTATUS,PARAM_ID,strUserId,PARAM_TOKEN,strUserToken];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"History Data= %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSLog(@"Response--%@",response);
                     NSDictionary *set = response;
                     ProviderCheckState *tester = [RMMapper objectWithClass:[ProviderCheckState class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                     if([[response valueForKey:@"is_active"] intValue]==1)
                     {
                         swAvailable.on=YES;
                         self.lblYes.text=NSLocalizedStringFromTable(@"YES",[pref objectForKey:@"TranslationDocumentName"],nil);
                     }
                     else
                     {
                         swAvailable.on=NO;
                         self.lblYes.text=NSLocalizedStringFromTable(@"NO",[pref objectForKey:@"TranslationDocumentName"],nil);
                     }
                 }
             }
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet", [pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", [pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)setStatus
{
    if([APPDELEGATE connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_TOGGLE withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"Request in Progress= %@",response);
             NSDictionary *set = response;
             ProviderCheckState *tester = [RMMapper objectWithClass:[ProviderCheckState class] fromDictionary:set];
             NSLog(@"Tdata: %@",tester.success);
             if (response)
             {
                 if([tester.success intValue]==1)
                 {
                     NSLog(@"Response--%@",response);
                    
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"AVAILABILITY_UODATE",[pref objectForKey:@"TranslationDocumentName"],nil)];
                 }
             }
             
         }];
    }
}

- (IBAction)backBtnPressed:(id)sender
{
    NSArray *currentControllers = self.navigationController.viewControllers;
    NSMutableArray *newControllers = [NSMutableArray
                                      arrayWithArray:currentControllers];
    UIViewController *obj=nil;
    
    for (int i=0; i<newControllers.count; i++)
    {
        UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
        if ([vc isKindOfClass:[FeedBackVC class]])
        {
            obj = (FeedBackVC *)vc;
        }
        else if ([vc isKindOfClass:[ArrivedMapVC class]])
        {
            obj = (ArrivedMapVC *)vc;
        }
        else if ([vc isKindOfClass:[PickMeUpMapVC class]])
        {
            obj = (PickMeUpMapVC *)vc;
        }
        
    }
    [self.navigationController popToViewController:obj animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setState:(id)sender
{
    if ([swAvailable isOn]==NO)
    {
        self.lblYes.text=NSLocalizedStringFromTable(@"NO",[pref objectForKey:@"TranslationDocumentName"],nil);
        
    }
    else
    {
        self.lblYes.text=NSLocalizedStringFromTable(@"YES", [pref objectForKey:@"TranslationDocumentName"],nil);
    }
    [self setStatus];

}

- (IBAction)setSound:(id)sender
{
    pref=[NSUserDefaults standardUserDefaults];
    if ([swSound isOn]==NO)
    {
        self.lblSound.text=NSLocalizedStringFromTable(@"OFF",[pref objectForKey:@"TranslationDocumentName"],nil);
        [pref setObject:@"off" forKey:@"SOUND"];
        
    }
    else
    {
        self.lblSound.text=NSLocalizedStringFromTable(@"ON", [pref objectForKey:@"TranslationDocumentName"],nil);
        [pref setObject:@"on" forKey:@"SOUND"];
    }
}


//----------Language Selection-----Implementation

- (IBAction)btnlanguageselection:(id)sender
{
  
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"Alert",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"Select_language",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
//    [alert show];
    
    [self.viewBackground setHidden:NO];
//    [[AppDelegate sharedAppDelegate]showToastMessage:@"Please Restart the application Inorder to reflect the changes applied for Language Settings"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [languagearray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = [languagearray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.viewBackground setHidden:YES];
    if ([cell.textLabel.text isEqualToString:@"English"])
        [pref setObject:@"Localizable" forKey:@"TranslationDocumentName"];
    else if ([cell.textLabel.text isEqualToString:@"Spanish"])
        [pref setObject:@"LocalizationSpanish" forKey:@"TranslationDocumentName"];
    else if ([cell.textLabel.text isEqualToString:@"Portuguese"])
        [pref setObject:@"LocalizationPortuguese" forKey:@"TranslationDocumentName"];
    [pref synchronize];
    [self CustomFormat];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated"
                                                        object:self];
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
