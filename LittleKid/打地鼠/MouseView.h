//
//  MouseView.h
//  打地鼠
//
//  Created by 元帅 on 14-7-22.
//  Copyright (c) 2014年 唐元帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MouseView : UIImageView
@property (nonatomic,assign) NSInteger coodY;
@property (nonatomic,assign) float speed;//运动速度,可证可负
- (void)move;
- (BOOL)comeOut;
- (void)beAttack;

@end
