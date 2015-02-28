//
//  CheseInterface.m
//  象棋Demo
//
//  Created by QzydeMac on 14/11/30.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import "CheseInterface.h"
#import "CheseTools.h"
#import "RootViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CDSessionManager.h"
@interface CheseInterface()


@property(weak, nonatomic)NSDictionary *senddict;
@end


@implementation CheseInterface
static  BOOL isShouldBlackChessPlayer = YES;
static BOOL isShouldRedChessPlayer = YES;
int cheseIndex[9][10];//存储棋子的小标索引,以及棋子的类型(黑方/红方),最后一个数组位有三种状态,0空位 1.黑车 2、黑马 3、黑像 4、黑士5、黑将 6、黑炮 7、黑卒  101 红车 102 红马 103 红相 104 红士 105 红帅 106 红炮 107 红兵
int blackChesePngIndex[16] = {0,1,2,3,4,3,2,1,0,5,5,6,6,6,6,6};
int redChesePngIndex[16] = {100,101,102,103,104,103,102,101,100,105,105,106,106,106,106,106};
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//- (void)dealloc
//{
//    [_cheseView release];
//    _cheseView = nil;
//    [super dealloc];
//}


- (id)initWithFrame :(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
//        self.userother = [[UserOther alloc]init];
//        [self loadCheseInterface:frame];
    }
    return self;
}
//- (void)moveChess:(NSNotification *)notify
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (isShouldBlackChessPlayer||isShouldRedChessPlayer) {
//            return;
//        }
//        NSDictionary *dict = notify.userInfo;
//        NSString *fromID = [dict objectForKey:@"fromid"];
//        dict = [dict objectForKey:@"cmd"];
//        if (![fromID isEqualToString:self.otherId])
//        {
//            return;
//        }
//        
////        NSDictionary *message_value = [dict objectForKey:@"message"];
//        NSString *chess_cmd = [dict objectForKey:@"CHESS_CMD"];
//        NSString *chess_x = [dict objectForKey:@"CHESS_X"];
//        NSString *chess_tag = [dict objectForKey:@"CHESS_TAG"];
//        NSInteger tag = [chess_tag integerValue];
//        _optionButton = (UIButton *)[self viewWithTag:tag];
//        NSInteger cmdindex = [chess_cmd integerValue];
////        NSLog(@"receve a data:%@",err);
//        
//        switch (cmdindex)
//        {
//            case CHESS_CMD_MOVE://MOVE
//            {
//                NSString *chess_y = [dict objectForKey:@"CHESS_Y"];
//                NSInteger x = [chess_x integerValue];
//                NSInteger y = [chess_y integerValue];
//                x = 8 - x;
//                y = 9 - y;
//                _pointLocation.x = chessStartPointX + (lenthOfUnitWidth*x);
//                _pointLocation.y = chessStartPointY + (lenthOfUnitHight*y);
//                seconds = 180;
//                [self opponentmovechess];
//            }
//                break;
//            case CHESS_CMD_REMOVE://REMOVE
//            {
//                NSString *chess_newtag = [dict objectForKey:@"NEW_CHESS_TAG"];
//                NSInteger newtag = [chess_newtag integerValue];
//                UIButton *newbutton =(UIButton *) [self viewWithTag:newtag];
//                [self opponentremoveChesePiecesAnimation:newbutton];
//                seconds = 180;
//            }
//                break;
//            default:
//                break;
//        }
//
//        });
//    
//}
- (void) touchChessMusic
{
    if (!self.isnoMusic) {
        NSURL *url = [[NSBundle mainBundle]URLForResource:@"chosechess" withExtension:@"wav"];
        SystemSoundID soundId =0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
        AudioServicesPlaySystemSound(soundId);
    }
    
}
- (void) removechessMusic
{
    if (!self.isnoMusic) {
        NSURL *url = [[NSBundle mainBundle]URLForResource:@"removechess" withExtension:@"wav"];
        SystemSoundID soundId =0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
        AudioServicesPlaySystemSound(soundId);
    }
    
}

- (void) removenotifition
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAY_CHESS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAY_CHESS_SEND_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAY_CHESS_SEND_FINISH object:nil];
}


- (void)loadCheseInterface
{
    
    CGRect rect = self.frame;
    for (int i = 0; i < 9; i++)
    {
        for (int j = 0; j<10; j++)
        {
            cheseIndex[i][j] = noneOccupy;//初始化全部为0
        }
    }
    for (int i=1;i<120; i++)
    {
        UIButton *newbutton =(UIButton *) [self viewWithTag:i];
        [newbutton removeFromSuperview];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveChess:) name:NOTIFI_CHESS_MOVE object:nil];
