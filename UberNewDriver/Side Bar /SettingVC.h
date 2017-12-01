//
//  SettingVC.h
//  UberforX Provider
//
//  Created by My Mac on 11/15/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"

@interface SettingVC : BaseVC <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISwitch *swAvailable;
@property (weak, nonatomic) IBOutlet UILabel *lblYes;
- (IBAction)backBtnPressed:(id)sender;
- (IBAction)setState:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblAvailable;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
- (IBAction)setSound:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *swSound;
@property (weak, nonatomic) IBOutlet UILabel *lblSound;
@property (weak, nonatomic) IBOutlet UILabel *lblSoundtext;
//Language outlets below
@property (weak, nonatomic) IBOutlet UIView *viewSelection;
@property (weak, nonatomic) IBOutlet UIView *viewSelection1;
@property (weak, nonatomic) IBOutlet UIView *viewSelection2;
@property (weak, nonatomic) IBOutlet UIView *viewBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine1;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine2;
@property (weak, nonatomic) IBOutlet UITableView *tblLanguageList;
@property (weak, nonatomic) IBOutlet UILabel *lbl_languagetitle;
@property (weak, nonatomic) IBOutlet UILabel *lb_language;
@property (weak, nonatomic) IBOutlet UILabel *lbl_languageabbrv;
@property (weak, nonatomic) IBOutlet UIButton *btnlanguageselection;
- (IBAction)btnlanguageselection:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *BgViewforTblview;



@end
