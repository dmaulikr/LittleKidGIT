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
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Photo library", nil];
    [chooseImageSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    switch (buttonIndex) {
        case 0://Take picture
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
            }else{
                NSLog(@"模拟器无法打开相机");
            }
            [self presentViewController:picker animated:YES completion:nil];
            break;
            
        case 1://From album
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            break;
            
        default:
            
            break;
    }
}

#pragma 拍照选择照片协议方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSData *data;
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //图片压缩，因为原图都是很大的，不必要传原图
        UIImage *scaleImage = originImage;//[self scaleImage:originImage toScale:0.3];
        
        //以下这两步都是比较耗时的操作，最好开一个HUD提示用户，这样体验会好些，不至于阻塞界面
        if (UIImagePNGRepresentation(scaleImage) == nil) {
            //将图片转换为JPG格式的二进制数据
            data = UIImageJPEGRepresentation(scaleImage, 1);
        } else {
            //将图片转换为PNG格式的二进制数据
            data = UIImagePNGRepresentation(scaleImage);
        }
        
        //将二进制数据生成UIImage
        UIImage *image = [UIImage imageWithData:data];
        
        //将图片传递给截取界面进行截取并设置回调方法（协议）
        CropperImgViewController *captureView = [[CropperImgViewController alloc] init];
        captureView.delegate = self;
        captureView.image = image;

        //隐藏UIImagePickerController本身的导航栏
        picker.navigationBar.hidden = YES;
        [picker pushViewController:captureView animated:YES];
        
    }
}

#pragma mark - 图片回传协议方法
-(void)passImage:(UIImage *)image
{
    self.profileImageView.image = image;
}

#pragma mark- 缩放图片
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


#pragma mark--设置用户性别

-(void)sexSegmentAction
{
    [self.defaults setInteger:self.sexText.selectedSegmentIndex forKey:@"sex_index"];
}
@end
