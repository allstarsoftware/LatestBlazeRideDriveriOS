//
//  ArrivedMapVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import "CrumbPathView.h"
#import "CrumbPath.h"
#import "WAGLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "FeedBackVC.h"

@class PickMeUpMapVC,RatingBar;

@interface ArrivedMapVC : BaseVC <MKMapViewDelegate,MKAnnotation,CLLocationManagerDelegate,GMSMapViewDelegate>
{
    UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
    
    GMSMapView *mapView_;
    GMSMarker *markerOwner;
    GMSMarker *markerDriver;
    GMSMarker *marker;
    GMSMarker *driver_marker;

}
@property (weak, nonatomic) IBOutlet UIImageView *linedivide1;
@property (weak, nonatomic) IBOutlet UIImageView *linedivide2;
@property (weak, nonatomic) IBOutlet UIImageView *linedivide3;
@property (weak, nonatomic) IBOutlet UIImageView *ImageClock;
@property (weak, nonatomic) IBOutlet UIImageView *ImageMiles;
@property (weak, nonatomic) IBOutlet UIImageView *ImageCash;

@property NSString *InstantJobNavigate;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView_;
@property (weak, nonatomic) IBOutlet UIImageView *ImgCalluser;


- (IBAction)onClickArrived:(id)sender;
- (IBAction)onClickJobDone:(id)sender;
- (IBAction)onClickWalkStart:(id)sender;
- (IBAction)onClickWalkerStart:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnWalker;
@property (weak, nonatomic) IBOutlet UIButton *btnWalk;
@property (weak, nonatomic) IBOutlet UIButton *btnJob;
@property (weak, nonatomic) IBOutlet UIButton *btnArrived;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UIButton *btnDistance;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UILabel *lblCallUser;
@property (weak, nonatomic) IBOutlet UIButton *btncancel_rejectionview;
@property (weak, nonatomic) IBOutlet UIButton *btnconfirm_rejctnview;
@property (weak, nonatomic) IBOutlet UITextField *enterfld_rejctnview;
@property (weak, nonatomic) IBOutlet UILabel *lblrejectionreason;

@property (weak, nonatomic) IBOutlet UIView *TimerView;
@property (weak, nonatomic) IBOutlet UILabel *TimerLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnWait;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;
- (IBAction)BtnPause:(id)sender;

- (IBAction)BtnWait:(id)sender;

@property(nonatomic, strong) NSTimer *timeForUpdateWalkLoc;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *timerForDistance;
@property(nonatomic, strong) NSTimer *timerForCancelRequest;
@property(nonatomic, strong) NSTimer *timerForDestinationAddr;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblUserRate;
- (IBAction)onClickCall:(id)sender;


@property (nonatomic,strong) MKPolyline *polyline;
@property(nonatomic,strong) CrumbPath *crumbs;
@property (nonatomic,strong) CrumbPathView *crumbView;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;

@property (nonatomic,strong) PickMeUpMapVC *pickMeUp;
@property (weak, nonatomic) IBOutlet RatingBar *ratingView;

@property (weak, nonatomic) IBOutlet UILabel *lblPayment;
@property (weak, nonatomic) IBOutlet UILabel *lblDestAddress;

- (IBAction)onClickNav:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnNav;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelTrip;
@property (weak, nonatomic) IBOutlet UIView *panGuestureview;

@end
