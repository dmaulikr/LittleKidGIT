//
//  ViewControllerImpInfo.m
//  LittleKid
//
//  Created by 吴相鑫 on 1/9/15.
//  Copyright (c) 2015 吴相鑫. All rights reserved.
//

#import "ViewControllerImpInfo.h"

@interface ViewControllerImpInfo ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property(retain,nonatomic) UIDatePicker *datePicker;
@property(retain,nonatomic) UITextField *nickText;
@property(retain,nonatomic) UITextField *birthText;
@property (strong, nonatomic) IBOutlet UIButton *nickBtn;
@property (strong, nonatomic) IBOutlet UIButton *birthBtn;
@property(retain,nonatomic)NSUserDefaults *defaults;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sexText;

@end

@implementation ViewControllerImpInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    //显示圆角
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    //监听图像区域点击事件
    self.profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTosetUserImage)];
    [self.profileImageView addGestureRecognizer:singleTap];
    
    //初始化本地数据
    self.defaults =[NSUserDefaults standardUserDefaults];
    
    NSData *imgdata = [self.defaults dataForKey:@"image"];
    self.profileImageView.image =  [UIImage imageWithData:imgdata];
    [self.nickBtn setTitle:[self.defaults objectForKey:@"nick"] forState:UIControlStateNormal];
    [self.birthBtn setTitle:[self.defaults objectForKey:@"birth"] forState:UIControlStateNormal];
    [self.sexText setSelectedSegmentIndex:[self.defaults integerForKey:@"sex_index"]];
    
    
    //监听性别选择点击
    [self.sexText addTarget:self action:@selector(sexSegmentAction) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickerFinish:(id)sender {
    
    //保存用户图像
    NSData *imgData = UIImageJPEGRepresentation(self.profileImageView.image, 100);
    [self.defaults setObject:imgData forKey:@"image"];
    
    //数据同步到磁盘，这里把前面设置的昵称、性别等所有数据同步
    [self.defaults synchronize];
}



- (IBAction)pickerName:(id)sender {
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"请输入昵称" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
     [alertView setTag:1];
    
    self.nickText = [ [UITextField alloc] init];
    self.nickText.backgroundColor = [UIColor whiteColor];
    self.nickText.borderStyle = UITextBorderStyleBezel;
    self.nickText.frame = CGRectMake(alertView.frame.origin.x+40, alertView.frame.origin.y+5,210, 23);
    self.nickText.text = [self.defaults objectForKey:@"nick"];//self.nickBtn.currentTitle;
    
    [alertView addCustomerSubview:self.nickText];
    [alertView show];
    
    
    NSLog(@"%@",sender);
}

- (IBAction)pickerBirth:(id)sender {
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"请选择生日" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setTag:2];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    self.datePicker.locale = locale;
    
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.frame = CGRectMake(10, 50, 280, 100);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    
    
    // And launch the dialog
    [alertView addCustomerSubview:self.datePicker];
    [alertView show];
}



-(void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
    {
        switch ((int)[alertView tag])
        {
            case 1:{
                [self.nickBtn setTitle:self.nickText.text forState:UIControlStateNormal];
                [self.defaults setObject:self.nickText.text forKey:@"nick"];
            }
            break;
            case 2:{
                NSDate *mydate = [self.datePicker date];
                NSString *dateFromData = [NSString stringWithFormat:@"%@",mydate];
                NSString *date = [dateFromData substringWithRange:NSMakeRange(0, 10)];
                [self.birthBtn setTitle:date forState:UIControlStateNormal];
                [self.defaults setObject:date forKey:@"birth"];
            }
            break;
                
            default:
                break;
        }
    }
}

#pragma mark--设置用户图像

-(void)clickTosetUserImage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改图像" message:@" " delegate:self cancelButtonTitle:@" " otherButtonTitles:@" ", nil];
    [alertView show];
}

#pragma mark--设置用户性别

-(void)sexSegmentAction
{
    [self.defaults setInteger:self.sexText.selectedSegmentIndex forKey:@"sex_index"];
}
@end
