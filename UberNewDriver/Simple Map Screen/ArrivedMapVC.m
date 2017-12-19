//
//  ArrivedMapVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "ArrivedMapVC.h"
#import "RegexKitLite.h"
#import <MapKit/MapKit.h>
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "PickMeUpMapVC.h"
#import "RatingBar.h"
#import "UIView+Utils.h"
#import "SWRevealViewController.h"
#import "ProviderRating.h"
#import "ProviderRequestLocation.h"
#import "RequestWalkCompleted.h"
#import "RequestWalkCompletedDetail.h"
#import "MZTimerLabel.h"
@interface ArrivedMapVC ()<SWRevealViewControllerDelegate>
{
    CLLocationManager *locationManager;
    
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    NSString *startTime;
    NSString *endTime;
    BOOL flag,isTo;
    int time,flagForNav;
    float totalDist;
    
    NSMutableString *strOwnerName;
    NSMutableString *strOwnerPhone;
    NSMutableString *strOwnerRate;
    NSMutableString *strOwnerPicture;
    
    NSString *strDesti_Latitude;
    NSString *strDesti_Longitude;
    
    CLLocation *locA,*locB, *walkOldLocation;
    NSString * strStart_lati;
    NSString * strStart_longi;
    NSMutableArray *arrPath;
    
    GMSMutablePath *pathUpdates;
    GMSMutablePath *pathpolilineDest;
    GMSMutablePath *pathNav;
    SWRevealViewController *revealViewController;
    NSUserDefaults *prefl;
    MZTimerLabel *stopwatch2;NSString *PauseBtnTag,*Waiting_Time;
    NSString *LatestTime,*Dograted;
    CGFloat screenWidth,screenHeight;CGRect screenRect;
    CLLocationDistance distance;
}

@end

@implementation ArrivedMapVC

@synthesize btnArrived,btnJob,btnWalk,btnWalker,btnTime,pickMeUp,lblPayment;

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
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    NSLog(@"Screen Width %f",screenWidth);
    NSLog(@"Screen Height %f",screenHeight);
    [super viewDidLoad];
    prefl = [[NSUserDefaults alloc]init];
    [self.TimerView setHidden:YES];
    
    [self AdaptiveLayoutIPhoneResolution];    //[self  performSegueWithIdentifier:@"jobToFeedback" sender:self];
    [self localizeString];
    self.revealViewController.delegate = self;

    [self.imgProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    
    [btnWalker setHidden:NO];
    [btnWalk setHidden:YES];
    [btnJob setHidden:YES];
    [btnArrived setHidden:YES];
    
    //self.lblDestAddress.numberOfLines=2;
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    [self.TimerView setHidden:YES];
    [self.btnWait setHidden:YES];
    [self.btnPause setHidden:YES];
    self.TimerLabel.textColor = [UberStyleGuide colorDefault];
    /*
    SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
    curLoc.yTag=1001;
    
    [self.mapView addAnnotation:curLoc];
     
     */
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current.latitude
                                                            longitude:current.longitude
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:self.mapView_.bounds camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.mapView_ addSubview:mapView_];
    mapView_.delegate=self;
    // Creates a marker in the center of the map.
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showUserLoc) userInfo:nil repeats:NO];
    
    
    isTo=NO;
    
    CLLocationCoordinate2D currentOwner;
    currentOwner.latitude=[strowner_lati doubleValue];
    currentOwner.longitude=[strowner_longi doubleValue];
    
    
    // [self showRouteFrom:current to:currentOwner];
    /*
    SBMapAnnotation *curLocOwn=[[SBMapAnnotation alloc]initWithCoordinate:currentOwner];
    curLocOwn.yTag=1000;
    
    
    [self.mapView addAnnotation:curLocOwn];
     
     */
    
    
    // Creates a marker in the center of the map.
   markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = currentOwner;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
    [self centerMapFirst:current two:currentOwner third:current];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strOwnerName=[pref objectForKey:PREF_USER_NAME];
    strOwnerPhone=[pref objectForKey:PREF_USER_PHONE];
    strOwnerRate=[pref objectForKey:PREF_USER_RATING];
    strOwnerPicture=[pref objectForKey:PREF_USER_PICTURE];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    
    flagForNav=[[pref objectForKey:PREF_NAV] integerValue];
    if (flagForNav==1)
    {
        [self.btnNav setHidden:YES];
        [self drawNavPath];
    }
    else
    {
        [self.btnNav setHidden:NO];
    }
    
    if (payment==0)
    {
        self.lblPayment.text = NSLocalizedStringFromTable(@"CARD", [prefl objectForKey:@"TranslationDocumentName"],nil);
    }
    else if (payment==1)
    {
        self.lblPayment.text = NSLocalizedStringFromTable(@"CASH",[prefl objectForKey:@"TranslationDocumentName"],nil);
    }
    
    self.lblUserName.text=strOwnerName;
    self.lblUserPhone.text=strOwnerPhone;
    self.lblUserRate.text=[NSString stringWithFormat:@"%.1f",[strOwnerRate floatValue]];;
    [self.imgProfile downloadFromURL:strOwnerPicture withPlaceholder:nil];
    
    [self.ratingView initRateBar];
    [self.ratingView setRatings:([strOwnerRate floatValue]*2)];
    [self.ratingView setUserInteractionEnabled:NO];
    
    [self.btnDistance setTitle:@"0" forState:UIControlStateNormal];
    [self.btnTime setTitle:[NSString stringWithFormat:@"0 %@",NSLocalizedStringFromTable(@"Mins", [prefl objectForKey:@"TranslationDocumentName"],nil)] forState:UIControlStateNormal];
    [self checkRequest];
    [self customFont];
    
//    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.panGuestureview addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        //        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    totalDist=0;
    //  Do any additional setup after loading the view.
}


