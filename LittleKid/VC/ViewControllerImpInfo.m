//
//  ViewControllerImpInfo.m
//  LittleKid
//
//  Created by 吴相鑫 on 1/9/15.
//  Copyright (c) 2015 吴相鑫. All rights reserved.
//

#import "ViewControllerImpInfo.h"
#import "RuntimeStatus.h"
#import "UIImage+FixOrientation.h"
#import "RadioButton.h"

@interface ViewControllerImpInfo ()
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property(retain,nonatomic) UIDatePicker *datePicker;
@property(retain,nonatomic) UITextField *birthText;
@property (strong, nonatomic) IBOutlet UITextField *nickText;
@property (strong, nonatomic) IBOutlet UIButton *birthBtn;
@property (strong, nonatomic) IBOutlet UIImageView *sexImgView;

@end

@implementation ViewControllerImpInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载性别选择
    [self setRadioBtn];
    //隐藏tabbar
    self.tabBarController.tabBar.hidden = YES;
    
    self.nickText.delegate = self;
    //显示圆角
//    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
//    self.profileImageView.layer.masksToBounds = YES;
    
    //监听图像区域点击事件
    self.profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTosetUserImage)];
    [self.profileImageView addGestureRecognizer:singleTap];
    
    //初始化本地数据
    if ([RuntimeStatus instance].userInfo.headImage != nil) {
        self.profileImageView.image = [[RuntimeStatus instance] circleImage:[RuntimeStatus instance].userInfo.headImage withParam:0];
    }
    self.nickText.text = [RuntimeStatus instance].userInfo.nickname;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[RuntimeStatus instance].userInfo.birthday];
    
    [self.birthBtn setTitle:strDate forState:UIControlStateNormal];
    
    //add--点击背景退出输入法
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
}

///add
- (void)removeKeyBoard{
    [self.nickText resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDefault) {
        [textField resignFirstResponder];
    }
    return YES;
}


#pragma mark--绘制RadioButton

-(void)setRadioBtn
{
    UIImage *maleImage = [UIImage imageNamed:@"maleimage"];
    UIImage *famaleImage = [UIImage imageNamed:@"famaleimage"];
    
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:2];
    CGRect btnRect = CGRectMake(self.sexImgView.frame.origin.x + 80, self.sexImgView.frame.origin.y + self.sexImgView.frame.size.height - 3, 100, 30);
    int i = 0;
    for (UIImage *images in @[maleImage,famaleImage]) {
        RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
        [btn addTarget:self action:@selector(sexSegmentAction:) forControlEvents:UIControlEventValueChanged];
        btn.tag = i++;
        btnRect.origin.x += 70;
        [btn setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [self.view addSubview:btn];
        
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.origin.x+25, btn.frame.origin.y, 30, 30)];
        bg.image = images;
        [self.view addSubview:bg];
        [buttons addObject:btn];
    }
    
    [buttons[0] setGroupButtons:buttons]; // Setting buttons into the group
    
    //set gender
    if ([[RuntimeStatus instance].userInfo.gender isEqualToString:@"boy"]) {
        [buttons[0] setSelected:YES];
    }
    else
    {
        [buttons[1] setSelected:YES];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[RuntimeStatus instance] setNickName:self.nickText.text];
    if (self.profileImageView.image.size.height > 75) {
        self.profileImageView.image = [self scaleToSize:self.profileImageView.image size:CGSizeMake(70, 70)];        
    }
    [[RuntimeStatus instance] setHeadImage:self.profileImageView.image];
    [[RuntimeStatus instance] saveUserInfo];
    
}

- (IBAction)pickerBirth:(id)sender {
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"请选择生日" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView setTag:2];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    self.datePicker.locale = locale;
    
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.frame = CGRectMake(10, 50, 280, 100);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    if ([RuntimeStatus instance].userInfo.birthday) {
        self.datePicker.date = [RuntimeStatus instance].userInfo.birthday;
    }
    else
    {
        self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    
    
    
    // And launch the dialog
    [alertView addCustomerSubview:self.datePicker];
    [alertView show];
}



-(void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
    {
        NSDate *mydate = [self.datePicker date];
        NSString *dateFromData = [NSString stringWithFormat:@"%@",mydate];
        NSString *date = [dateFromData substringWithRange:NSMakeRange(0, 10)];
        [[RuntimeStatus instance] setBirthday:mydate];
        [self.birthBtn setTitle:date forState:UIControlStateNormal];
    }
}

#pragma mark--设置用户图像

-(void)clickTosetUserImage{
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
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
        
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //图片压缩，因为原图都是很大的，不必要传原图//[self scaleImage:originImage toScale:0.3];
        //TODO:压缩
        
        /*
         用相机拍摄出来的照片含有EXIF信息，UIImage的imageOrientation属性指的就是EXIF中的orientation信息。
         如果我们忽略orientation信息，而直接对照片进行像素处理或者drawInRect等操作，得到的结果是翻转或者旋转90之后的样子。这是因为我们执行像素处理或者drawInRect等操作之后，imageOrientaion信息被删除了，imageOrientaion被重设为0，造成照片内容和imageOrientaion不匹配。
         所以，在对照片进行处理之前，先将照片旋转到正确的方向，并且返回的imageOrientaion为0 */
        
        UIImage *scaleImage =[self fixOrientation:originImage];
        
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
        RSKImageCropViewController *captureView = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
        captureView.delegate = self;
//        captureView.image = image;
        [RuntimeStatus instance].userInfo.headImage = image;
        
        //隐藏UIImagePickerController本身的导航栏
        picker.navigationBar.hidden = YES;
        [picker pushViewController:captureView animated:YES];
        
    }
}


#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToViewController:self.vi animated:<#(BOOL)#>];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    [self passImage:croppedImage];
}



- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
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

-(void)sexSegmentAction:(RadioButton*)sender
{
    if(sender.selected)
    {
        if(sender.tag == 0)
        {
            [RuntimeStatus instance].userInfo.gender = @"boy";
        }
        else
        {
            [RuntimeStatus instance].userInfo.gender = @"girl";
        }
    }
    
    [[RuntimeStatus instance] saveUserInfo];
    
}
@end
