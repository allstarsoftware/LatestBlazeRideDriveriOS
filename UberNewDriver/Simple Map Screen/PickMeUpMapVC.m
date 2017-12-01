//
//  PickMeUpMapVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//
#import "AFNetworking.h"

#import "PickMeUpMapVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegexKitLite.h"
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "ContactVC.h"
#import "ArrivedMapVC.h"
#import "RatingBar.h"
#import "UIView+Utils.h"
#import "SWRevealViewController.h"
#import "ProviderLocation.h"
#import "ProviderRequestInProgress.h"
#import "MCPercentageDoughnutView.h"

typedef void(^addressCompletion)(NSString *);


@interface PickMeUpMapVC () <SWRevealViewControllerDelegate,MCPercentageDoughnutViewDataSource,MCPercentageDoughnutViewDelegate>
{
    CLLocationManager *locationManager;
    NSMutableArray *arrRequest;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    NSMutableDictionary *dict;
    NSMutableDictionary *dictOwner;
    BOOL flag,isTo,is_approved;
    int time;
    float totalDist;
    NSString *strPickuplocation, *strDropOffLocation;
    SWRevealViewController *revealViewController;
    NSUserDefaults *pref;
    BOOL swAvailable;
    NSURL *StaticImage;
    NSMutableString *MapImgURL,*ETA,*NewPickupAdd,*NewDropAdd;
    CGFloat screenWidth,screenHeight;CGRect screenRect;
}

@end

@implementation PickMeUpMapVC

@synthesize lblBlue,lblGrey,lblTime,btnProfile,btnAccept,btnReject,lblDetails,lblName,lblRate,imgStar,ProfileView,imgUserProfile,sound1Player;

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
    [self hide];
   
    [self.AcceptViewNewDesign setHidden:YES];
    internet=[APPDELEGATE connected];
    [super viewDidLoad];
    pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
//    pref = [[NSUserDefaults alloc]init];

    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    NSLog(@"Screen Width %f",screenWidth);
    NSLog(@"Screen Height %f",screenHeight);
    
    if (screenHeight == 568.000000)
    {
        NSLog(@"Standard Resolution Device");
    }
    if (screenHeight == 667.000000)
    {
        NSLog(@"High Resolution Device");
    }
    if (screenHeight > 667.000000)
    {
        NSLog(@"iPhone 7 & 7plus");
    }

    
    NSLog(@"testing the pref   %@",[pref objectForKey:@"TranslationDocumentName"]);
    self.lblNotApproved.text = NSLocalizedStringFromTable(@"YOU ARE NOT APPROVED BY ADMIN",[pref objectForKey:@"TranslationDocumentName"],nil);
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"MENU",[pref objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
    [self localizeString];
    
    //SideBarVC *sidebarObj=[self.storyboard instantiateViewControllerWithIdentifier:@"pickmeUp"];
    //[sidebarObj setDelegate:self];
    self.arrivedMap.pickMeUp=self;
    [self.imgUserProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    
    isTo=NO;
    progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-50,-50, 320,20)];
    progressView.color = [UIColor colorWithRed:0.0f/255.0f green:193.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    //progressView.background = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0];
    progressView.progress = 1.0;
    progressView.showText = @NO;
    progressView.animate = @NO;
    progressView.borderRadius = @NO;
    [self.ProfileView addSubview:progressView];
    [self.ProfileView bringSubviewToFront:self.lblTime];
    
    self.etaView.hidden=YES;
    [self.ratingView initRateBar];
    [self.ratingView setUserInteractionEnabled:NO];
    
    /*
    Mysingletonclass *tmp = [Mysingletonclass sharedSingleton];
    // read
    NSString *new = tmp.Myuserid;
    NSLog(@"Singleton ID- %@",new);
    NSLog(@"Singleton Token- %@",tmp.temptoken);
     */
    strUserId=[pref objectForKey:PREF_USER_ID];
    NSLog(@"User-ID %@     %@",strUserId,[pref objectForKey:PREF_USER_ID] );
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSLog(@"User Token %@",strUserToken);
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    [self updateLocation];
    [self getPagesData];
    [self customFont];
    [self getUserLocation];
    
//    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    /*SWRevealViewController *reveal = self.revealViewController;
     reveal.panGestureRecognizer.enabled = YES;*/
    
    time=0;
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current.latitude
                                                            longitude:current.longitude
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,0,self.viewForMap.frame.size.width,self.viewForMap.frame.size.height) camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.viewForMap addSubview:mapView_];
    mapView_.delegate=self;
    // Creates a marker in the center of the map.
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
//    marker.rotation = head

    /*SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
     curLoc.yTag=1000;
     [self.mapView addAnnotation:curLoc];*/
    
    
    
    //[self performSegueWithIdentifier:@"segurtoarrived" sender:self];
    
    
    // Do any additional setup after loading the view.
}