//    [[RuntimeStatus instance].udpP2P sendData:[NSData dataWithBytes:"hello world" length:11] toHost:@"192.168.1.13" port:20108 withTimeout:3 tag:0];
//    rect.origin.x +=lenthOfUnitWidth/2;
    rect.origin.y +=2.5*lenthOfUnitHight;
    rect.size.height -= 4.6*lenthOfUnitHight;
    rect.origin.x = -20;
    rect.size.width +=40;
//    rect.size.width -=lenthOfUnitWidth;
    _cheseView = [[UIImageView alloc]initWithFrame:rect];
    _cheseView.image = [UIImage imageNamed:@"象棋棋盘.png"];
    _cheseView.userInteractionEnabled = YES;
    //CGRectContainsPoint(<#CGRect rect#>, <#CGPoint point#>)判断选中点是否在点击范围的方法
    _isShouldremoveChesePieces = NO;
    _optionButton = nil;
    [self addSubview:_cheseView];
    if(self.ischessReverse)
    {
        [self loadUpChesePieces:redChesePngIndex];//加载上面棋盘
        [self loadDownChesePieces:blackChesePngIndex];
        ischessToolsReverse = 1;
        isShouldBlackChessPlayer = NO;
        isShouldRedChessPlayer = NO;
    }
    else
    {
        [self loadUpChesePieces:blackChesePngIndex];//加载上面棋盘
        [self loadDownChesePieces:redChesePngIndex];
        ischessToolsReverse = 0;
        isShouldRedChessPlayer = YES;
        isShouldBlackChessPlayer = NO;
    }
    
    _theDeadBlackCheseNumber = 1;
    _theDeadRedCheseNumber = 1;//记录红色棋子被吃掉的个数
    
    
}


