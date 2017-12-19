//
//  SideBarVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "SideBarVC.h"
#import "SWRevealViewController.h"
#import "PickMeUpMapVC.h"
#import "CellSlider.h"
#import "UIView+Utils.h"
#import "UIImageView+Download.h"
#import "ProviderLogout.h"


@interface SideBarVC ()
{
    NSMutableArray *arrImages,*arrListName,*arrIdentifire;
    NSMutableString *strUserId;
    NSMutableString *strUserToken,*strRequsetId;
    NSUserDefaults *pref;
}

@end

@implementation SideBarVC

@synthesize ViewObj;


#pragma mark - Init

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
//    pref = [[NSUserDefaults alloc]init];
    internet=[APPDELEGATE connected];
}

-(void)viewWillAppear:(BOOL)animated
{
    pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"DataUpdated"
                                               object:nil];
    
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    [self.imgProfilePic applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    NSLog(@"Arrayuser-%@,",arrUser);
    [self.imgProfilePic downloadFromURL:[arrUser valueForKey:PREF_USER_PICTURE] withPlaceholder:nil];
    self.lblName.font=[UberStyleGuide fontRegularBold:15];
    self.lblName.text=[NSString stringWithFormat:@"%@ %@",[arrUser valueForKey:@"first_name"],[arrUser valueForKey:@"last_name"]];
     NSLog(@"Arrayuser-%@,",self.lblName.text);
    arrIdentifire=[[NSMutableArray alloc]initWithObjects:SEGUE_PROFILE,SEGUE_TO_HISTORY,SEGUE_TO_SETTINGS, SEGUE_SHARE, nil];
    arrListName=[[NSMutableArray alloc]initWithObjects:NSLocalizedStringFromTable(@"PROFILE",[pref objectForKey:@"TranslationDocumentName"],nil),NSLocalizedStringFromTable(@"History",[pref objectForKey:@"TranslationDocumentName"],nil),NSLocalizedStringFromTable(@"Settings",[pref objectForKey:@"TranslationDocumentName"],nil),NSLocalizedStringFromTable(@"Share",[pref objectForKey:@"TranslationDocumentName"],nil),nil];
    
    arrImages=[[NSMutableArray alloc]initWithObjects:@"nav_profile",@"ub__nav_history",@"nav_settings",@"nav_share",nil];
    
    
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    NSMutableArray *arrImg=[[NSMutableArray alloc]init];
    for (int i=0; i<arrPage.count; i++)
    {
        NSMutableDictionary *temp1=[arrPage objectAtIndex:i];
        [arrTemp addObject:[temp1 valueForKey:@"title"]];
        [arrImg addObject:@"nav_support"];
    }
    
    [arrListName addObjectsFromArray:arrTemp];
    [arrImages addObjectsFromArray:arrImg];
    
    [arrListName addObject:NSLocalizedStringFromTable(@" Instant Job",[pref objectForKey:@"TranslationDocumentName"],nil)];
    [arrImages addObject:@"nav_Instantjob"];
    
    [arrListName addObject:NSLocalizedStringFromTable(@"Logout",[pref objectForKey:@"TranslationDocumentName"],nil)];
    [arrImages addObject:@"ub__nav_logout"];
    
    
    self.navigationItem.leftBarButtonItem=nil;
    
    self.tableView.backgroundView=nil;
    self.tableView.backgroundColor=[UIColor clearColor];
}


-(void)handleUpdatedData:(NSNotification *)notification
{
    NSLog(@"recieved");
    [self.tableView reloadData];
    [self viewDidLoad];
}


