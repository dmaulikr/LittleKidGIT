//
//  GameControl.h
//  打地鼠
//
//  Created by 元帅 on 14-7-22.
//  Copyright (c) 2014年 唐元帅. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GameControlDelegate
- (void)alterWillDismiss:(int )score;
@end
@interface GameControl : UIView<UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, assign) id<GameControlDelegate> delegate;

@property(nonatomic) int score;
//@property (strong, nonatomic) UINavigationController *navController;
@end