-(void)AdaptiveLayoutIPhoneResolution
{
    if (![self.InstantJobNavigate isEqualToString:@"FromSidebar"])
    {
        [self.ratingView setHidden:NO];
    }
    else
    {
        
        if (screenHeight == 568.000000)
        {
            NSLog(@"Standard Resolution Device");
            [self.ratingView setHidden:YES];
            [self.TimerView setHidden:YES];
            [self.btnCall setHidden:YES];
            [self.lblCallUser setHidden:YES];
            [self.ImgCalluser setHidden:YES];
            [self.linedivide3 setHidden:YES];
            self.linedivide1.frame = CGRectMake(112, 474, 1, 41);
            self.linedivide2.frame = CGRectMake(207, 474, 1, 41);
            self.btnTime.frame = CGRectMake(20, 501, 79, 18);
            self.btnDistance.frame=CGRectMake(125, 501, 70, 18);
            self.lblPayment.frame=CGRectMake(230, 499, 58, 21);
            self.ImageClock.frame=CGRectMake(40, 473, 25, 25);
            self.ImageMiles.frame=CGRectMake(145, 473, 25, 25);
            self.ImageCash.frame=CGRectMake(245, 473, 25, 25);
        }
        if (screenHeight == 667.000000)
        {
            NSLog(@"High Resolution Device");
            [self.ratingView setHidden:YES];
            [self.TimerView setHidden:YES];
            [self.btnCall setHidden:YES];
            [self.lblCallUser setHidden:YES];
            [self.ImgCalluser setHidden:YES];
            [self.linedivide3 setHidden:YES];
            self.linedivide1.frame = CGRectMake(128, 570, 1, 41);
            self.linedivide2.frame = CGRectMake(239, 570, 1, 41);
            self.btnTime.frame = CGRectMake(25, 597, 79, 18);
            self.btnDistance.frame=CGRectMake(145, 597, 70, 18);
            self.lblPayment.frame=CGRectMake(270, 596, 58, 21);
            self.ImageClock.frame=CGRectMake(50, 569, 25, 25);
            self.ImageMiles.frame=CGRectMake(165, 569, 25, 25);
            self.ImageCash.frame=CGRectMake(285, 569, 25, 25);
        }
        if (screenHeight == 736.000000)
        {
            NSLog(@"iPhone 7 & 7plus");
            [self.ratingView setHidden:YES];
            [self.TimerView setHidden:YES];
            [self.btnCall setHidden:YES];
            [self.lblCallUser setHidden:YES];
            [self.ImgCalluser setHidden:YES];
            [self.linedivide3 setHidden:YES];
            self.linedivide1.frame = CGRectMake(132, 639, 1, 41);
            self.linedivide2.frame = CGRectMake(277, 639, 1, 41);
            self.btnTime.frame = CGRectMake(40, 666, 79, 18);
            self.btnDistance.frame=CGRectMake(175, 666, 70, 18);
            self.lblPayment.frame=CGRectMake(310, 664, 58, 21);
            self.ImageClock.frame=CGRectMake(60, 638, 25, 25);
            self.ImageMiles.frame=CGRectMake(195, 638, 25, 25);
            self.ImageCash.frame=CGRectMake(325, 638, 25, 25);
        }
        
    }
    
}




