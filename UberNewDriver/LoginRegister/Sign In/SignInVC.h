//
//  SignInVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "JVFloatLabeledTextField.h"

@interface SignInVC : BaseVC <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property ( nonatomic) bool maleBtnSelected;
@property ( nonatomic) bool femaleBtnSelected;

@property (weak, nonatomic) IBOutlet UIButton *btnNav_Register;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *typeCollectionView;

- (IBAction)faceBookBtnPressed:(id)sender;
- (IBAction)selectCountryBtnPressed:(id)sender;
- (IBAction)googleBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;
- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)saveBtnPressed:(id)sender;
- (IBAction)imgPickBtnPressed:(id)sender;

- (IBAction)backBtnPressed:(id)sender;

extern NSString *testuserid;

@property (weak, nonatomic) IBOutlet UIView *viewForPicker;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UIButton *btnpropic;
@property (weak, nonatomic) IBOutlet UIButton *btnemail_info;
@property (weak, nonatomic) IBOutlet UIButton *btnclickinfo;
@property (weak, nonatomic) IBOutlet UIButton *btncancel_pickerview;
@property (weak, nonatomic) IBOutlet UIButton *btndone_pickerview;
@property (weak, nonatomic) IBOutlet UILabel *lblselectcountry;


@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIImageView *imgProPic;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtFirstName;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtLastName;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtEmail;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtPassword;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtRePassword;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtAddress;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtBio;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtZipcode;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtNumber;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtType;
@property (weak, nonatomic) IBOutlet UIImageView *imgType;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtTaxiModel;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *txtTaxiNumber;

- (IBAction)typeBtnPressed:(id)sender;
- (IBAction)pickDoneBtnPressed:(id)sender;
- (IBAction)pickCancelBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *pickTypeView;
@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
- (IBAction)termsBtnPressed:(id)sender;
- (IBAction)checkBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnTerms;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
- (IBAction)selectServiceBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectService;
@property (weak, nonatomic) IBOutlet UIButton *btnAgreeCondtion;

- (IBAction)onClickCarModelInfo:(id)sender;
- (IBAction)onClickCarNumberInfo:(id)sender;

- (IBAction)onClickEmailInfo:(id)sender;
- (IBAction)onClickInfo:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imgInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;


@property (weak, nonatomic) IBOutlet UIImageView *imgCarModelInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblCarModelInfo;

@property (weak, nonatomic) IBOutlet UIImageView *imgCarNumberInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblCarNumberInfo;

@property (weak, nonatomic) IBOutlet UIImageView *imgEmailInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailInfo;

@property (weak, nonatomic) IBOutlet UILabel *genderLbl;
@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
@property (weak, nonatomic) IBOutlet UILabel *maleLbl;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;
@property (weak, nonatomic) IBOutlet UILabel *femaleLbl;

@end