- (void)loadUpChesePieces:(int *)chessindex//布置上面棋盘
{

    for (int i = 0; i<9; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth*i, chessStartPointY, widthChesePieces,lenthChesePieces);

        int index = i;

        if (index > 4)
        {
            index = 8 - index;
        }

        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",chessindex[i]]] forState:UIControlStateNormal];
        btn.tag = i+1+chessindex[0];
        cheseIndex[i][0] = (int)btn.tag;
        [btn addTarget:self action:@selector(moveChesePieces:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }

    for (int i = 0; i < 2; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==0)
        {
            btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth, chessStartPointY+lenthOfUnitHight*2,widthChesePieces, lenthChesePieces );
            btn.tag = 10+chessindex[0];
            cheseIndex[1][2]=(int)btn.tag;
        }
        else
        {
            btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth*7, chessStartPointY+lenthOfUnitHight*2,widthChesePieces, lenthChesePieces);
            btn.tag = 11+chessindex[0];
            cheseIndex[7][2]=(int)btn.tag;
        }
        
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",chessindex[0]+5]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(moveChesePieces:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }

    for (int i = 0; i<5; i++)
    {

        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(chessStartPointX+lenthOfUnitWidth*i*2, chessStartPointY+lenthOfUnitHight*3,widthChesePieces, lenthChesePieces)];
        btn.tag = 12+i+chessindex[0];
        cheseIndex[i*2][3]=(int)btn.tag;
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",chessindex[0]+6]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(moveChesePieces:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}
//棋子坐标:(-5+lenthOfUnitWidth*i,155+30*j,30,30);
- (void)loadDownChesePieces:(int *)chessindex//布置下面棋盘
{

    for (int i = 0; i<5; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];

        btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth*i*2, chessStartPointY+lenthOfUnitHight*6,widthChesePieces, lenthChesePieces);

        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",chessindex[0]+6] ] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(moveChesePieces:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 16-i+chessindex[0];
        cheseIndex[i*2][6] = (int)btn.tag;
        [self addSubview:btn];
    }

    for (int i = 0; i<2; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==0)
        {
            btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth, chessStartPointY+lenthOfUnitHight*7, widthChesePieces,lenthChesePieces);
            btn.tag = 11-i+chessindex[0];
            cheseIndex[1][7] = (int)btn.tag;
        }

        if (i==1)
        {
            btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth*7, chessStartPointY+lenthOfUnitHight*7, widthChesePieces,lenthChesePieces);
            btn.tag = 11-i+chessindex[0];
            cheseIndex[7][7] = (int)btn.tag;
        }
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",chessindex[0]+5]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(moveChesePieces:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }

    for (int i = 0; i<9; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(chessStartPointX+lenthOfUnitWidth*i, chessStartPointY+lenthOfUnitHight*9, widthChesePieces,lenthChesePieces);

        int index = i;

        if (index > 4)
        {
            index = 8 - index;
        }
        
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",chessindex[i]]] forState:UIControlStateNormal];
        btn.tag = 9-i+chessindex[0];
        cheseIndex[i][9]=(int)btn.tag;
        [btn addTarget:self action:@selector(moveChesePieces:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)moveChesePieces:(UIButton *)chesePieces
{
    
    if (_optionButton)//前一个子还没有清空,表示不是移动到空位置上,而是移动到对方的子上了
    {
        if (abs((int)_optionButton.tag-(int)chesePieces.tag)<=16)//一家人,当然不能吃了
        {
            if (chesePieces.tag>=1&&chesePieces.tag<=16)
            {
                [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",blackChesePngIndex[_optionButton.tag-1]]] forState:UIControlStateNormal];
            }
            else
            {
                [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",redChesePngIndex[_optionButton.tag - 101]]] forState:UIControlStateNormal];
            }
            _optionButton = nil;

            [self moveChesePieces:chesePieces];
        }
        else
        {
            //不是一家人也要判断吃子规则是否满足,不满足还是不能吃
            [self removeChesePiecesAnimation:chesePieces];
        }
    }
    else if (chesePieces.tag>=1&&chesePieces.tag<=16)
    {
        if (isShouldBlackChessPlayer) {
            _isLegal = NO;
            [self touchChessMusic];
            _optionButton = chesePieces;
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",blackChesePngIndex[chesePieces.tag - 1]+10]] forState:UIControlStateNormal];
           // _isShouldremoveChesePieces = YES;
           // isShouldRedChessPlayer = NO;
        }
    }
    else
    {
        if (isShouldRedChessPlayer) {
            _isLegal = NO;
            [self touchChessMusic];
            _optionButton = chesePieces;
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",redChesePngIndex[chesePieces.tag - 101]+10]] forState:UIControlStateNormal];
          //  isShouldBlackChessPlayer = NO;
          //  _isShouldremoveChesePieces = YES;
        }
    }
}

//除去对方棋子方法
- (void)removeChesePiecesAnimation:(UIButton *)chesePieces
{
    
    CGPoint pointNewLocation = chesePieces.frame.origin;//判定吃子是否符合规则
    if (_optionButton.tag<100)
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &pointNewLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",blackChesePngIndex[_optionButton.tag-1]]] forState:UIControlStateNormal];
            // [_delegate showWhoShouldPlayChese:2];
        }
    }
    else
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &pointNewLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",redChesePngIndex[_optionButton.tag - 101]]] forState:UIControlStateNormal];
            // [_delegate showWhoShouldPlayChese:1];
        }
    }
    
    if (!_isLegal)//如果是非法吃子
    {
        //  _optionButton = nil;
        return;
    }
    NSString *str_cmd = [[NSString alloc]initWithFormat:@"%d",1];
    NSString *str_tag = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",(int)_optionButton.tag]];
    NSString *str_newtag = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",(int)chesePieces.tag]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str_cmd,@"CHESS_CMD",str_tag,@"CHESS_TAG",str_newtag, @"NEW_CHESS_TAG", nil];
    //                [[RuntimeStatus instance].udpP2P sendDict:dict toUser:self.userother withProtocol:CHESS];
    
    self.senddict = dict;
    [self.delegate cheseInterSendcmd:self.senddict];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        
        _optionButton.frame = chesePieces.frame;
        
    } completion:^(BOOL finished) {
        
        if (chesePieces.tag == 5)
        {
            
            if (self.ischessReverse) {
                self.rezult = 0 ;
            }
            else
            {
                self.rezult = 1;
            }
            [self.delegate cheseInterRezult];
            
        }
        else if (chesePieces.tag == 105)
        {
            
            if (self.ischessReverse) {
                self.rezult = 1 ;
            }
            else
            {
                self.rezult = 0;
            }
            [self.delegate cheseInterRezult];
        }
        
        
        
        [chesePieces removeFromSuperview];
        [self moveComplete];
        
    }];
}