-(void)viewWillAppear:(BOOL)animated
{
    
    walkOldLocation =[[CLLocation alloc]initWithLatitude:0.0000000 longitude:0.00000];
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"MENU",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
    [self checkRequestStatus];
    [self checkForCancleRequest];
    
    strDesti_Latitude=@"";
    strDesti_Longitude=@"";
    
    [self checkForDestinationAddr];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timerForDestinationAddr = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForDestinationAddr) userInfo:nil repeats:YES];
    [runloop addTimer:self.timerForDestinationAddr forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timerForDestinationAddr forMode:UITrackingRunLoopMode];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [APPDELEGATE hideLoadingView];
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"MENU",[prefl objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark-

-(void)customFont
{
    btnWalker=[APPDELEGATE setBoldFontDiscriptor:btnWalker];
    btnArrived=[APPDELEGATE setBoldFontDiscriptor:btnArrived];
    btnWalk=[APPDELEGATE setBoldFontDiscriptor:btnWalk];
    btnJob=[APPDELEGATE setBoldFontDiscriptor:btnJob];
    self.btnCall.titleLabel.font=[UberStyleGuide fontRegularBold:12.0f];
    self.btnDistance.titleLabel.font=[UberStyleGuide fontRegular:12.0f];
    self.btnTime.titleLabel.font=[UberStyleGuide fontRegular:12.0f];
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.lblUserName.font=[UberStyleGuide fontRegular];
    self.btnCall.titleLabel.textColor=[UberStyleGuide colorDefault];
}
-(void)localizeString
{
    
    [self.lblCallUser setText:NSLocalizedStringFromTable(@"CALL USER",[prefl objectForKey:@"TranslationDocumentName"],nil)];
    
    [btnWalker setTitle:NSLocalizedStringFromTable(@"TAP WHEN STARTED",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateNormal];
    [btnWalker setTitle:NSLocalizedStringFromTable(@"TAP WHEN STARTED",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateSelected];
    [btnWalker setTitle:NSLocalizedStringFromTable(@"TAP WHEN STARTED",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateHighlighted];
    [self.btnWalk setTitle:NSLocalizedStringFromTable(@"START TRIP",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateNormal];
    [self.btnWalk setTitle:NSLocalizedStringFromTable(@"START TRIP",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateSelected];
    [self.btnWalk setTitle:NSLocalizedStringFromTable(@"START TRIP",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateHighlighted];
    [self.btnJob setTitle:NSLocalizedStringFromTable(@"END TRIP",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateNormal];
    [self.btnJob setTitle:NSLocalizedStringFromTable(@"END TRIP",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateSelected];
    [self.btnJob setTitle:NSLocalizedStringFromTable(@"END TRIP",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateHighlighted];
    [self.btnArrived setTitle:NSLocalizedStringFromTable(@"TAP WHEN ARRIVED",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateNormal];
    [self.btnArrived setTitle:NSLocalizedStringFromTable(@"TAP WHEN ARRIVED",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateSelected];
    [self.btnArrived setTitle:NSLocalizedStringFromTable(@"TAP WHEN ARRIVED",[prefl objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateHighlighted];
    
    [self.btnconfirm_rejctnview setTitle:NSLocalizedStringFromTable(@"CONFIRM",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateNormal];
    [self.btncancel_rejectionview setTitle:NSLocalizedStringFromTable(@"Cancel",[prefl objectForKey:@"TranslationDocumentName"], nil) forState:UIControlStateNormal];
    [self.enterfld_rejctnview setText:NSLocalizedStringFromTable(@"ENTER",[prefl objectForKey:@"TranslationDocumentName"], nil)];
    [self.lblrejectionreason setText:NSLocalizedStringFromTable(@"Enter_reject_reason",[prefl objectForKey:@"TranslationDocumentName"], nil)];
}


#pragma mark-
#pragma mark- User Location


-(void)showUserLoc
{
    MKCoordinateRegion region;
    region.center.latitude     = [struser_lati doubleValue];
    region.center.longitude    = [struser_longi doubleValue];
    region.span.latitudeDelta = 1.5;
    region.span.longitudeDelta = 1.5;
   
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=[struser_lati doubleValue];
    coordinate.longitude=[struser_longi doubleValue];

    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:15];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];

    //[self.mapView setRegion:region animated:YES];
}
#pragma mark - SWRevealViewController Delegate Methods

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        [self.panGuestureview setHidden:YES];
    } else {
        [self.panGuestureview setHidden:NO];
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        [self.panGuestureview setHidden:YES];
        
    } else {
        [self.panGuestureview setHidden:NO];
    }
}
#pragma mark-
#pragma mark- Check request Status


-(void)checkRequest
{
    if(is_walker_started==1)
    {
        [self getUserLocation];
        if (is_walker_arrived==1)
        {
            if (is_started==1)
            {
                if (is_completed==1)
                {
                    if (is_dog_rated==1)
                    {
                        
                    }
                    else
                    {
                        [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"PLEASE_WAIT",[prefl objectForKey:@"TranslationDocumentName"],nil)];

                        [self performSegueWithIdentifier:@"jobToFeedback" sender:self];
                    }
                }
                else
                {
                    
                    [btnWalker setHidden:YES];
                    [btnArrived setHidden:YES];
                    [btnWalk setHidden:YES];
                    [btnJob setHidden:NO];
                    
                    arrPath=[[NSMutableArray alloc]init];
                    [self requestPath];
                    [self.pickMeUp.timer invalidate];
                    self.pickMeUp.timer=nil;
                    
                    
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    [pref synchronize];
                    startTime=[pref objectForKey:PREF_START_TIME];
                    [self updateTime];
                    
                    if (distance>=5.000000)
                    {
                        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                        self.timeForUpdateWalkLoc = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateWalkLocation) userInfo:nil repeats:YES];
                        [runloop addTimer:self.timeForUpdateWalkLoc forMode:NSRunLoopCommonModes];
                        [runloop addTimer:self.timeForUpdateWalkLoc forMode:UITrackingRunLoopMode];
                    }
                    
                    
                    NSRunLoop *runloop1 = [NSRunLoop currentRunLoop];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                    [runloop1 addTimer:self.timer forMode:NSRunLoopCommonModes];
                    [runloop1 addTimer:self.timer forMode:UITrackingRunLoopMode];
                    
                    
                }
            }
            else
            {
                [btnWalker setHidden:YES];
                [btnArrived setHidden:YES];
                [btnWalk setHidden:NO];
            }
        }
        else
        {
            [btnWalker setHidden:YES];
            [btnArrived setHidden:NO];
        }
    }
}
#pragma mark-
#pragma mark- API Method

#pragma mark-
#pragma mark- API Methods

-(void)checkRequestStatus
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if([APPDELEGATE connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
       //strRequsetId
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_GET_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
         {
            
             NSLog(@"Check Request= %@",response);
             if (response) {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSMutableDictionary *dictRequest=[response valueForKey:@"request"];
                     
                     is_completed=[[dictRequest valueForKey:@"is_completed"]intValue];
                     is_dog_rated=[[dictRequest valueForKey:@"is_dog_rated"]intValue];
                     is_started=[[dictRequest valueForKey:@"is_started" ]intValue];
                     is_walker_arrived=[[dictRequest valueForKey:@"is_walker_arrived"]intValue];
                     is_walker_started=[[dictRequest valueForKey:@"is_walker_started"]intValue];
                     // [self respondToRequset];
                     if (is_walker_started == 1)
                     {
                     }
                     if (is_walker_arrived==1)
                     {
                         [self.TimerView setHidden:YES];
                         [self.btnNav setHidden:YES];
                         [self.timerForCancelRequest invalidate];
                         [self.btnWait setHidden:NO];
//                         self.btnWalk.frame = CGRectMake(160, 523, 160, 45);
                         if ([[pref objectForKey:@"WaitButton"] isEqualToString:@"WaitClicked"])
                         {
                             [self.TimerView setHidden:YES];
                             self.TimerLabel.text=[pref objectForKey:@"TIMEWAITED"];
                             //                             [self Timer_Action];
                             
                         }

                     }
                     if (is_started==1)
                     {
                         [self.btnCancelTrip setHidden:YES];
                         [self.timerForCancelRequest invalidate];
                         [self.btnWait setHidden:NO];
//                         self.btnJob.frame = CGRectMake(160, 523, 160, 45);
                         if ([[pref objectForKey:@"WaitButton"] isEqualToString:@"WaitClicked"])
                         {
                             [self.TimerView setHidden:YES];
                             self.TimerLabel.text=[pref objectForKey:@"TIMEWAITED"];
//                             [self Timer_Action];
                             
                         }
                     }
                     if (is_completed==0)
                     {
                         NSLog(@"Hii = %@",[dictRequest valueForKey:@"time"]);
                         totalDist=[[dictRequest valueForKey:@"distance"]floatValue];
                         if ([dictRequest valueForKey:@"unit"]==nil)
                         {
                             //self.btnDistance.titleLabel.text=[dictRequest valueForKey:@"distance"];
                             if ([dictRequest valueForKey:@"distance"]!=nil)
                             {
                                 [self.btnDistance setTitle:[dictRequest valueForKey:@"distance"] forState:UIControlStateNormal];
                                 [btnTime setTitle:[NSString stringWithFormat:@"%ld %@",(long)[LatestTime integerValue],NSLocalizedStringFromTable(@"Mins",[prefl objectForKey:@"TranslationDocumentName"],nil)] forState:UIControlStateNormal];
                             }
                             
                         }
                         else
                         {
                             [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[dictRequest valueForKey:@"distance"] floatValue],[dictRequest valueForKey:@"unit"]] forState:UIControlStateNormal];
                         }
                         
                     }
                     else if(is_completed==1)
                     {
                         self.TimerLabel.text = @"00:00:00";
                         [pref setObject:@"00:00:00" forKey:@"TIMEWAITED"];
                         [pref synchronize];
                         dictBillInfo=[[response objectForKey:@"request"] valueForKey:@"bill"];
                         [self.timerForDestinationAddr invalidate];
                         [self.timeForUpdateWalkLoc invalidate];
                         
                     }
                 }
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[prefl objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[prefl objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[prefl objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


-(void)walkerStarted
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WLKER_STARTED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSLog(@"Response--%@",response);
                     NSDictionary *set = response;
                     ProviderRating* tester = [RMMapper objectWithClass:[ProviderRating class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                     [self getUserLocation];
                     [btnWalker setHidden:YES];
                     [btnArrived setHidden:NO];
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"WALKER_STARTED",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                 }
             }
             
         }];
    }
}



-(void)arrivedRequest
{
    
    if (![self.InstantJobNavigate isEqualToString:@"FromSidebar"])
    {
        [self.TimerView setHidden:YES];
        [self.btnWait setHidden:NO];
//        self.btnWalk.frame = CGRectMake(160, 523, 160, 45);
    }
    
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WLKER_ARRIVED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
            if (response)
             {
                 is_walker_arrived=1;
                 [pref removeObjectForKey:PREF_NAV];
                 flagForNav=[[pref objectForKey:PREF_NAV] integerValue];
                 [self.btnNav setHidden:YES];
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSLog(@"Response--%@",response);
                     NSDictionary *set = response;
                     ProviderRating* tester = [RMMapper objectWithClass:[ProviderRating class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                     [btnArrived setHidden:YES];
                     [btnWalk setHidden:NO];
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"WALKER_ARRIVED",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                 }
             }
             
         }];
    }
}

//******************* Label Timer Begins******************

-(void)Timer_Action
{
    stopwatch2 = [[MZTimerLabel alloc] initWithLabel:self.TimerLabel];
    [stopwatch2 start];
    [self.TimerView.layer setCornerRadius:10.0];
    
}
- (IBAction)BtnPause:(id)sender
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [stopwatch2 pause];
    [self.btnPause setHidden:YES];
    [self.btnWait setHidden:NO];
    PauseBtnTag = @"Pause";
    Waiting_Time = self.TimerLabel.text;
    [pref setObject:Waiting_Time forKey:@"TIMEWAITED"];
    [pref synchronize];
    NSLog(@"Time Waited %@",Waiting_Time);
    NSLog(@"Time Waited Preference%@",[pref objectForKey:@"TIMEWAITED"]);
}

- (IBAction)BtnWait:(id)sender
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:@"WaitClicked" forKey:@"WaitButton"];
    [pref synchronize];
    if ([PauseBtnTag isEqualToString:@"Pause"])
    {
        [stopwatch2 start];
        [self.TimerView setHidden:NO];
        [self.btnWait setHidden:YES];
        [self.btnPause setHidden:NO];
    }
    else
    {
        [self Timer_Action];
        [self.TimerView setHidden:NO];
        [self.btnPause setHidden:NO];
    }
//    [stopwatch pause];
}
//******************* Label Timer Ends ********************

-(void)walkStarted
{
    [self.btnCancelTrip setHidden:YES];
    [self.btnWait setHidden:NO];
//    self.btnJob.frame = CGRectMake(160, 523, 160, 45);
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WALK_STARTED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSLog(@"Response %@",response);
                     NSDictionary *set = response;
                     ProviderRating* tester = [RMMapper objectWithClass:[ProviderRating class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                     is_started=1;
                     [self drawPath];
                     
                     [self.pickMeUp.timer invalidate];
                     self.pickMeUp.timer=nil;
                     [self.timerForCancelRequest invalidate];
                     //[self.timerForDestinationAddr invalidate];
                     
                     if (distance>=5.000000)
                     {
                         NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                         self.timeForUpdateWalkLoc = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateWalkLocation) userInfo:nil repeats:YES];
                         [runloop addTimer:self.timeForUpdateWalkLoc forMode:NSRunLoopCommonModes];
                         [runloop addTimer:self.timeForUpdateWalkLoc forMode:UITrackingRunLoopMode];
                     }
                     
                     
                     [self getUserLocation];
                     [btnWalk setHidden:YES];
                     [btnJob setHidden:NO];
                     //strStart_lati=struser_lati;
                     // strStart_longi=struser_longi;
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"WALK_STARTED",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                 }
             }
             
         }];
    }
}

