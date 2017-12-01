//
//  ForgotPasswordVC.m
//  UberforX Provider
//
//  Created by My Mac on 11/15/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "UberStyleGuide.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constant.h"

@interface ForgotPasswordVC ()

@end

@implementation ForgotPasswordVC
{
    NSUserDefaults *prefl;
}

#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefl = [[NSUserDefaults alloc]init];
    [super setBackBarItem];
    [self customfont];
    //self.btnSend=[APPDELEGATE setBoldFontDiscriptor:self.btnSend];
    self.btnSend.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.txtEmail.font=[UberStyleGuide fontRegularBold];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.btnForget setTitle:NSLocalizedStringFromTable(@"FORGOT_PASSWORD",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
}
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-
#pragma mark- Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField     //Hide the keypad when we pressed return
{
    [self.txtEmail resignFirstResponder];
    return YES;
}

- (IBAction)forgotBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedStringFromTable(@"SENDING MAIL",[prefl objectForKey:@"TranslationDocumentName"],nil)];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
        [dictParam setValue:@"1" forKey:@"type"];
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_FORGOT_PASSWORD withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             
             if (response)
             {
                 if([[response valueForKey:@"success"] boolValue])
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"PASSWORD_SENT_SUCCESS",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 else
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"ERROR",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                     
                 }
             }
             
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

# pragma mark -- Custom Font & Color
-(void)customfont
{
    
    [self.btnSend setTitle:NSLocalizedStringFromTable(@"SEND PASSWORD",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
    self.txtEmail.placeholder = NSLocalizedStringFromTable(@"EMAIL",[prefl objectForKey:@"TranslationDocumentName"],nil);
}




@end