-(void)Reject_LoadHome
{
    self.revealViewController.delegate = self;
    [revealViewController setDelegate:self];
    //[self hide];
    internet=[APPDELEGATE connected];
    pref=[NSUserDefaults standardUserDefaults];
    //[pref synchronize];
    strUserId=[pref objectForKey:[NSString stringWithFormat:@"%@",PREF_USER_ID]];
    NSLog(@"parm-ID %@",strUserId);
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    is_approved=[[pref valueForKey:PREF_IS_APPROVED] boolValue];
    
    if (is_approved)
    {
        self.viewForNotApproved.hidden=YES;
        self.navigationController.navigationBarHidden=NO;
    }
    else
    {
        self.viewForNotApproved.hidden=NO;
        self.navigationController.navigationBarHidden=YES;
    }
    
    
    [self updateLocation];
    
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
 
    marker = [[GMSMarker alloc] init];
    marker.position = current;
 
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
    
    self.navigationItem.hidesBackButton=YES;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showUserLoc) userInfo:nil repeats:NO];
    [self getRequestId];
    
    strowner_lati=nil;
    strowner_longi=nil;
    
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    
    revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.panGuestureview addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        //        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    self.revealViewController.delegate = self;
    [revealViewController setDelegate:self];
    //[self hide];
    internet=[APPDELEGATE connected];
    pref=[NSUserDefaults standardUserDefaults];
    //[pref synchronize];
    strUserId=[pref objectForKey:[NSString stringWithFormat:@"%@",PREF_USER_ID]];
    NSLog(@"parm-ID %@",strUserId);
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    is_approved=[[pref valueForKey:PREF_IS_APPROVED] boolValue];

    if (is_approved)
    {
        self.viewForNotApproved.hidden=YES;
        self.navigationController.navigationBarHidden=NO;
    }
    else
    {
        self.viewForNotApproved.hidden=NO;
        self.navigationController.navigationBarHidden=YES;
    }
    
    
    [self updateLocation];
    
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    /*
     
     SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
     curLoc.yTag=1000;
     [self.mapView addAnnotation:curLoc];
     
     */
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    //marker.title = @"Current Location";
    //marker.snippet = @"Australia";
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
    
    self.navigationItem.hidesBackButton=YES;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showUserLoc) userInfo:nil repeats:NO];
    [self getRequestId];
    
    strowner_lati=nil;
    strowner_longi=nil;

        [self.viewforPickupLabel setHidden:YES];
        [self.viewforDropOffLabel setHidden:YES];
    
    revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.panGuestureview addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        //        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    
    //self.navigationController.navigationBarHidden=NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.btnMenu setTitle:NSLocalizedStringFromTable(@"MENU",[pref objectForKey:@"TranslationDocumentName"],nil) forState:UIControlStateNormal];
    self.viewforPickupLabel.layer.borderWidth = 1;
    self.viewforPickupLabel.layer.borderColor = [[UberStyleGuide colorDefault] CGColor];
    
    self.viewforDropOffLabel.layer.borderWidth = 1;
    self.viewforDropOffLabel.layer.borderColor = [[UberStyleGuide colorDefault] CGColor];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.mapView_ clear];
    // [self.mapView removeAnnotations:self.mapView.annotations];
}