-(void)ConvertWaitingTime
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *WaitTime = [pref objectForKey:@"TIMEWAITED"];
    NSLog(@"Time Waited %@",WaitTime);
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    timeFormat.dateFormat = @"hh:mm a";
    NSDate *timeIs = [timeFormat dateFromString:WaitTime];
    timeFormat.dateFormat = @"HH:mm";
    NSString *a24timeIs = [timeFormat stringFromDate:timeIs];
    NSLog(@"24Hour Time %@",a24timeIs);
    
    [timeFormat setDateFormat:@"h:mm a"];
    NSString *strDate = [timeFormat stringFromDate:timeIs];
    NSLog(@"StrDate Time %@",strDate);
}


-(void)jobDone
{
    
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    NSString *WaitTime = [pref objectForKey:@"TIMEWAITED"];
    
    NSString *strs = [WaitTime stringByReplacingOccurrencesOfString:@"00:0"
                                         withString:@" "];
    
    NSLog(@"Time Waited STR %ld",(long)[strs integerValue]);
    
//    [self ConvertWaitingTime];
    
    if (strRequsetId!=nil)
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        [dictparam setObject:[NSString stringWithFormat:@"%.2f",totalDist] forKey:PARAM_DISTANCE];
        [dictparam setObject:[NSString stringWithFormat:@"%ld",(long)[strs integerValue] ] forKey:@"trip_waiting_time"];
        [dictparam setObject:[NSString stringWithFormat:@"%ld",(long)[strs integerValue] ] forKey:@"total_waiting_time"];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WALK_COMPLETED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSLog(@"Job Done Response %@",response);
                     Dograted = [response valueForKey:@""];
                     NSDictionary *set = response;
                     RequestWalkCompleted* tester = [RMMapper objectWithClass:[RequestWalkCompletedDetail class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                    [self.timerForDestinationAddr invalidate];
                     NSString *distance= self.btnDistance.titleLabel.text;
                     NSArray *arrDistace=[distance componentsSeparatedByString:@" "];
                     float dist;
                     if (arrDistace.count!=0)
                     {
                         
                         dist=[[arrDistace objectAtIndex:0]floatValue];
                         if (arrDistace.count>1)
                         {
                             
                             if ([[arrDistace objectAtIndex:1] isEqualToString:@"kms"])
                             {
                                 dist=dist*0.621371;
                                 
                             }
                             
                         }
                     }
                     
                     dictBillInfo=[[response objectForKey:@"request"] valueForKey:@"bill"];
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref setObject:[NSString stringWithFormat:@"%.2f",dist] forKey:PREF_WALK_DISTANCE];
                     [pref setObject:[NSString stringWithFormat:@"%ld",(long)[LatestTime integerValue]] forKey:PREF_WALK_TIME];
                     self.TimerLabel.text = @"00:00:00";
                     [pref setObject:@"00:00:00" forKey:@"TIMEWAITED"];
                     [pref synchronize];
                     
                     [self.timeForUpdateWalkLoc invalidate];
                     
                     
                     [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"JOB_DONE",[prefl objectForKey:@"TranslationDocumentName"],nil)];
                     if ([[dictBillInfo valueForKey:@"payment_type"] integerValue]==1)
                     {
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"Please collect cash from client for your trip",[prefl objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[prefl objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:Nil, nil];
                         alert.tag=111;
                         [alert show];
                     }
                     else
                     {
                         [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"PLEASE_WAIT",[prefl objectForKey:@"TranslationDocumentName"],nil)];

                         [self  performSegueWithIdentifier:@"jobToFeedback" sender:self];
                     }
                     
                     
                 }
             }
             
         }];
    }
}