#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrListName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellSlider *cell=(CellSlider *)[tableView dequeueReusableCellWithIdentifier:@"CellSlider"];
    if (cell==nil) {
        cell=[[CellSlider alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSlider"];
    }
    cell.lblName.font=[UberStyleGuide fontSemiBold];
    cell.lblName.text=[[arrListName objectAtIndex:indexPath.row]uppercaseString];
    cell.imgIcon.image=[UIImage imageNamed:[arrImages objectAtIndex:indexPath.row]];
    
    //[cell setCellData:[arrSlider objectAtIndex:indexPath.row] withParent:self];[NSString stringWithFormat:@"%ld",(long)indexPath.row]
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([[arrListName objectAtIndex:indexPath.row]isEqualToString:NSLocalizedStringFromTable(@"Logout",[pref objectForKey:@"TranslationDocumentName"],nil)])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"Logout",[pref objectForKey:@"TranslationDocumentName"],nil)  message:NSLocalizedStringFromTable(@"Are Sure You want to log Out",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"NO", [pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:NSLocalizedStringFromTable(@"YES",[pref objectForKey:@"TranslationDocumentName"],nil), nil];
        alert.tag=100;
        [alert show];
        return;
    }
    
    if ([[arrListName objectAtIndex:indexPath.row]isEqualToString:NSLocalizedStringFromTable(@" Instant Job",[pref objectForKey:@"TranslationDocumentName"],nil)])
    {
        NSLog(@"InstantJob Dialog");
        [[AppDelegate sharedAppDelegate]showToastMessage:@"Instant Job"];
        [self CreateInstantJob];
        return;
    }

    
    if ([[arrListName objectAtIndex:indexPath.row]isEqualToString:NSLocalizedStringFromTable(@"Share", [pref objectForKey:@"TranslationDocumentName"],nil)])
    {
        NSLog(@"shareButton pressed");
        
        NSString *texttoshare = [NSString stringWithFormat:@"I am using Blaze Driver App ! Why don't you try it out... Install Blaze Driver now ! "]; //this is your text string to share
        //UIImage *imagetoshare = @""; //this is your image to share
        NSArray *activityItems = @[texttoshare];
        
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
        [self presentViewController:activityVC animated:TRUE completion:nil];

        return;
    }
    
    if ((indexPath.row >3)&&(indexPath.row<(arrListName.count-1)))
    {
        [self.revealViewController rightRevealToggle:self];
        
        UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
        
        ViewObj=(PickMeUpMapVC *)[nav.childViewControllers objectAtIndex:0];
        
        
        
        NSDictionary *dictTemp=[arrPage objectAtIndex:indexPath.row-4];
              
        [ViewObj performSegueWithIdentifier:@"contact us" sender:dictTemp];
        return;
    }
    [self.revealViewController rightRevealToggle:self];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    ViewObj=(PickMeUpMapVC *)[nav.childViewControllers objectAtIndex:0];
    
    if(ViewObj!=nil)
        [ViewObj goToSetting:[arrIdentifire objectAtIndex:indexPath.row]];
}

#pragma mark - Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_LOGOUT",[pref objectForKey:@"TranslationDocumentName"],nil)];
            
            
            if(internet)
            {
                
                    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
                    
                    [dictparam setObject:strUserId forKey:PARAM_ID];
                    [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
                    
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_LOGOUT withParamData:dictparam withBlock:^(id response, NSError *error)
                     {
                         
                         NSLog(@"Log Out= %@",response);
                         [APPDELEGATE hideLoadingView];
                         if (response)
                         {
                             if([[response valueForKey:@"success"] intValue]==1)
                             {
                                 NSLog(@"Response--%@",response);
                                 NSDictionary *set = response;
                                 ProviderLogout *tester = [RMMapper objectWithClass:[ProviderLogout class] fromDictionary:set];
                                 NSLog(@"Tdata: %@",tester.success);
                                 pref=[NSUserDefaults standardUserDefaults];
                                 [pref synchronize];
                                 [pref removeObjectForKey:PARAM_REQUEST_ID];
                                 [pref removeObjectForKey:PARAM_SOCIAL_ID];
                                 [pref removeObjectForKey:PREF_EMAIL];
                                 [pref removeObjectForKey:PREF_LOGIN_BY];
                                 [pref removeObjectForKey:PREF_PASSWORD];
                                 [pref removeObjectForKey:PREF_USER_ID];
                                 [pref removeObjectForKey:PREF_USER_TOKEN];
                                 [pref setBool:NO forKey:PREF_IS_LOGIN];
                                 
                                 [pref setObject:@"" forKey:PREF_USER_ID];
                                 [pref setObject:@"" forKey:PREF_USER_TOKEN];
                                 [pref synchronize];
                                 
                                 
                                 
//                                 if ([self.delegate respondsToSelector:@selector(invalidateTimer)])
//                                 {
//                                     [self.delegate invalidateTimer];
//                                 }
                                 
                                 
                                 [self.navigationController   popToRootViewControllerAnimated:YES];
                                 [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"LOGED_OUT",[pref objectForKey:@"TranslationDocumentName"],nil)];
                                 
                             }
                         }
                         
                     }];

            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET", [pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            
            
        }
    }
}