-(void)showUserLoc
{
    if ([CLLocationManager locationServicesEnabled])
    {
        //        MKCoordinateRegion region;
        //        region.center.latitude     = [struser_lati doubleValue];
        //        region.center.longitude    = [struser_longi doubleValue];
        //        region.span.latitudeDelta = 1.5;
        //        region.span.longitudeDelta = 1.5;
        
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude=[struser_lati doubleValue];
        coordinate.longitude=[struser_longi doubleValue];
        
        
        /*
         GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
         longitude:coordinate.longitude
         zoom:10];
         [self.mapView_ animateToCameraPosition:[GMSCameraPosition
         cameraWithLatitude:coordinate.latitude
         longitude:coordinate.longitude
         zoom:10]];
         
         */
        
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:15];
        
        [mapView_ animateWithCameraUpdate:updatedCamera];
        
        //mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,65,320,505) camera:camera];
        
        //[mapView_ setCamera:camera];
        //[self.mapView_ setRegion:region animated:YES];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> RideKangaroo Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    btnAccept=[APPDELEGATE setBoldFontDiscriptor:btnAccept];
    btnReject=[APPDELEGATE setBoldFontDiscriptor:btnReject];
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.lblName.font=[UberStyleGuide fontRegular];
    //self.lblTime.font=[UberStyleGuide fontRegular:48.0f];
}
-(void)localizeString
{
    
    [self.btnAccept setTitle:NSLocalizedStringFromTable(@"ACCEPT",[pref objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateHighlighted];
    [self.btnAccept setTitle:NSLocalizedStringFromTable(@"ACCEPT",[pref objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateSelected];
    [self.btnReject setTitle:NSLocalizedStringFromTable(@"REJECT",[pref objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateHighlighted];
    [self.btnReject setTitle:NSLocalizedStringFromTable(@"REJECT",[pref objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateSelected];
    [self.btnClose setTitle:NSLocalizedStringFromTable(@"CLOSE",[pref objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateHighlighted];
    [self.btnClose setTitle:NSLocalizedStringFromTable(@"CLOSE",[pref objectForKey:@"TranslationDocumentName"],nil)forState:UIControlStateSelected];
}

#pragma mark-
#pragma mark- Method for New Accept & Reject Request Properties
// Method for New Accept & Reject Request Properties Begins

-(void)DisplayNewAccpet_RejectView
{
    NSLog(@"Map URL = %@",MapImgURL);
    NSLog(@"Map ETA = %@",ETA);

    [self.MapRoundedImageview downloadFromURL:MapImgURL withPlaceholder:nil];
    [self.TimeLabel setText:[NSString stringWithFormat:@"%@ Mins away",ETA]];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [self StaticMapImageGenerator];
    [self.navigationController setNavigationBarHidden:YES];
    self.MapRoundedImageview.layer.cornerRadius = self.MapRoundedImageview.frame.size.width/2;
    self.MapRoundedImageview.layer.masksToBounds = YES;
    self.ViewforButtons.layer.cornerRadius = 15;
    self.ViewforButtons.layer.masksToBounds = YES;
    //    NSString *urlString = [StaticImage absoluteString];
    //    [self.MapRoundedImageview downloadFromURL:Hello withPlaceholder:nil];
    
    MCPercentageDoughnutView *percentageDoughnut = [[MCPercentageDoughnutView alloc]init];//[[MCPercentageDoughnutView alloc] initWithFrame:CGRectMake(46, 20, 230, 230)];
    
    if (screenHeight == 568.000000)
    {
        NSLog(@"Standard Resolution Device");
        percentageDoughnut = [[MCPercentageDoughnutView alloc]initWithFrame:CGRectMake(46, 20, 230, 230)];
    }
    if (screenHeight == 667.000000)
    {
        NSLog(@"High Resolution Device");
        percentageDoughnut = [[MCPercentageDoughnutView alloc]initWithFrame:CGRectMake(51, 20, 275, 275)];
    }
    if (screenHeight == 736.000000)
    {
        NSLog(@"iPhone 7 & 7plus");
        percentageDoughnut = [[MCPercentageDoughnutView alloc]initWithFrame:CGRectMake(56,20, 310, 310)];
    }
    
    [self.AcceptViewNewDesign addSubview:percentageDoughnut];
    percentageDoughnut.animatesBegining = YES;
    percentageDoughnut.percentage              = 1;
    percentageDoughnut.linePercentage          = 0.05;
    percentageDoughnut.animationDuration       = time;
    percentageDoughnut.decimalPlaces           = 1;
    percentageDoughnut.showTextLabel           = NO;
    percentageDoughnut.fillColor               = [UberStyleGuide colorDefault];
    percentageDoughnut.unfillColor             = [MCUtil iOS7DefaultGrayColorForBackground];
    percentageDoughnut.textLabel.textColor     = [UIColor blackColor];
    percentageDoughnut.textLabel.font          = [UIFont systemFontOfSize:50];
    percentageDoughnut.gradientColor1          = [UIColor greenColor];
    percentageDoughnut.gradientColor2          = [MCUtil iOS7DefaultGrayColorForBackground];
}

- (IBAction)BtnNewReject:(id)sender
{
    if (internet)
    {
        pref=[NSUserDefaults standardUserDefaults];
        strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
        
        if (strRequsetId!=nil)
        {
            NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
            
            [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
            [dictparam setObject:strUserId forKey:PARAM_ID];
            [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
            [dictparam setObject:@"0" forKey:PARAM_ACCEPTED];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
             {
                 
                 NSLog(@"Respond to Request= %@",response);
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         
                         [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"REQUEST_REJECTED",[pref objectForKey:@"TranslationDocumentName"],nil)];
                         
                         [self.time invalidate];
                         [self.viewforPickupLabel setHidden:YES];
                         [self.viewforDropOffLabel setHidden:YES];
                         [self.progtime invalidate];
                         [self hide];
                         [self Reject_LoadHome];                     }
                 }
                 
             }];
        }
        else
        {
            
        }
    }
    
    pref=[NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:PREF_REQUEST_ID];
    strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
    [mapView_ clear];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [self.progtime invalidate];
    [self hide];

}

- (IBAction)BtnNewAccept:(id)sender
{
    strPickuplocation = @"";
    strDropOffLocation = @"";
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    
    [sound1Player stop];
    
    [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_ADMIN_APPROVE",[pref objectForKey:@"TranslationDocumentName"],nil)];
    [self respondToRequset];
    [self.time invalidate];
}


// Method for New Accept & Reject Request Properties Ends

#pragma mark-
#pragma mark- Profile View Hide/Show Method

-(void)hide
{
    self.AcceptViewNewDesign.hidden=YES;
   
    self.lblTime.hidden=YES;
    self.lblWhite.hidden=YES;
    self.imgTimeBg.hidden=YES;
    [ProfileView setHidden:YES];
    [btnAccept setHidden:YES];
    [btnReject setHidden:YES];
}

-(void)show
{
    
    self.AcceptViewNewDesign.hidden=NO;
    [self DisplayNewAccpet_RejectView];
    self.lblTime.hidden=NO;
    self.lblWhite.hidden=NO;
    self.imgTimeBg.hidden=NO;
    [ProfileView setHidden:NO];
    [btnAccept setHidden:NO];
    [btnReject setHidden:NO];
    
    
    /*
     [APPDELEGATE.window addSubview:self.btnAccept];
     [APPDELEGATE.window bringSubviewToFront:self.btnAccept];
     
     [APPDELEGATE.window addSubview:self.btnReject];
     [APPDELEGATE.window bringSubviewToFront:self.btnReject];
     
     [APPDELEGATE.window addSubview:self.lblWhite];
     [APPDELEGATE.window bringSubviewToFront:self.lblWhite];
     
     [APPDELEGATE.window addSubview:self.imgTimeBg];
     [APPDELEGATE.window bringSubviewToFront:self.imgTimeBg];
     
     [APPDELEGATE.window addSubview:self.lblTime];
     [APPDELEGATE.window bringSubviewToFront:self.lblTime];
     
     [APPDELEGATE.window addSubview:self.ProfileView];
     [APPDELEGATE.window bringSubviewToFront:self.ProfileView];
     */
}

#pragma mark-
#pragma mark- If-Else Methods
-(void)getRequestId
{
    if (strRequsetId!=nil)
    {
        [self checkRequest];
    }
    else
    {
        [self requsetProgress];
    }
}
-(void)getRequestIdSecond
{
    if (strRequsetId!=nil)
    {
        [self checkRequest];
    }
    else
    {
        flag=YES;
        [self getAllRequests];
        
    }
}

-(void)requestThird
{
    if(strRequsetId!=nil)
    {
        [self respondToRequset];
    }
    else
    {
        flag=NO;
        [self.time invalidate];
        [self getAllRequests];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
        [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
        [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
        self.navigationItem.hidesBackButton=YES;
    }
}

#pragma mark-
#pragma mark- API Methods

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
                     [mapView_ clear];
                     
                     [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"PLEASE_WAIT",[pref objectForKey:@"TranslationDocumentName"],nil)];
                     [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
                     // [self respondToRequset];
                     
                 }
                 else
                 {
                     pref=[NSUserDefaults standardUserDefaults];
                     [pref removeObjectForKey:PREF_REQUEST_ID];
                     strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
                     [self getRequestId];
                 }
             }
             
             
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


-(void)requsetProgress
{
    if(internet)
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        NSLog(@"parm-ID %@",strUserId);
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_PROGRESS withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"Request in Progress= %@",response);
             
             if (response)
             {
                 if([[response valueForKey:@"success"]intValue]==1)
                 {
                     NSLog(@"Response--%@",response);
                     NSDictionary *set = response;
                     ProviderRequestInProgress *tester = [RMMapper objectWithClass:[ProviderRequestInProgress class] fromDictionary:set];
                     NSLog(@"Tdata: %@",tester.success);
                     if ([[response valueForKey:@"request_id"] intValue]!=-1)
                     {
                         pref=[NSUserDefaults standardUserDefaults];
                         [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQUEST_ID];
                         [pref synchronize];
                         strRequsetId=[response valueForKey:@"request_id"];
                     }
                     [self getRequestIdSecond];
                 }
             }
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getAllRequests
{
    if(internet)
    {
        pref=[NSUserDefaults standardUserDefaults];
        strUserId = [pref valueForKey:[NSString stringWithFormat:@"%@",PREF_USER_ID]];
        NSLog(@"parm-ID %@",strUserId);
        strUserToken = [pref valueForKey:PREF_USER_TOKEN];
        [pref synchronize];
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             NSLog(@"Get All Request= %@",response);
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     
                     pref=[NSUserDefaults standardUserDefaults];
                     
                     NSArray *Resp = [[NSArray alloc] init];
                     Resp = [response valueForKey:@"incoming_requests"];
                     NSDictionary *ReqData = [[NSDictionary alloc] init];
                     ReqData = [Resp valueForKey:@"request_data"];
                     NSArray *Estimation = [[NSArray alloc]init];
                     Estimation = [ReqData valueForKey:@"estimation"];
                     NSLog(@"DICTRES %@",Estimation);
                     
                     for (int i=0; i<[Estimation count]; i++)
                     {
                         MapImgURL = [NSMutableString stringWithFormat:@"%@",[[Estimation valueForKey:@"gmap_url"] objectAtIndex:i]];
                         ETA = [NSMutableString stringWithFormat:@"%@",[[Estimation valueForKey:@"estimation"] objectAtIndex:i]];
                         NewPickupAdd =[NSMutableString stringWithFormat:@"%@",[[Estimation valueForKey:@"pickup_address"] objectAtIndex:i]];
                         NewDropAdd =[NSMutableString stringWithFormat:@"%@",[[Estimation valueForKey:@"drop_address"] objectAtIndex:i]];
                     }
                     
                     
                     
                     [pref setBool:[[response valueForKey:@"is_approved"] boolValue] forKey:PREF_IS_APPROVED];
                     is_approved=[[pref valueForKey:PREF_IS_APPROVED] boolValue];
                     if (is_approved)
                     {
                         self.viewForNotApproved.hidden=YES;
                         self.navigationController.navigationBarHidden=NO;
                     }
                     else
                     {
                         self.viewForNotApproved.hidden=NO;
                         self.navigationController.navigationBarHidden=YES;
                     }
                     
                     NSMutableArray *arrRespone=[response valueForKey:@"incoming_requests"];
                     if(arrRespone.count!=0)
                     {
                        
                         [self PlaySound];
                         [sound1Player play];
                         [self.time invalidate];
                         NSMutableDictionary *dictRequestData=[arrRespone valueForKey:@"request_data"];
                         NSMutableArray *arrOwner=[dictRequestData valueForKey:@"owner"];
                         dictOwner=[arrOwner objectAtIndex:0];
                         NSMutableArray *arrRequest_Id=[arrRespone valueForKey:@"request_id"];
                         strRequsetId=[NSMutableString stringWithFormat:@"%@",[arrRequest_Id objectAtIndex:0]];
                         pref=[NSUserDefaults standardUserDefaults];
                         [pref setObject:strRequsetId forKey:PREF_REQUEST_ID];
                         [pref synchronize];
                         lblName.text=[dictOwner valueForKey:@"name"];
                         lblRate.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"rating"]];
                         lblDetails.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
                         [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
                         strowner_lati=[dictOwner valueForKey:@"latitude"];
                         strowner_longi=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"longitude"]];
                         strdesti_lati=[dictOwner valueForKey:@"dest_latitude"];
                         strdesti_longi=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"dest_longitude"]];
                         CLLocation* pickLocation = [[CLLocation alloc] initWithLatitude:[strowner_lati doubleValue] longitude:[strowner_longi doubleValue]];
                         if([strowner_lati integerValue]>0 && [strowner_longi integerValue]>0) {
                             [self getAddressFromLocation:pickLocation complationBlock:^(NSString * address) {
                                 if(address) {
                                     strPickuplocation = address;
                                     self.lblPickupLocation.text = [NSString stringWithFormat:@"  %@",strPickuplocation];
                                     strPickuplocation = address;
                                     self.NewPickupLabel.text = [NSString stringWithFormat:@"  %@",NewPickupAdd];
                                     _NewPickupLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                     _NewPickupLabel.numberOfLines = 3;
                                     
                                    [self.viewforPickupLabel setHidden:YES];
                                 }
                             }];
                         }
                         if([strdesti_lati integerValue]>0 && [strdesti_longi integerValue]>0) {
                             
                             CLLocation* dropoffLocation = [[CLLocation alloc] initWithLatitude:[strdesti_lati doubleValue] longitude:[strdesti_longi doubleValue]];
                             
                             [self getAddressFromLocation:dropoffLocation complationBlock:^(NSString * address) {
                                 if(address) {
                                     strDropOffLocation = address;
                                     self.lblDropOffLocation.text = [NSString stringWithFormat:@"  %@",strDropOffLocation];
                                     strDropOffLocation = address;
                                     self.NewDropLabel.text = [NSString stringWithFormat:@"  %@",NewDropAdd];
                                     _NewDropLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                     _NewDropLabel.numberOfLines = 3;
                                    [self.viewforDropOffLabel setHidden:YES];
                                 }
                             }];
                         }
                         
                         RBRatings rate=([[dictOwner valueForKey:@"rating"]floatValue]*2);
                         [ self.ratingView setRatings:rate];
                         
                         payment=[[dictOwner valueForKey:@"payment_type"] integerValue];
                         
                         
                         [self.mapView_ clear];
                         
                         
                         
                         CLLocationCoordinate2D current;
                         current.latitude=[struser_lati doubleValue];
                         current.longitude=[struser_longi doubleValue];
                         
                         marker = [[GMSMarker alloc] init];
                         marker.position = current;
                         marker.icon = [UIImage imageNamed:@"pin_driver"];
                         marker.map = mapView_;
                         
                         CLLocationCoordinate2D currentOwner;
                         currentOwner.latitude=[strowner_lati doubleValue];
                         currentOwner.longitude=[strowner_longi doubleValue];
                         
                         
                         GMSMarker *markerOwner = [[GMSMarker alloc] init];
                         markerOwner.position = currentOwner;
                         markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
                         markerOwner.map = mapView_;
                         
                         
                         /*
                          SBMapAnnotation *curLocOwner=[[SBMapAnnotation alloc]initWithCoordinate:currentClient];
                          curLocOwner.yTag=1001;
                          
                          [self.mapView addAnnotation:curLocOwner];
                          
                          */
                         
                         
                         NSMutableArray *arrTime=[arrRespone valueForKey:@"time_left_to_respond"];
                         time=[[arrTime objectAtIndex:0]intValue];
                         
                         
                         [self.progtime invalidate];
                         NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                         self.progtime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(customProgressBar) userInfo:nil repeats:YES];
                         [runloop addTimer:self.progtime forMode:NSRunLoopCommonModes];
                         [runloop addTimer:self.progtime forMode:UITrackingRunLoopMode];
                         
                         
                         [self show];
                         [self centerMapFirst:current two:currentOwner third:current];
                         
                     }
                     
                     else if (flag==YES)
                     {
                         [self requestThird];
                         
                     }
                 }
             }
             
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    
    
}

-(void)getAddressFromLocation:(CLLocation *)location complationBlock:(addressCompletion)completionBlock
{
    __block CLPlacemark* placemark;
    __block NSString *address = nil;
    
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             address = [NSString stringWithFormat:@"%@, %@ %@", placemark.name, placemark.postalCode, placemark.locality];
             completionBlock(address);
         }
     }];
}

