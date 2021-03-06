//
//  CropperImgViewController.m
//  LittleKid
//
//  Created by XC on 15-2-3.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "CropperImgViewController.h"

@interface CropperImgViewController ()
{
    ImageCropperView *editorView;
}
@end

@implementation CropperImgViewController
@synthesize delegate;
@synthesize image;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //添加导航栏和完成按钮
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [self.view addSubview:naviBar];
    
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"图片裁剪"];
    [naviBar pushNavigationItem:naviItem animated:YES];
    
    //保存按钮
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(saveButton)];
    naviItem.rightBarButtonItem = doneItem;
    
    //image为上一个界面传过来的图片资源
    editorView = [[ImageCropperView alloc] init];
    [editorView setImage:self.image];
    editorView.frame = CGRectMake(0, 44, self.view.frame.size.width ,  self.view.frame.size.height );
    editorView.backgroundColor  = [UIColor redColor];
    editorView.center = CGPointMake(self.view.center.x, self.view.center.y+44);
    
    [self.view addSubview:editorView];
}

//完成截取
-(void)saveButton
{
    //output为截取后的图片，UIImage类型
    UIImage *resultImage = editorView.getCroppedImage;
    
    //通过代理回传给上一个界面显示
    [self.delegate passImage:resultImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
