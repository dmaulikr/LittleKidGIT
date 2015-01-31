//
//  ViewControllerImpInfo.m
//  LittleKid
//
//  Created by 吴相鑫 on 1/9/15.
//  Copyright (c) 2015 吴相鑫. All rights reserved.
//

#import "ViewControllerImpInfo.h"

@interface ViewControllerImpInfo ()
@property(retain,nonatomic) UIDatePicker *datePicker;
@property(retain,nonatomic) UITextField *nickText;
@property(retain,nonatomic) UITextField *birthText;
@property (strong, nonatomic) IBOutlet UIButton *nickBtn;
@property (strong, nonatomic) IBOutlet UIButton *birthBtn;
@end

@implementation ViewControllerImpInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pickerDate:(id)sender {


}

- (IBAction)pickerName:(id)sender {
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"请输入昵称" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
     [alertView setTag:1];
    
    self.nickText = [ [UITextField alloc] init];
    self.nickText.backgroundColor = [UIColor whiteColor];
    self.nickText.borderStyle = UITextBorderStyleBezel;
    self.nickText.frame = CGRectMake(alertView.frame.origin.x+40, alertView.frame.origin.y+5,210, 23);
    self.nickText.text = self.nickBtn.currentTitle;
    
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
            }
            break;
            case 2:{
                NSDate *mydate = [self.datePicker date];
                NSString *dateFromData = [NSString stringWithFormat:@"%@",mydate];
                NSString *date = [dateFromData substringWithRange:NSMakeRange(0, 10)];
                [self.birthBtn setTitle:date forState:UIControlStateNormal];
            }
            break;
                
            default:
                break;
        }
    }
}


@end