-(void)updateLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if(internet)
        {
            
            if(((struser_lati==nil)&&(struser_longi==nil))
               ||(([struser_longi doubleValue]==0.00)&&([struser_lati doubleValue]==0)))
            {
            }
            else
            {
                pref=[NSUserDefaults standardUserDefaults];
                strUserId = [pref valueForKey:[NSString stringWithFormat:@"%@",PREF_USER_ID]];
                strUserToken = [pref valueForKey:[NSString stringWithFormat:@"%@",PREF_USER_TOKEN]];
                [pref synchronize];
                NSLog(@"parm-ID %@",strUserId);
                NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
                [dictparam setObject:strUserId forKey:[NSString stringWithFormat:@"%@",PARAM_ID]];
                
                [dictparam setObject:strUserToken forKey:[NSString stringWithFormat:@"%@",PARAM_TOKEN]];
                [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
                [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
                
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_USERLOCATION withParamData:dictparam withBlock:^(id response, NSError *error)
                 {
                     
                     NSLog(@"Update Location = %@",response);
                     if (response)
                     {
                         if([[response valueForKey:@"success"] intValue]==1)
                         {
                             NSLog(@"Response--%@",response);
                             NSDictionary *set = response;
                             ProviderLocation *tester = [RMMapper objectWithClass:[ProviderLocation class] fromDictionary:set];
                             NSLog(@"Tdata: %@",tester.success);

                         }
                     }
                     
                 }];
                
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> RideKangaroo Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}

-(void)respondToRequset
{
    @try
    {
        if(internet)
        {
            pref=[NSUserDefaults standardUserDefaults];
            strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
            
            if (strRequsetId!=nil)
            {
                NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
                
                [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
                [dictparam setObject:strUserId forKey:PARAM_ID];
                [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
                [dictparam setObject:@"1" forKey:PARAM_ACCEPTED];
                
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
                 {
                     
                     NSLog(@"Respond to Request= %@",response);
                     [APPDELEGATE hideLoadingView];
                     if (response)
                     {
                         if([[response valueForKey:@"success"] intValue]==1)
                         {
                             
                             [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"REQUEST_ACCEPTED",[pref objectForKey:@"TranslationDocumentName"],nil)];
                             pref=[NSUserDefaults standardUserDefaults];
                             
                             [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
                             [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
                             [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
                             [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
                             [pref synchronize];
                             
                             
                             lblName.text=[dictOwner valueForKey:@"name"];
                             lblRate.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"rating"]];
                             lblDetails.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
                             [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
                             
                             [self.time invalidate];
                             [self.progtime invalidate];
                             [self hide];
                             [self.viewforPickupLabel setHidden:YES];
                             [self.viewforDropOffLabel setHidden:YES];
                             strPickuplocation = @"";
                             strDropOffLocation = @"";
                             [mapView_ clear];
                             [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
                         }
                         else if([[response valueForKey:@"success"] intValue]==1)
                         {
                             NSLog(@"Do Nothing");
                             NSLog(@"Do Nothing");
                             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Opps an Error Occured" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
                             [alert show];
                         }
                     }
                     
                 }];
            }
            else
            {
                NSLog(@"Do Nothing");
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Opps an Error Occured" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
            [alert show];
        }

    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}


-(void)getPagesData
{
    if(internet)
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGES,PARAM_ID,strUserId];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"Page Data= %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrPage=[response valueForKey:@"informations"];
                 }
             }
             
         }];
        
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"No Internet",[pref objectForKey:@"TranslationDocumentName"],nil) message:NSLocalizedStringFromTable(@"NO_INTERNET",[pref objectForKey:@"TranslationDocumentName"],nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK",[pref objectForKey:@"TranslationDocumentName"],nil) otherButtonTitles:nil, nil];
        [alert show];
    }
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

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
    for(int idx = 0; idx < routes.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    
    
    
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    
    region.span.latitudeDelta = 1.5;
    region.span.longitudeDelta = 1.5;
    
    //[self.mapView setRegion:region animated:YES];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    //GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
    // longitude:coordinate.longitude
    //    zoom:6];
    //mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,65,320,505) camera:camera];
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:15];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];
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
    
    double zoomLevel = 19.1 + log2(mapScale);
    
    //    GMSCameraPosition *camera = [GMSCameraPosition
    //                                 cameraWithLatitude: centreLocation.latitude
    //                                 longitude: centreLocation.longitude
    //                                 zoom: zoomLevel];
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:centreLocation zoom: zoomLevel];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];
}