-(void)updateWalkLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([APPDELEGATE connected])
        {
            if(((struser_lati==nil)&&(struser_longi==nil))
               ||(([struser_longi doubleValue]==0.00)&&([struser_lati doubleValue]==0)))
            {
            }
            else
            {
                
                NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                strUserId = [pref valueForKey:PARAM_ID];
                strUserToken = [pref valueForKey:PARAM_TOKEN];

                NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
                [dictparam setObject:strUserId forKey:PARAM_ID];
                [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
                [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
                [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
                [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
                [dictparam setObject:@"0" forKey:PARAM_DISTANCE];
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_WALK_LOCATION withParamData:dictparam withBlock:^(id response, NSError *error)
                 {
                     
                     NSLog(@"Update Walk Location = %@",response);
                     NSLog(@"Response %@",response);
                     NSDictionary *set = response;
                     ProviderRequestLocation *tester = [RMMapper objectWithClass:[ProviderRequestLocation class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                     if (response)
                     {
                         
                         LatestTime = [response valueForKey:@"time"];
                        
                         payment=[[response valueForKey:@"payment_type"] boolValue];
                         if (payment==0)
                         {
                             self.lblPayment.text = NSLocalizedStringFromTable(@"CARD",[prefl objectForKey:@"TranslationDocumentName"],nil);
                             [btnTime setTitle:[NSString stringWithFormat:@"%d %@",[LatestTime integerValue],NSLocalizedStringFromTable(@"Mins",[prefl objectForKey:@"TranslationDocumentName"],nil)] forState:UIControlStateNormal];
                         }
                         else if (payment==1)
                         {
                             self.lblPayment.text = NSLocalizedStringFromTable(@"CASH",[prefl objectForKey:@"TranslationDocumentName"],nil);
                             [btnTime setTitle:[NSString stringWithFormat:@"%d %@",[LatestTime integerValue],NSLocalizedStringFromTable(@"Mins",[prefl objectForKey:@"TranslationDocumentName"],nil)] forState:UIControlStateNormal];
                         }
                         
                         
                         if([[response valueForKey:@"success"] intValue]==1)
                         {
                             totalDist=[[response valueForKey:@"distance"]floatValue];
                             [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]] forState:UIControlStateNormal];
                         }
                         else
                         {
                             [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]] forState:UIControlStateNormal];
                             
                             if ([[response valueForKey:@"is_cancelled"] integerValue]==1)
                             {
                                 [self.timerForCancelRequest invalidate];
                                 [self.timerForDestinationAddr invalidate];
                                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                                 [pref removeObjectForKey:PREF_REQUEST_ID];
                                 [pref removeObjectForKey:PREF_NAV];
                                 strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
                                 
                                 
                                 [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"Request Canceled",[prefl objectForKey:@"TranslationDocumentName"],nil) ];
                                 
                                 
                                 is_walker_started=0;
                                 is_walker_arrived=0;
                                 is_started=0;
                                 [btnWalker setHidden:NO];
                                 [btnArrived setHidden:YES];
                                 [btnWalk setHidden:YES];
                                 
                                 [self.navigationController popToRootViewControllerAnimated:YES];
                                 
                             }
                         }
                     }
                     
                 }];
            }
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[prefl objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[prefl objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[prefl objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Blaze Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
        
    }
}

-(void)requestPath
{
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_REQUEST_PATH,PARAM_ID,strUserId,PARAM_TOKEN,strUserToken,PARAM_REQUEST_ID,strRequsetId];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         
         NSLog(@"Page Data= %@",response);
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [arrPath removeAllObjects];
                 arrPath=[response valueForKey:@"locationdata"];
                 [self drawPath];
             }
         }
         
     }];
}


-(void)checkForCancleRequest
{
    [self updateWalkLocation];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timerForCancelRequest = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateWalkLocation) userInfo:nil repeats:YES];
    [runloop addTimer:self.timerForCancelRequest forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timerForCancelRequest forMode:UITrackingRunLoopMode];
}

-(void)checkForDestinationAddr
{
    if([APPDELEGATE connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_GET_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"Check Destination Location= %@",response);
             if (response) {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSMutableDictionary *dictRequest=[response valueForKey:@"request"];
                     
                     is_completed=[[dictRequest valueForKey:@"is_completed"]intValue];
                     is_dog_rated=[[dictRequest valueForKey:@"is_dog_rated"]intValue];
                     is_started=[[dictRequest valueForKey:@"is_started" ]intValue];
                     is_walker_arrived=[[dictRequest valueForKey:@"is_walker_arrived"]intValue];
                     is_walker_started=[[dictRequest valueForKey:@"is_walker_started"]intValue];
                     
                     
                     if (([strDesti_Latitude doubleValue]!=[[dictRequest valueForKey:@"dest_latitude"] doubleValue]) || ([strDesti_Longitude doubleValue]!=[[dictRequest valueForKey:@"dest_longitude"] doubleValue]))
                     {
                         strDesti_Latitude=[dictRequest valueForKey:@"dest_latitude"];
                         strDesti_Longitude=[dictRequest valueForKey:@"dest_longitude"];
                         
                         CLLocationCoordinate2D currentOwner;
                         currentOwner.latitude=[strowner_lati doubleValue];
                         currentOwner.longitude=[strowner_longi doubleValue];
                         NSLog(@"Owner Coordinates %f %f",currentOwner.latitude,currentOwner.longitude);
                         CLLocationCoordinate2D DestiLocation;
                         DestiLocation.latitude=[strDesti_Latitude doubleValue];
                         DestiLocation.longitude=[strDesti_Longitude doubleValue];
                         NSLog(@"DestiLocation Coordinates %f %f",DestiLocation.latitude,DestiLocation.longitude);
                         [self.ratingView setHidden:YES];
                         [self getAddress];
                         [self showRouteFrom:currentOwner to:DestiLocation];
                         
                     }
//                     else
//                     {
//                         CLLocationCoordinate2D current;
//                         current.latitude=[struser_lati doubleValue];
//                         current.longitude=[struser_longi doubleValue];
//                         
//                         CLLocationCoordinate2D currentOwner;
//                         currentOwner.latitude=[strowner_lati doubleValue];
//                         currentOwner.longitude=[strowner_longi doubleValue];
//                         
//                         [self showRouteFrom:current to:currentOwner];
//
//                     }
                     
                }
             }
  
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[prefl objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[prefl objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[prefl objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }

}
#pragma mark -
#pragma mark - Google Api method
-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strDesti_Latitude floatValue], [strDesti_Longitude floatValue], [strDesti_Latitude floatValue], [strDesti_Longitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    if (getAddress.count!=0)
    {
        self.lblDestAddress.text=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
    
}

#pragma mark -
#pragma mark - Draw Route Methods

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}
-(void)centerMap:(NSArray*)locations
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    CLLocationCoordinate2D location;
    for (CLLocation *loc in locations)
    {
        location.latitude = loc.coordinate.latitude;
        location.longitude = loc.coordinate.longitude;
        // Creates a marker in the center of the map.
        bounds = [bounds includingCoordinate:location];
    }
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:10.0f]];
}

