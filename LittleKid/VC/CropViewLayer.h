//
//  CropViewLayer.h
//  LittleKid
//
//  Created by XC on 15-2-3.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropViewLayer : UIView
{
    CGRect _cropRect;
    UIImageView* leftTopCorner;
    UIImageView* leftBottomCorner;
    UIImageView* rightTopCorner;
    UIImageView* rightBottomCorner;
}
- (void)setCropRegionRect:(CGRect)cropRect;

@end