//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t
-(void) showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t

{
    if(routes)
    {
        //[self.mapView removeAnnotations:[self.mapView annotations]];
        [mapView_ clear];
    }
    
    
    //[self.mapView addAnnotation:f];
    //[self.mapView addAnnotation:t];
    GMSMarker *markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = f;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
    GMSMarker *markerDriver = [[GMSMarker alloc] init];
    markerDriver.position = f;
    markerDriver.icon = [UIImage imageNamed:@"pin_driver"];
    markerDriver.map = mapView_;
    
    routes = [self calculateRoutesFrom:f to:t];
    NSInteger numberOfSteps = routes.count;
    
    
    GMSMutablePath *pathpoliline=[GMSMutablePath path];
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        CLLocation *location = [routes objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        [pathpoliline addCoordinate:coordinate];
    }
    //MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    
    
    
    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:pathpoliline];
    
    polyLinePath.strokeColor = [UIColor blueColor];
    polyLinePath.strokeWidth = 5.f;
    polyLinePath.geodesic = YES;
    polyLinePath.map = mapView_;
    [self centerMap];
}




#pragma mark-
#pragma mark MKPolyline delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}

#pragma mark-
#pragma mark- MapView delegate
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    MKAnnotationView *annot=[[MKAnnotationView alloc] init];
    
    SBMapAnnotation *temp=(SBMapAnnotation*)annotation;
    if (temp.yTag==1000)
    {
        annot.image=[UIImage imageNamed:@"pin_driver"];
    }
    if (temp.yTag==1001)
    {
        annot.image=[UIImage imageNamed:@"pin_client_org"];
        
    }
    
    return annot;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

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
    
    //[self.mapView removeAnnotations:self.mapView.annotations];
    [mapView_ clear];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    /*
     SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
     curLoc.yTag=1000;
     [self.mapView addAnnotation:curLoc];
     */
    
    
    
    mapView_.myLocationEnabled = NO;
    //[self.viewForMap addSubview:mapView_];
    mapView_.delegate=self;
    // Creates a marker in the center of the map.
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    //marker.title = @"Current Location";
    //marker.snippet = @"Australia";
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    
    
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
    
    
}



