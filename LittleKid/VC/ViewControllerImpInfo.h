//
//  ViewControllerImpInfo.h
//  LittleKid
//
//  Created by 吴相鑫 on 1/9/15.
//  Copyright (c) 2015 吴相鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertView.h"
#import "PassImageDelegate.h"
#import "UIViewControllerBase.h"
#import "RSKImageCropViewController.h"

@interface ViewControllerImpInfo : UIViewControllerBase<MBAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PassImageDelegate,RSKImageCropViewControllerDelegate>


@end