//除去对方棋子方法
- (void)opponentremoveChesePiecesAnimation:(UIButton *)chesePieces
{
    
    CGPoint pointNewLocation = chesePieces.frame.origin;//判定吃子是否符合规则
    if (_optionButton.tag<100)
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &pointNewLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",blackChesePngIndex[_optionButton.tag-1]]] forState:UIControlStateNormal];
           // [_delegate showWhoShouldPlayChese:2];
        }
    }
    else
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &pointNewLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",redChesePngIndex[_optionButton.tag - 101]]] forState:UIControlStateNormal];
           // [_delegate showWhoShouldPlayChese:1];
        }
    }
    
    if (!_isLegal)//如果是非法吃子
    {
      //  _optionButton = nil;
        return;
    }
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        
        _optionButton.frame = chesePieces.frame;
        
    } completion:^(BOOL finished) {
        
        if (chesePieces.tag == 5)
        {
//            UIView * gameView = [[UIView alloc]initWithFrame:self.bounds];
//            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//            label.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
//            label.textAlignment = NSTextAlignmentCenter;
//            [label setTextColor:[UIColor redColor]];
//            gameView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            label.font = [UIFont boldSystemFontOfSize:20];
//            [self addSubview:gameView];
//            [label setText:@"红方赢"];
//            [self addSubview:label];
            if (self.ischessReverse) {
                self.rezult = 0 ;
            }
            else
            {
                self.rezult = 1;
            }
            [self.delegate cheseInterRezult];
            
        }
        else if (chesePieces.tag == 105)
        {
//            UIView * gameView = [[UIView alloc]initWithFrame:self.bounds];
//            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//            label.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
//            [label setTextColor:[UIColor redColor]];
//            label.textAlignment = NSTextAlignmentCenter;
//            label.font = [UIFont boldSystemFontOfSize:20];
//            gameView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            [self addSubview:gameView];
//            [label setText:@"黑方赢"];
//            [self addSubview:label];
            if (self.ischessReverse) {
                self.rezult = 1 ;
            }
            else
            {
                self.rezult = 0;
            }
            [self.delegate cheseInterRezult];
        }

        
        
        [chesePieces removeFromSuperview];
        [self moveComplete];
        
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    
    _pointLocation = [touch locationInView:self];
    
    [self move];
}

- (void)move
{
    if (_optionButton.tag<100)
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &_pointLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",blackChesePngIndex[_optionButton.tag-1]]] forState:UIControlStateNormal];
          // [_delegate showWhoShouldPlayChese:2];
        }
    }
    else
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &_pointLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",redChesePngIndex[_optionButton.tag - 101]]] forState:UIControlStateNormal];
         //   [_delegate showWhoShouldPlayChese:1];
        }
    }
    //传地址就是为了能够更好的调整移动位置
    if (_isLegal)
    {
            NSString *str_tag = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",(int)_optionButton.tag]];
            NSString *str_cmd = [[NSString alloc]initWithFormat:@"%d",0];
            Piecesindex newPiecesindex=getIndexOfPieces(_pointLocation);
            NSString *str_x = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",(int)newPiecesindex.x]];
            NSString *str_y = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",(int)newPiecesindex.y]];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str_cmd,@"CHESS_CMD", str_tag,@"CHESS_TAG",str_x, @"CHESS_X", str_y, @"CHESS_Y", nil];
            self.senddict = dict;
         //   [[CDSessionManager sharedInstance] sendPlayChess:self.senddict toPeerId:self.otherId];
        [self.delegate cheseInterSendcmd:self.senddict];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{

            _optionButton.layer.transform = CATransform3DTranslate(_optionButton.layer.transform, _pointLocation.x - _optionButton.frame.origin.x, _pointLocation.y - _optionButton.frame.origin.y, 0);

        } completion:^(BOOL finished) {
           [self moveComplete];
        }];
    }
}
-(void)opponentmovechess
{
    if (_optionButton.tag<100)
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &_pointLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",blackChesePngIndex[_optionButton.tag-1]]] forState:UIControlStateNormal];
            // [_delegate showWhoShouldPlayChese:2];
        }
    }
    else
    {
        _isLegal = isLegalRuleToJumpNewLocationOfChese(_optionButton, _optionButton.frame, &_pointLocation,cheseIndex);
        if (_isLegal) {
            [_optionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",redChesePngIndex[_optionButton.tag - 101]]] forState:UIControlStateNormal];
            //   [_delegate showWhoShouldPlayChese:1];
        }
    }
    //传地址就是为了能够更好的调整移动位置
    if (_isLegal)
    {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            _optionButton.layer.transform = CATransform3DTranslate(_optionButton.layer.transform, _pointLocation.x - _optionButton.frame.origin.x, _pointLocation.y - _optionButton.frame.origin.y, 0);
            
        } completion:^(BOOL finished) {
            [self moveComplete];
        }];
    }
}

- (void)moveComplete
{
    
    isShouldBlackChessPlayer = !isShouldBlackChessPlayer;
    isShouldRedChessPlayer = !isShouldRedChessPlayer;
    [self removechessMusic];

    if (ischessToolsReverse) {
        isShouldRedChessPlayer = FALSE;
    }
    else
    {
        isShouldBlackChessPlayer = FALSE;
    }
    _optionButton = nil;
}
@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