#pragma mark-
#pragma mark- Button Click Events


- (IBAction)onClickSetEta:(id)sender
{
    
    
}

- (IBAction)onClickReject:(id)sender
{
    strPickuplocation = @"";
    strDropOffLocation = @"";
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    [sound1Player stop];
    
    if (internet)
    {
        pref=[NSUserDefaults standardUserDefaults];
        strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
        
        if (strRequsetId!=nil)
        {
            NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
            
            [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
            [dictparam setObject:strUserId forKey:PARAM_ID];
            [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
            [dictparam setObject:@"0" forKey:PARAM_ACCEPTED];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
             {
                 
                 NSLog(@"Respond to Request= %@",response);
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         
                         [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"REQUEST_REJECTED",[pref objectForKey:@"TranslationDocumentName"],nil)];
                         
                         //[self.time invalidate];
                         [self.viewforPickupLabel setHidden:YES];
                         [self.viewforDropOffLabel setHidden:YES];
                         [self.progtime invalidate];
                         [self hide];
                         [self Reject_LoadHome];
                     }
                 }
                 
             }];
        }
        else
        {
            
        }
    }
    
    pref=[NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:PREF_REQUEST_ID];
    strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
    
    //    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    //    self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
    //    [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
    //    [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
    //    self.navigationItem.hidesBackButton=YES;
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    
    [mapView_ clear];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [self.progtime invalidate];
    [self hide];
    
    //[self performSegueWithIdentifier:@"qwe" sender:self];
}

