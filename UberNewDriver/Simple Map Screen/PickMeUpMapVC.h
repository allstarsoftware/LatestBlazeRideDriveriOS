//
//  PickMeUpMapVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import "sbMapAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "LDProgressView.h"
#import "UIColor+RGBValues.h"
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "AudioToolbox/AudioToolbox.h"
#import <QuartzCore/QuartzCore.h>

@class SideBarVC;
@class ArrivedMapVC,RatingBar;


@interface PickMeUpMapVC : BaseVC <MKAnnotation,MKMapViewDelegate,GMSMapViewDelegate,AVAudioPlayerDelegate>
{
    Reachability *internetReachableFoo;
    BOOL internet;
    UIImageView* routeView;
    
	NSArray* routes;
	
	UIColor* lineColor;
    
    LDProgressView *progressView;
    GMSMapView *mapView_;
    GMSMarker *marker;
}

// Outlets for New Design Accept & Reject View

@property (weak, nonatomic) IBOutlet UIView *AcceptViewNewDesign;
@property (weak, nonatomic) IBOutlet UIButton *BtnNewRejectRequest;
- (IBAction)BtnNewReject:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *BtnNewAccept;
- (IBAction)BtnNewAccept:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *MapRoundedImageview;
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
@property (weak, nonatomic) IBOutlet UIView *AddressSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *NewPickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *NewDropLabel;
@property (weak, nonatomic) IBOutlet UIView *ViewforButtons;
@property (weak, nonatomic) IBOutlet UILabel *LblPriceValue;
@property (weak, nonatomic) IBOutlet UILabel *LblPrice;



@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIView *etaView;
@property (weak, nonatomic) IBOutlet UIView *datePicker;

- (IBAction)onClickSetEta:(id)sender;
- (IBAction)onClickReject:(id)sender;

- (IBAction)onClickAccept:(id)sender;

- (IBAction)onClickNoKey:(id)sender;
-(void)goToSetting:(NSString *)str;

@property (weak, nonatomic) IBOutlet UILabel *lblBlue;
@property (weak, nonatomic) IBOutlet UILabel *lblGrey;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar;
@property (weak, nonatomic) IBOutlet UILabel *lblRate;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;
- (IBAction)pickMeBtnPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *ProfileView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView_;

@property (weak, nonatomic) IBOutlet UIProgressView *progressTimer;


@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *time;
@property(nonatomic, strong) NSTimer *progtime;
@property (weak, nonatomic) IBOutlet UIImageView *imgTimeBg;

@property (weak, nonatomic) IBOutlet UILabel *lblWhite;
@property(nonatomic, strong) ArrivedMapVC *arrivedMap;

@property (weak, nonatomic) IBOutlet RatingBar *ratingView;
@property (weak, nonatomic) IBOutlet UIView *viewForMap;
@property (weak, nonatomic) IBOutlet UIView *viewForNotApproved;
- (IBAction)onClickClose:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblNotApproved;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (strong, nonatomic) AVAudioPlayer *sound1Player;


@property(strong, nonatomic) IBOutlet UILabel *lblPickupLocation;
@property(strong, nonatomic) IBOutlet UILabel *lblDropOffLocation;

@property (strong, nonatomic) IBOutlet UIView *viewforPickupLabel;
@property (strong, nonatomic) IBOutlet UIView *viewforDropOffLabel;
@property (weak, nonatomic) IBOutlet UIView *panGuestureview;


@property (weak, nonatomic) IBOutlet UIView *viewStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;

@end