#pragma mark - Creating Instant Job & its API Methods

-(void)CreateInstantJob
{
    if(internet)
    {
        
        NSString *Phone_Number = [arrUser valueForKey:@"phone"];
        NSLog(@"Phone Number %@",Phone_Number);
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:Phone_Number forKey:PARAM_PHONE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_CREATE_INSTANTJOB withParamData:dictparam withBlock:^(id response, NSError *error)
        {
             
             NSLog(@"Instant Job Create Request Response = %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     InstantRequestID = [[response valueForKey:@"requests"] valueForKey:@"id"];
                     strRequsetId =[[response valueForKey:@"requests"] valueForKey:@"id"];
                     [pref setObject:InstantRequestID forKey:PREF_REQUEST_ID];
                     [pref synchronize];
                     NSLog(@"InstReqID = %@",InstantRequestID);
                     [self checkRequest];
//                     [self.revealViewController rightRevealToggle:self];
//                    [self.navigationController popToViewController: animated:YES];
                 }
             }
            if([[response valueForKey:@"success"] intValue]==0)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }];

    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET", [pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}




#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)checkRequest
{
    if(internet)
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        NSLog(@"parm-ID %@",strUserId);
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_GET_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"Check Request= %@",response);
             
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSMutableDictionary *dictRequest=[response valueForKey:@"request"];
                     
                     is_completed=[[dictRequest valueForKey:@"is_completed"]intValue];
                     is_dog_rated=[[dictRequest valueForKey:@"is_dog_rated"]intValue];
                     is_started=[[dictRequest valueForKey:@"is_started" ]intValue];
                     is_walker_arrived=[[dictRequest valueForKey:@"is_walker_arrived"]intValue];
                     is_walker_started=[[dictRequest valueForKey:@"is_walker_started"]intValue];
                     
                     NSDictionary *dictOwner;
                     dictOwner=[dictRequest valueForKey:@"owner"];;//[arrOwner objectAtIndex:0];
                     strowner_lati=[dictOwner valueForKey:@"latitude"];
                     strowner_longi=[dictOwner valueForKey:@"longitude"];
                     payment=[[dictRequest valueForKey:@"payment_type"] integerValue];
                     
                     
                     NSString *gmtDateString = [dictRequest valueForKey:@"start_time"];
                     NSDateFormatter *df = [NSDateFormatter new];
                     [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                     df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                     NSDate *datee = [df dateFromString:gmtDateString];
                     df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
                     
                     NSString *startTime=[NSString stringWithFormat:@"%f",[datee timeIntervalSince1970] * 1000];
                     
                     pref=[NSUserDefaults standardUserDefaults];
                     [pref setObject:startTime forKey:PREF_START_TIME];
                     [pref synchronize];
                     
                     
                     [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
                     [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
                     [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
                     [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
                     [pref synchronize];
//                     [mapView_ clear];
                     
                     [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"PLEASE_WAIT",[pref objectForKey:@"TranslationDocumentName"],nil)];
                     [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
                     // [self respondToRequset];
                     
                 }
//                 else
//                 {
//                     pref=[NSUserDefaults standardUserDefaults];
//                     [pref removeObjectForKey:PREF_REQUEST_ID];
//                     strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
//                     [self getRequestId];
//                 }
             }
             
             
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"segurtoarrived"])
     {
         ArrivedMapVC *obj = [segue destinationViewController];
         obj.InstantJobNavigate = @"FromSidebar";
     }

 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.  sw_front
 }


@end