-(void)RejectRequestAutomatically
{
    strPickuplocation = @"";
    strDropOffLocation = @"";
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    [sound1Player stop];
    
    if (internet)
    {
        pref=[NSUserDefaults standardUserDefaults];
        strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
        
        if (strRequsetId!=nil)
        {
            NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
            
            [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
            [dictparam setObject:strUserId forKey:PARAM_ID];
            [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
            [dictparam setObject:@"0" forKey:PARAM_ACCEPTED];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
             {
                 
                 NSLog(@"Respond to Request= %@",response);
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         
                         [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"REQUEST_REJECTED",[pref objectForKey:@"TranslationDocumentName"],nil)];
                         
                         //[self.time invalidate];
                         [self.viewforPickupLabel setHidden:YES];
                         [self.viewforDropOffLabel setHidden:YES];
                         [self.progtime invalidate];
                         [self hide];
                         [self Reject_LoadHome];
                     }
                 }
                 
             }];
        }
        else
        {
            
        }
    }
    
    pref=[NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:PREF_REQUEST_ID];
    strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
    
    //    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    //    self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
    //    [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
    //    [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
    //    self.navigationItem.hidesBackButton=YES;
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    
    [mapView_ clear];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [self.progtime invalidate];
    [self hide];

}

- (IBAction)onClickAccept:(id)sender
{
    strPickuplocation = @"";
    strDropOffLocation = @"";
    [self.viewforPickupLabel setHidden:YES];
    [self.viewforDropOffLabel setHidden:YES];
    
    [sound1Player stop];

    [APPDELEGATE showLoadingWithTitle:NSLocalizedStringFromTable(@"WAITING_ADMIN_APPROVE",[pref objectForKey:@"TranslationDocumentName"],nil)];
    [self respondToRequset];
    [self.time invalidate];
    //[self performSegueWithIdentifier:@"segurtoarrived" sender:self];
    
    //[self.etaView setHidden:NO];
}

- (IBAction)onClickNoKey:(id)sender
{
    [self.etaView setHidden:YES];
}

- (IBAction)pickMeBtnPressed:(id)sender
{
    [self showUserLoc];
}


-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

-(void)invalidateTimer
{
    [self.timer invalidate];
    [self.time invalidate];
}



#pragma mark-
#pragma mark- Progress Bar Method


-(void)customProgressBar
{
    progressView.hidden=YES;
    float t=(time/60.0f);
    lblTime.text=[NSString stringWithFormat:@"%d",time];
    //self.lblTime.font=[UberStyleGuide fontRegular:48.0f];
    self.lblTime.font=[UIFont fontWithName:@"OpenSans" size:24.0f];
    if(time<5)
    {
        progressView.color = [UIColor colorWithRed:245.0f/255.0f green:25.0f/255.0f blue:42.0f/255.0f alpha:1.0];
    }
    else
    {
        progressView.color = [UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:214.0f/255.0f alpha:1.0];
    }
    
    
    progressView.background = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0];
    progressView.showText = @NO;
    progressView.progress = t;
    progressView.borderRadius = @NO;
    progressView.animate = @NO;
    progressView.type = LDProgressSolid;
    time=time-1;