//-(void) centerMap
//{
//    MKCoordinateRegion region;
//    CLLocationDegrees maxLat = -90.0;
//    CLLocationDegrees maxLon = -180.0;
//    CLLocationDegrees minLat = 90.0;
//    CLLocationDegrees minLon = 180.0;
//    for(int idx = 0; idx < routes.count; idx++)
//    {
//        CLLocation* currentLocation = [routes objectAtIndex:idx];
//        if(currentLocation.coordinate.latitude > maxLat)
//            maxLat = currentLocation.coordinate.latitude;
//        if(currentLocation.coordinate.latitude < minLat)
//            minLat = currentLocation.coordinate.latitude;
//        if(currentLocation.coordinate.longitude > maxLon)
//            maxLon = currentLocation.coordinate.longitude;
//        if(currentLocation.coordinate.longitude < minLon)
//            minLon = currentLocation.coordinate.longitude;
//    }
//    region.center.latitude     = (maxLat + minLat) / 2.0;
//    region.center.longitude    = (maxLon + minLon) / 2.0;
//    region.span.latitudeDelta = 0.01;
//    region.span.longitudeDelta = 0.01;
//    
//    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
//    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
//    //[self.mapView setRegion:region animated:YES];
//    
//    
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude=region.center.latitude;
//    coordinate.longitude=region.center.longitude;
//    
////    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
////                                                            longitude:coordinate.longitude
////                                                                 zoom:13];
////    mapView_ = [GMSMapView mapWithFrame:mapView_.bounds camera:camera];
//    
//    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:15];
//    
//    [mapView_ animateWithCameraUpdate:updatedCamera];
//}

//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t


-(void) showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t
{
    if(routes)
    {
        //[self.mapView removeAnnotations:[self.mapView annotations]];
        [mapView_ clear];
        
        if (flagForNav==1 && is_walker_arrived!=1)
        {
            GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathNav];
            polyline.strokeColor = [UIColor colorWithRed:(155.0f/255.0f) green:(46.0f/255.0f) blue:(46.0f/255.0f) alpha:1.0];
            polyline.strokeWidth = 5.f;
            polyline.geodesic = YES;
            polyline.map = mapView_;
        }
        
    }
    
    //[self.mapView addAnnotation:f];
    //[self.mapView addAnnotation:t];
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    markerDriver = [[GMSMarker alloc] init];
    markerDriver.position = current;
    markerDriver.icon = [UIImage imageNamed:@"pin_driver"];
    markerDriver.map = mapView_;
    
    markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = f;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
    
    if (strDesti_Latitude && strDesti_Longitude)
    {
        // if ([TripStatusTag isEqualToString:@"1"])
        //{
        NSLog(@"Testing Destination Marker" );
        CLLocationCoordinate2D dest;
        dest.latitude=[strDesti_Latitude floatValue];
        dest.longitude=[strDesti_Longitude floatValue];
        marker = [[GMSMarker alloc] init];
        marker.position = dest;
        marker.icon = [UIImage imageNamed:@"pin_client_destination"];
        marker.map = mapView_;
        //}
    }
    
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,Google_Map_API_Key];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    @try {
        GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
        GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:path];
        polyLinePath.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
        polyLinePath.strokeWidth = 5.f;
        polyLinePath.geodesic = YES;
        polyLinePath.map = mapView_;
        
        routes = json[@"routes"];
        
        NSString *points=[[[routes objectAtIndex:0] objectForKey:@"overview_polyline"] objectForKey:@"points"];
        
        NSArray *temp= [self decodePolyLine:[points mutableCopy]];
        
        [self centerMap:temp];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    CLLocationCoordinate2D currentDriver;
    currentDriver.latitude=[struser_lati floatValue];
    currentDriver.longitude=[struser_longi floatValue];
    
}

-(void)centerMapFirst:(CLLocationCoordinate2D)pos1 two:(CLLocationCoordinate2D)pos2 third:(CLLocationCoordinate2D)pos3
{
    GMSCoordinateBounds* bounds =
    [[GMSCoordinateBounds alloc]initWithCoordinate:pos1 coordinate:pos2];
    bounds = [bounds includingCoordinate:pos3];

    CLLocationCoordinate2D location1 = bounds.southWest;
    CLLocationCoordinate2D location2 = bounds.northEast;
    
    float mapViewWidth = mapView_.frame.size.width;
    float mapViewHeight = mapView_.frame.size.height;
    
    MKMapPoint point1 = MKMapPointForCoordinate(location1);
    MKMapPoint point2 = MKMapPointForCoordinate(location2);
    
    MKMapPoint centrePoint = MKMapPointMake(
                                            (point1.x + point2.x) / 2,
                                            (point1.y + point2.y) / 2);
    CLLocationCoordinate2D centreLocation = MKCoordinateForMapPoint(centrePoint);
    
    double mapScaleWidth = mapViewWidth / fabs(point2.x - point1.x);
    double mapScaleHeight = mapViewHeight / fabs(point2.y - point1.y);
    double mapScale = MIN(mapScaleWidth, mapScaleHeight);
    
    double zoomLevel = 19.5 + log2(mapScale);
    
//    GMSCameraPosition *camera = [GMSCameraPosition
//                                 cameraWithLatitude: centreLocation.latitude
//                                 longitude: centreLocation.longitude
//                                 zoom: zoomLevel];
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:centreLocation zoom: zoomLevel];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];
}
 
#pragma mark-
#pragma mark MKPolyline delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
    polylineView.lineWidth = 5.0;
    return polylineView;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    MKAnnotationView *annot=[[MKAnnotationView alloc] init];
    
    SBMapAnnotation *temp=(SBMapAnnotation*)annotation;
    if (temp.yTag==1001)
    {
        annot.image=[UIImage imageNamed:@"pin_driver"];
    }
    if (temp.yTag==1000)
    {
        annot.image=[UIImage imageNamed:@"pin_client_org"];
    }
    //    if (isTo)
    //    {
    //
    //
    //    }
    //    else
    //    {
    //        isTo=YES;
    //        annot.image=[UIImage imageNamed:@"pin_driver.png"];
    //    }
    return annot;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

#pragma mark-
#pragma mark- DrawPath Method

-(void)drawPath
{
    NSMutableDictionary *dictPath=[[NSMutableDictionary alloc]init];
    NSString *templati,*templongi;
    
    pathUpdates = [GMSMutablePath path];
    pathUpdates = [[GMSMutablePath alloc]init];
    for (int i=0; i<arrPath.count; i++)
    {
        dictPath=[arrPath objectAtIndex:i];
        templati=[dictPath valueForKey:@"latitude"];
        templongi=[dictPath valueForKey:@"longitude"];
        
        CLLocationCoordinate2D current;
        current.latitude=[templati doubleValue];
        current.longitude=[templongi doubleValue];
        CLLocation *curLoc=[[CLLocation alloc]initWithLatitude:current.latitude longitude:current.longitude];
        
        //[paths addObject:curLoc];
        [pathUpdates addCoordinate:current];
        //[self updateMapLocation:curLoc];
    }
    
    
    //    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    //    polyline.strokeColor = [UIColor blueColor];
    //    polyline.strokeWidth = 5.f;
    //    polyline.geodesic = YES;
    //
    //    polyline.map = mapView_;
    
}


