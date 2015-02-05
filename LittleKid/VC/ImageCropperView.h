//
//  ImageCropperView.h
//  LittleKid
//
//  Created by XC on 15-2-3.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropViewLayer.h"

#define IMAGE_BOUNDRY_SPACE 10
enum rectPoint { LeftTop = 0, RightTop=1, LeftBottom = 2, RightBottom = 3, MoveCenter = 4, NoPoint = 1};

@interface ImageCropperView : UIView
{
    UIImageView* _imageView;
    UIImage* _image;
    CropViewLayer* _cropView;
    enum rectPoint _movePoint;
    CGRect _cropRect;
    CGRect _translatedCropRect;
    CGPoint _lastMovePoint;
    CGFloat _scalingFactor;
}
- (void)setCropRegionRect:(CGRect)cropRect;
- (void) setImage:(UIImage*)image;
- (void) setFrame:(CGRect)frame;
- (void) reLayoutView;
- (UIImage *)getCroppedImage;

@end