//    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
//    if ([[pref valueForKey:@"SOUND"] isEqualToString:@"on"]) {
//        [self PlaySound];
//        [sound1Player play];
//    }

    if(time<15)
    {
//        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
//        if ([[pref valueForKey:@"SOUND"] isEqualToString:@"on"]) {
//            [self PlaySound];
//            [sound1Player play];
//        }
    }
    if(time<0)
    {
        [self.progtime invalidate];
        [self hide];
        [sound1Player stop];
        [self RejectRequestAutomatically];
        [self.viewforDropOffLabel setHidden:YES];
        [self.viewforPickupLabel setHidden:YES];
        strPickuplocation = @"";
        strDropOffLocation = @"";
        
        [self.time invalidate];
        pref=[NSUserDefaults standardUserDefaults];
        [pref removeObjectForKey:PREF_REQUEST_ID];
        strRequsetId=[pref valueForKey:PREF_REQUEST_ID];
        
        if (internet)
        {
            pref=[NSUserDefaults standardUserDefaults];
            strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
            
            if (strRequsetId!=nil)
            {
                NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
                
                [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
                [dictparam setObject:strUserId forKey:PARAM_ID];
                [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
                [dictparam setObject:@"0" forKey:PARAM_ACCEPTED];
                
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
                 {
                     
                     NSLog(@"Respond to Request= %@",response);
                     [APPDELEGATE hideLoadingView];
                     if (response)
                     {
                         if([[response valueForKey:@"success"] intValue]==1)
                         {
                             
                             [APPDELEGATE showToastMessage:NSLocalizedStringFromTable(@"REQUEST_REJECTED",[pref objectForKey:@"TranslationDocumentName"],nil)];
                             
                             //[self.time invalidate];
                             [self.progtime invalidate];
                             [self hide];
                         }
                     }
                     
                 }];
            }
            else
            {
                
            }
        }
        
        
        [self getAllRequests];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
        [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
        [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
        
        [mapView_ clear];
        
        CLLocationCoordinate2D current;
        current.latitude=[struser_lati doubleValue];
        current.longitude=[struser_longi doubleValue];
        
        
        marker = [[GMSMarker alloc] init];
        marker.position = current;
        marker.icon = [UIImage imageNamed:@"pin_driver"];
        marker.map = mapView_;
    }
    
}

#pragma mark-
#pragma mark - Sound Player
-(void)PlaySound
{
    
    [sound1Player stop];
    
    NSString *bk=[NSString stringWithFormat:@"beep-07"];
    NSString *path = [[NSBundle mainBundle] pathForResource:bk ofType:@"mp3"];
    NSURL *url=[NSURL fileURLWithPath:path];
    
    sound1Player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [sound1Player setVolume: 1.0];
    if(!sound1Player)
    {
        NSLog(@"error");
    }
    
    sound1Player.delegate=self;
    sound1Player.numberOfLoops= -1;
    [sound1Player stop];
}

#pragma mark-
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"contact us"])
    {
        ContactVC *obj=[segue destinationViewController];
        obj.dictContact=sender;
    }
}
- (IBAction)onClickClose:(id)sender
{
    exit(0);
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
                     if([[response valueForKey:@"is_active"] intValue]==1)
                     {
                         swAvailable=YES;
                         
                         [self.btnStatus setTitle:@"INACTIVO" forState:UIControlStateNormal];
                         [self.btnStatus setTitle:@"INACTIVO" forState:UIControlStateSelected];
                         [self.btnStatus setTitle:@"INACTIVO" forState:UIControlStateHighlighted];
                         
                         
                     }
                     else
                     {
                         swAvailable=NO;
                         [self.btnStatus setTitle:@"ACTIVO" forState:UIControlStateNormal];
                         [self.btnStatus setTitle:@"ACTIVO" forState:UIControlStateSelected];
                         [self.btnStatus setTitle:@"ACTIVO" forState:UIControlStateHighlighted];
                     }
                 }
             }
             if (swAvailable)
                 [self.viewStatus setHidden:YES];
             else
                 [self.viewStatus setHidden:NO];
             
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No Internet", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
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
             if (response)
             {
                 if([[response valueForKey:@"success"]intValue]==1)
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"AVAILABILITY_UODATE", nil)];
                     if (swAvailable)
                         [self.viewStatus setHidden:YES];
                     else
                         [self.viewStatus setHidden:NO];
                     
                 }
             }
             
         }];
    }
}
- (IBAction)setState:(id)sender
{
    if (swAvailable) {
        swAvailable = NO;
        [self.btnStatus setTitle:@"ACTIVO" forState:UIControlStateNormal];
        [self.btnStatus setTitle:@"ACTIVO" forState:UIControlStateSelected];
        [self.btnStatus setTitle:@"ACTIVO" forState:UIControlStateHighlighted];
        
    }
    else
    {
        swAvailable = YES;
        [self.btnStatus setTitle:@"INACTIVO" forState:UIControlStateNormal];
        [self.btnStatus setTitle:@"INACTIVO" forState:UIControlStateSelected];
        [self.btnStatus setTitle:@"INACTIVO" forState:UIControlStateHighlighted];
        
        
    }
    [self setStatus];
    
}


@end
