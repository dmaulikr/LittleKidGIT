//
//  CropperImgViewController.h
//  LittleKid
//
//  Created by XC on 15-2-3.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCropperView.h"
#import "PassImageDelegate.h"

@interface CropperImgViewController : UIViewController
{
    UIImage *image;
}

@property(nonatomic,strong) UIImage *image;

@property(strong,nonatomic) NSObject<PassImageDelegate> *delegate;

@end