/*
- (void)updateMapLocation:(CLLocation *)newLocation
{
    self.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
    self.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
    
    for (MKAnnotationView *annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[SBMapAnnotation class]])
        {
            SBMapAnnotation *wAnnotation = (SBMapAnnotation*)annotation;
            if(wAnnotation.yTag==1001)
                [wAnnotation setCoordinate:newLocation.coordinate];
            if (!self.crumbs)
            {
                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.mapView addOverlay:self.crumbs];
            
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.mapView setRegion:region animated:YES];
            }
            else{
                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect))
                {
                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    // Ask the overlay view to update just the changed area.
                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
                    
                    // [self.mapView setVisibleMapRect:updateRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
                }
            }
        }
    }
    
}
*/





/*

#pragma mark - MapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
    
    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}
 
 */

#pragma mark-
#pragma mark- Get Location

-(void)getUserLocation
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    locationManager.allowsBackgroundLocationUpdates = NO;
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestWhenInUseAuthorization];
        [locationManager requestWhenInUseAuthorization];
    }
#endif
    
    [locationManager startUpdatingLocation];
    
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        struser_lati=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude];//[NSString stringWithFormat:@"%.8f",+37.40618700];
        struser_longi=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];//[NSString stringWithFormat:@"%.8f",-122.18845228];
    }
    if (newLocation != nil)
    {
        if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude)
        {
            
        }
        else
        {
            if(walkOldLocation.coordinate.latitude==0.00)
            {
                walkOldLocation=[walkOldLocation initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
                
                
            }
            
            distance = [walkOldLocation distanceFromLocation:currentLocation];
            NSLog(@"Distance = %f",distance);
            if (distance>=5.000000)
            {
                walkOldLocation=[walkOldLocation initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
                [self updateWalkLocation];
                //[self updateMapLocation:newLocation];
                [mapView_ clear];
                
                [pathUpdates addCoordinate:newLocation.coordinate];
                
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathUpdates];
                polyline.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
                polyline.strokeWidth = 5.f;
                polyline.geodesic = YES;
                polyline.map = mapView_;
                
                
               driver_marker = [[GMSMarker alloc] init];
                driver_marker.position=newLocation.coordinate;
                driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
                driver_marker.map = mapView_;
                
                
                CLLocationCoordinate2D currentOwner;
                currentOwner.latitude=[strowner_lati doubleValue];
                currentOwner.longitude=[strowner_longi doubleValue];
                
                
               markerOwner = [[GMSMarker alloc] init];
                markerOwner.position = currentOwner;
                markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
                markerOwner.map = mapView_;
                
                if (pathpolilineDest.count!=0)
                {
                    CLLocationCoordinate2D Destination;
                    Destination.latitude=[strDesti_Latitude doubleValue];
                    Destination.longitude=[strDesti_Longitude doubleValue];
                    
                    marker = [[GMSMarker alloc] init];
                    marker.position = Destination;
                    marker.icon = [UIImage imageNamed:@"pin_client_destination"];
                    marker.map = mapView_;

                    
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathpolilineDest];
                    polyline.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
                    polyline.strokeWidth = 5.f;
                    polyline.geodesic = YES;
                    polyline.map = mapView_;
                }
                if (flagForNav==1 && is_walker_arrived!=1)
                {
                    [self.btnNav setHidden:YES];
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathNav];
                    polyline.strokeColor = [UIColor colorWithRed:(155.0f/255.0f) green:(46.0f/255.0f) blue:(46.0f/255.0f) alpha:1.0];
                    polyline.strokeWidth = 5.f;
                    polyline.geodesic = YES;
                    polyline.map = mapView_;
                }
                
            }
            
            
            
        }
    }
    
}

#pragma mark-
#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    if(alertView.tag==111)
    {
        [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"PLEASE_WAIT",[prefl objectForKey:@"TranslationDocumentName"],nil)];

        [self  performSegueWithIdentifier:@"jobToFeedback" sender:self];
    }
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     
     if ([self.InstantJobNavigate isEqualToString:@"FromSidebar"])
     {
         if ([segue.identifier isEqualToString:@"jobToFeedback"])
         {
             FeedBackVC *obj = [segue destinationViewController];
             obj.InstantjobStatus = @"YesInstantJob";
             obj.DOGRATE = Dograted;
         }
     }
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 

#pragma mark-
#pragma mark- Calculate Distance

/*-(float)calculateDistanceFrom:(CLLocation *)locC To:(CLLocation *)locD
 {
 CLLocationDistance distance;
 distance=[locC distanceFromLocation:locD];
 float Range=distance;
 return Range;
 }*/



