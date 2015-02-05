//
//  CheseInterface.h
//  象棋Demo
//
//  Created by QzydeMac on 14/11/30.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNGridMenu.h"

@protocol CheseInterfaceDelegat <NSObject>

-(void) cheseInterRezult;

@end

@interface CheseInterface : UIView
@property (assign,readwrite,nonatomic)id delegate;
@property (retain,readwrite,nonatomic)UIImageView * cheseView;
@property (assign)CGPoint pointLocation;
@property (assign)BOOL isLegal;//棋子的走法是否合法,初始为非法
@property (assign,readwrite,nonatomic)UIButton * optionButton;
@property (assign,readwrite,nonatomic)BOOL isShouldremoveChesePieces;//当一方开始移动吃子的时候,如果点在了另一个子上面就吃掉
@property (assign,readwrite,nonatomic)UIButton * removeButton;
@property (assign)int theDeadBlackCheseNumber;
@property (assign)int theDeadRedCheseNumber;
@property (assign)BOOL ischessReverse;//1 b 0red
@property (nonatomic, strong) NSString *otherId;
-(void) cheseInterRezult;
@property BOOL isnoMusic;//1无
@property NSInteger rezult;
-(void)loadCheseInterface;
- (void) removenotifition;



@end
//int ischessReverse;
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