-(void)walkPath
{
    if([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D current;
        current.latitude=[struser_lati doubleValue];
        current.longitude=[struser_longi doubleValue];
        
        //SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
        
        CLLocationCoordinate2D currentOwner;
        currentOwner.latitude=[strowner_lati doubleValue];
        currentOwner.longitude=[strowner_longi doubleValue];
        
        //SBMapAnnotation *curLocOwn=[[SBMapAnnotation alloc]initWithCoordinate:currentOwner];
        
        [self showRouteFrom:currentOwner to:current];
        
        
        
        
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Blaze Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
    
}

#pragma mark-
#pragma mark- Button Method

-(IBAction)DriverCancelTripAction:(id)sender
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if([APPDELEGATE connected])
    {
        [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"PLEASE_WAIT",[prefl objectForKey:@"TranslationDocumentName"],nil)];
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        [dictparam setObject:@"" forKey:@"reason"];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:@"provider/cancellation" withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             NSLog(@"Cancel Request= %@",response);
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     [pref removeObjectForKey:PREF_REQUEST_ID];
                     [self.navigationController popViewControllerAnimated:YES];
                 }
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[prefl objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[prefl objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[prefl objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)onClickArrived:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WALKER_ARRIVED",[prefl objectForKey:@"TranslationDocumentName"],nil)];
    [self arrivedRequest];
    //    [btnArrived setHidden:YES];
    //    [btnWalk setHidden:NO];
    
}

- (IBAction)onClickJobDone:(id)sender
{
    
    [self.timer invalidate];
    
    [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
    
    endTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    double start = [startTime doubleValue];
    double end=[endTime doubleValue];
    
    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
    
    NSLog(@"difference: %f", difference);
    
    time=(difference/(1000*60));
    
    if(time==0)
    {
        time=1;
    }
    [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_TRIP_COMPLETE",[prefl objectForKey:@"TranslationDocumentName"],nil)];
    [self jobDone];
    // [self  performSegueWithIdentifier:@"jobToFeedback" sender:self];
    
}

- (IBAction)onClickWalkStart:(id)sender
{

    //    [btnWalk setHidden:YES];
    //    [btnJob setHidden:NO];
    startTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:startTime forKey:PREF_START_TIME];
    [pref synchronize];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
    [self walkStarted];
    [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_TRIP_START",[prefl objectForKey:@"TranslationDocumentName"],nil)];
}

- (IBAction)onClickWalkerStart:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_WALKER_START",[prefl objectForKey:@"TranslationDocumentName"],nil)];
    [self walkerStarted];
    //    [btnWalker setHidden:YES];
    //    [btnArrived setHidden:NO];
}

- (IBAction)onClickCall:(id)sender
{
    
    NSString *call=[NSString stringWithFormat:@"tel://%@",strOwnerPhone];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
}

- (IBAction)onClickNav:(id)sender
{
    /*
    CLLocationCoordinate2D drivercoordinate = CLLocationCoordinate2DMake([struser_lati doubleValue], [struser_longi doubleValue]);
    CLLocationCoordinate2D ownercoordinate = CLLocationCoordinate2DMake([strowner_lati doubleValue], [strowner_longi doubleValue]);
    
    MKPlacemark* driverplace = [[MKPlacemark alloc] initWithCoordinate: drivercoordinate addressDictionary: nil];
    MKMapItem* driverdestination = [[MKMapItem alloc] initWithPlacemark: driverplace];
    MKPlacemark* ownerplace = [[MKPlacemark alloc] initWithCoordinate: ownercoordinate addressDictionary: nil];
    MKMapItem* ownerdestination = [[MKMapItem alloc] initWithPlacemark: ownerplace];
//    destination.name = @"Name Here!";
    NSArray* items = [[NSArray alloc] initWithObjects: driverdestination, ownerdestination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
    
    */
    
    /*
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake([struser_lati doubleValue], [struser_longi doubleValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:@"Customer Location"];
        
        // Set the directions mode to "Walking"
        // Can use MKLaunchOptionsDirectionsModeDriving instead
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
   
    CLLocationCoordinate2D coordinate =
    CLLocationCoordinate2DMake([struser_lati doubleValue], [struser_longi doubleValue]);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];

    MKDirectionsRequest *DirectionsTransportTypeAny = [[MKDirectionsRequest alloc] init];
    DirectionsTransportTypeAny.transportType = MKDirectionsTransportTypeAny;
    [DirectionsTransportTypeAny setSource:[MKMapItem mapItemForCurrentLocation]];
    [DirectionsTransportTypeAny setDestination:mapItem];
    
    MKDirections *walkingRouteDirections = [[MKDirections alloc] initWithRequest:DirectionsTransportTypeAny];
    [walkingRouteDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * walkingRouteResponse, NSError *walkingRouteError) {
        if (walkingRouteError) {
            [self handleDirectionsError:walkingRouteError];
        } else {
            // The code doesn't request alternate routes, so add the single calculated route to
            // a previously declared MKRoute property called walkingRoute.
            self.walkingRoute = walkingRouteResponse.routes[0];
        }
    }];
    */
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f",[strowner_lati doubleValue], [strowner_longi doubleValue],[struser_lati doubleValue], [struser_longi doubleValue]]];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        }
    else
        [[UIApplication sharedApplication] openURL:url];
    
    /* old code
     
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:@"1" forKey:PREF_NAV];
    flagForNav=[[pref objectForKey:PREF_NAV] integerValue];
    [self.btnNav setHidden:YES];
    [self drawNavPath];
    */
}

-(void)drawNavPath
{
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    CLLocationCoordinate2D currentOwner;
    currentOwner.latitude=[strowner_lati doubleValue];
    currentOwner.longitude=[strowner_longi doubleValue];
    
    
    [self showRouteFrom:currentOwner to:current];
//    NSArray* routesNav = [self calculateRoutesFrom:current to:currentOwner];
//    NSInteger numberOfSteps = routesNav.count;
//    
//    
//    pathNav=[GMSMutablePath path];
//    [pathNav removeAllCoordinates];
//    
//    CLLocationCoordinate2D coordinates[numberOfSteps];
//    for (NSInteger index = 0; index < numberOfSteps; index++)
//    {
//        CLLocation *location = [routesNav objectAtIndex:index];
//        CLLocationCoordinate2D coordinate = location.coordinate;
//        coordinates[index] = coordinate;
//        [pathNav addCoordinate:coordinate];
//    }
//    
//    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:pathNav];
//    
//    polyLinePath.strokeColor = [UIColor colorWithRed:(155.0f/255.0f) green:(46.0f/255.0f) blue:(46.0f/255.0f) alpha:1.0];
//    polyLinePath.strokeWidth = 5.f;
//    polyLinePath.geodesic = YES;
//    polyLinePath.map = mapView_;
//    [self centerMapFirst:current two:currentOwner third:currentOwner];
    
    //[self centerMap];
    //[self showRouteFrom:currentOwner to:current];
}

#pragma mark-
#pragma mark- Calculate Time & Distance

-(void)updateTime
{
    NSLog(@"Start time= %@",startTime);
    
    NSString *currentTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    double start = [startTime doubleValue];
    double end=[currentTime doubleValue];
    
    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
    
    NSLog(@"difference: %f", difference);
    
    time=(difference/(1000*60));
    NSLog(@"Timeset is %d",time);
//    if(time==0)
//    {
//        time=1;
//    }
    NSDateFormatter *dfs = [[NSDateFormatter alloc] init];
    [dfs setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1s = [dfs dateFromString:startTime];
    NSDate *date2s = [NSDate date];
    NSTimeInterval intervals = [[NSDate date] timeIntervalSince1970] - [date1s timeIntervalSince1970];
    int hours = ((int)intervals / 3600)/3600;             // integer division to get the hours part
    int minutes = (intervals - (hours*3600)) / 60; // interval minus hours part (in seconds) divided by 60 yields minutes
    NSString *timeDiff = [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    NSLog(@"Ftest Time %@",timeDiff);
    
        NSDateFormatter *dfl=[[NSDateFormatter alloc] init];
    //     Set the date format according to your needs
        [dfl setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [dfl dateFromString:startTime];
        NSDate *date2 = [NSDate date];
        double dif =[[NSDate date] timeIntervalSince1970] - [date2 timeIntervalSince1970];
        NSLog(@" time difference %f",dif);
        int aptime = dif/60;
        NSLog(@"Apptime %d",aptime);
    
    NSString *gmtDateString = startTime;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *datee = [df dateFromString:gmtDateString];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    double dateTimeDiff=  [[NSDate date] timeIntervalSince1970] - [datee timeIntervalSince1970];
    int Diff=dateTimeDiff/60;
    NSLog(@"Time is %d",Diff);
    
    
//    [btnTime setTitle:[NSString stringWithFormat:@"%d %@",Diff,NSLocalizedStringFromTable(@"Mins",[prefl objectForKey:@"TranslationDocumentName"],nil)] forState:UIControlStateNormal];

}

/*
 */

-(void)calculateDistance
{
    CLLocationCoordinate2D current;
    current.latitude=[strStart_lati doubleValue];
    current.longitude=[strStart_longi doubleValue];
    
    CLLocationCoordinate2D currentOwner;
    currentOwner.latitude=[struser_lati doubleValue];
    currentOwner.longitude=[struser_longi doubleValue];
    
    locA=[[CLLocation alloc]initWithLatitude:current.latitude longitude:current.longitude];
    locB=[[CLLocation alloc]initWithLatitude:currentOwner.latitude longitude:currentOwner.longitude];
    
    // distance = [locA distanceFromLocation:locB];
    
    
    
}



@end
