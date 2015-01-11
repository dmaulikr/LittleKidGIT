//
//  CheseTools.m
//  象棋Demo
//
//  Created by QzydeMac on 14/12/1.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import "CheseTools.h"
//int ischessReverse;
#pragma mark --判断从oldLocation,移动到newLocation是否合法
BOOL isLegalRuleToJumpNewLocationOfChese(UIButton * piecesButton,CGRect oldLocation,CGPoint *newLocation,int cheseIndex[][10])
{
    
    BOOL isFindPointLocation=NO;
    for (int i = 0; i<9; i++)
    {
        for (int j = 0; j < 10; j++)
        {
            CGRect rect = CGRectMake(lenthOfUnitWidth*i+chessStartPointX,chessStartPointY+lenthOfUnitHight*j, widthChesePieces,lenthChesePieces);
            
/*            if (j>=5)
            {
                rect.origin.y+=lenthOfUnitHight;
            }
            
*/            if(CGRectContainsPoint(rect, *newLocation))
            {
                *newLocation = rect.origin;
                isFindPointLocation = YES;
                break;
            }
        }
        if (isFindPointLocation)
        {
            break;
        }
    }
    
    
    if (!isFindPointLocation)//没有发现合法坐标则是非法移动位置,不移动
    {
        return NO;
    }
    
    if (piecesButton.tag>100)
    {
        redChesePiecesTagWeight = 100;
        generalOrSoldierMoveScope = TheRedGeneralOrSoldierMoveScope;
        isRedOrBlackChesePieces = RedChesePieces;
    }
    else
    {
        redChesePiecesTagWeight = 0;
        generalOrSoldierMoveScope = TheBlackGeneralOrSoldierMoveScope;
        isRedOrBlackChesePieces = BlackChesePieces;
    }
    if (oldLocation.origin.y<lenthOfUnitHight*4)
    {
        generalOrSoldierMoveScope = TheBlackGeneralOrSoldierMoveScope;
    }
    else
    {
        generalOrSoldierMoveScope = TheRedGeneralOrSoldierMoveScope;
    }
    
    if (piecesButton.tag == 1+redChesePiecesTagWeight||piecesButton.tag == 9+redChesePiecesTagWeight)//处理军走法
    {
        moveFunc = isLegalVehicleJumpRule;
    }
    else if (piecesButton.tag == 2+redChesePiecesTagWeight||piecesButton.tag == 8+redChesePiecesTagWeight)//马
    {
        moveFunc = isLegalHorseJumpRule;
    }
    else if (piecesButton.tag == 3+redChesePiecesTagWeight||piecesButton.tag == 7+redChesePiecesTagWeight)//相
    {
        moveFunc = isLegalElephantJumpRule;
    }
    else if (piecesButton.tag == 4+redChesePiecesTagWeight||piecesButton.tag == 6+redChesePiecesTagWeight)//士
    {
        moveFunc = isLegalSoldierJumpRule;
    }
    else if (piecesButton.tag == 5+redChesePiecesTagWeight)//将军
    {
        moveFunc = isLegalGeneralJumpRule;
    }
    else if (piecesButton.tag ==10+redChesePiecesTagWeight||piecesButton.tag == 11+redChesePiecesTagWeight)//炮
    {
        moveFunc = isLegalBombJumpRule;
    }
    else//卒
    {
        moveFunc = isLegalhurriedlyJumpRule;
    }
    
    return moveFunc(oldLocation.origin,*newLocation,cheseIndex);
}

#pragma mark -- 移动合法,将棋盘的移动位置上的数组变量重新布置
void moveDownAndSetNewCheseIndex(int cheseIndex[][10],Piecesindex oldLocationIndex,Piecesindex newLocationIndex)
{

    cheseIndex[newLocationIndex.x][newLocationIndex.y] = cheseIndex[oldLocationIndex.x][oldLocationIndex.y];
    
    cheseIndex[oldLocationIndex.x][oldLocationIndex.y] = 0;
    
    //printfCheseIndex(cheseIndex);
}
#pragma mark -- 根据棋子的位置,获取棋子的数组下标
Piecesindex getIndexOfPieces(CGPoint point)//获取棋子的坐标位置,将原先的位置和将要移动的位置进行比较,可以知道中间有无障碍
{
    Piecesindex locationIndex;
    
    BOOL findPoint = NO;
    for (int i = 0; i<9; i++)
    {
        for (int j = 0; j < 10; j++)
        {
            CGRect rect = CGRectMake(chessStartPointX+lenthOfUnitWidth*i, chessStartPointY+ lenthOfUnitHight*j, widthChesePieces, lenthChesePieces);
            
/*            if (j>=5)
            {
                rect.origin.y+=lenthOfUnitHight;
            }
            
 */           if(CGRectContainsPoint(rect, point))
            {
                locationIndex.y = j;
                locationIndex.x = i;
                findPoint = YES;
                break;
            }
        }
        if (findPoint) {
            break;
        }
    }
    return locationIndex;
}
#pragma mark -- 主要是用来判断,移动后棋盘的数组变量是否发生变化
void printfCheseIndex(int cheseIndex[][10])
{
    for (int i = 0; i < 10; i++)
    {
        for (int j = 0; j<9; j++)
        {
            printf("%d\t",cheseIndex[j][i]);
        }
        printf("\n");
    }
}
#pragma mark -- 兵-卒走法判断
BOOL isLegalhurriedlyJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])//兵
{
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    int isReseve;
    if (ischessToolsReverse)
    {
        isReseve = -1;
    }
    else
    {
        isReseve =1;
    }
    
    if ((((oldLocation.x+lenthOfUnitWidth == newLocation.x||(oldLocation.x-lenthOfUnitWidth == newLocation.x))&&(oldLocation.y == newLocation.y))&&(oldLocationIndex.y>4)&&((isRedOrBlackChesePieces == BlackChesePieces&&(!ischessToolsReverse))||(isRedOrBlackChesePieces == RedChesePieces&&ischessToolsReverse)))
        
        
        ||((oldLocation.x-lenthOfUnitWidth == newLocation.x||(oldLocation.x+lenthOfUnitWidth == newLocation.x))&&(oldLocation.y == newLocation.y)&&(oldLocationIndex.y<5)&&(((isRedOrBlackChesePieces == RedChesePieces&&(!ischessToolsReverse)))||(isRedOrBlackChesePieces == BlackChesePieces&&(ischessToolsReverse))))
        
        
        ||((oldLocation.x == newLocation.x)&&(oldLocation.y+30*isRedOrBlackChesePieces*isReseve == newLocation.y))
        
        ||((oldLocation.x == newLocation.x)&&(oldLocation.y+40*isRedOrBlackChesePieces*isReseve == newLocation.y)))
    {
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    
    return NO;
}

#pragma mark -- 炮走法
BOOL isLegalBombJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])
{
    int chesePiecesCount = 0;//用来记录在新旧位置之间的棋子个数,有一个就是合法移动,有0个只有在该位置是空缺的时候才是合法移动
    
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    
    if (oldLocationIndex.x == newLocationIndex.x)
    {
        
        if (oldLocationIndex.y<newLocationIndex.y)
        {
            for (int i = oldLocationIndex.y+1; i<newLocationIndex.y; i++)//向下吃子,注意应该在移动的两颗棋子之间遍历,不能包含两个棋子的坐标
            {
                if (cheseIndex[oldLocationIndex.x][i])//不为0就是非法移动
                {
                    chesePiecesCount++;//中间有其它棋子,非法移动
                }
            }
        }
        else
        {
            for (int i = newLocationIndex.y+1; i<oldLocationIndex.y; i++)//向上吃子
            {
                if (cheseIndex[oldLocationIndex.x][i])//不为0就是非法移动
                {
                    chesePiecesCount++;//中间有其它棋子,非法移动
                }
            }
        }
        
    }
    else if (oldLocationIndex.y == newLocationIndex.y)//水平移动
    {
        if (oldLocationIndex.x<newLocationIndex.x)
        {
            for (int i = oldLocationIndex.x+1; i<newLocationIndex.x; i++)//向右吃子
            {
                if (cheseIndex[i][oldLocationIndex.y])//不为0就是非法移动
                {
                    chesePiecesCount++;//中间有其它棋子,非法移动
                }
            }
        }
        else
        {
            for (int i = newLocationIndex.x+1; i<oldLocationIndex.x; i++)//向左吃子
            {
                if (cheseIndex[i][oldLocationIndex.y])//不为0就是非法移动
                {
                    chesePiecesCount++;//中间有其它棋子,非法移动
                }
            }
        }
    }
    else
    {
        return NO;
    }
    //若是合法的移动位置,在移动之前,我们应该将数组的值进行改变,棋子原本的位置现在空缺下来,我们将其置0,移动到的位置,我们将原本位置的值替换掉新位置上的值
    
//    NSLog(@"middle Chess Count: %d",chesePiecesCount);
    
    if (chesePiecesCount == 0&&!cheseIndex[newLocationIndex.x][newLocationIndex.y])//为0,则炮的新位置上必须空缺
    {
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    else if(chesePiecesCount == 1&&cheseIndex[newLocationIndex.x][newLocationIndex.y])//为1,则新地方必须被敌方占领
    {
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    
    return NO;
}
#pragma mark -- 军走法
BOOL isLegalVehicleJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])
{
    
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    
    if (oldLocationIndex.x == newLocationIndex.x)
    {
        
        if (oldLocationIndex.y<newLocationIndex.y)
        {
            for (int i = oldLocationIndex.y+1; i<newLocationIndex.y; i++)//向下吃子,注意应该在移动的两颗棋子之间遍历,不能包含两个棋子的坐标
            {
                if (cheseIndex[oldLocationIndex.x][i])//不为0就是非法移动
                {
                    return NO;//中间有其它棋子,非法移动
                }
            }
        }
        else
        {
            for (int i = newLocationIndex.y+1; i<oldLocationIndex.y; i++)//向上吃子
            {
                if (cheseIndex[oldLocationIndex.x][i])//不为0就是非法移动
                {
                    return NO;//中间有其它棋子,非法移动
                }
            }
        }
        
    }
    else if (oldLocationIndex.y == newLocationIndex.y)//水平移动
    {
        if (oldLocationIndex.x<newLocationIndex.x)
        {
            for (int i = oldLocationIndex.x+1; i<newLocationIndex.x; i++)//向右吃子
            {
                if (cheseIndex[i][oldLocationIndex.y])//不为0就是非法移动
                {
                    return NO;//中间有其它棋子,非法移动
                }
            }
        }
        else
        {
            for (int i = newLocationIndex.x+1; i<oldLocationIndex.x; i++)//向左吃子
            {
                if (cheseIndex[i][oldLocationIndex.y])//不为0就是非法移动
                {
                    return NO;//中间有其它棋子,非法移动
                }
            }
        }
    }
    else
    {
        return NO;
    }
    //若是合法的移动位置,在移动之前,我们应该将数组的值进行改变,棋子原本的位置现在空缺下来,我们将其置0,移动到的位置,我们将原本位置的值替换掉新位置上的值
    
    moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
    
    return YES;
}

#pragma mark -- 象走法
BOOL isLegalElephantJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])
{
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    Piecesindex centerLocation;
    
    int sumMove = abs(oldLocation.x - newLocation.x)+abs(oldLocation.y-newLocation.y);
    if ((oldLocation.x!=newLocation.x&&oldLocation.y!=newLocation.y)&&(sumMove == 2*lenthOfUnitHight+2*lenthOfUnitWidth))
    {
        centerLocation.x = (oldLocationIndex.x+newLocationIndex.x)/2;
        centerLocation.y = (oldLocationIndex.y+newLocationIndex.y)/2;
        
        if (cheseIndex[centerLocation.x][centerLocation.y])//相腿位置,有人这不能移动
        {
            return NO;
        }
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    return NO;
}

#pragma mark -- 马走法
BOOL isLegalHorseJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])
{
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    
    int sumMove = abs(oldLocation.x - newLocation.x)+abs(oldLocation.y-newLocation.y);
    if ((oldLocation.x!=newLocation.x&&oldLocation.y!=newLocation.y)&&(sumMove == 2*lenthOfUnitHight+lenthOfUnitWidth||sumMove == 2*lenthOfUnitWidth+lenthOfUnitHight))
    {
        Piecesindex obstacleIndex;
        if (abs(oldLocationIndex.x-newLocationIndex.x)==2)
        {
            obstacleIndex.x = (oldLocationIndex.x + newLocationIndex.x)/2;
            obstacleIndex.y = oldLocationIndex.y;
            if (cheseIndex[obstacleIndex.x][obstacleIndex.y])
            {
                return NO;
            }
        }
        else if (abs(oldLocationIndex.y-newLocationIndex.y)==2)
        {
            obstacleIndex.y = (oldLocationIndex.y + newLocationIndex.y)/2;
            obstacleIndex.x = oldLocationIndex.x;
            if (cheseIndex[obstacleIndex.x][obstacleIndex.y])
            {
                return NO;
            }
        }
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    return NO;
}
#pragma mark -- 士走法
BOOL isLegalSoldierJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])
{
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    
    int sumMove = abs(oldLocation.x - newLocation.x)+abs(oldLocation.y-newLocation.y);
    if ((oldLocation.x!=newLocation.x&&oldLocation.y!=newLocation.y)&&(sumMove == lenthOfUnitWidth+lenthOfUnitHight)&&CGRectContainsPoint(generalOrSoldierMoveScope(), newLocation))
    {
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    return NO;
}

#pragma mark -- 将-帅走法
BOOL isLegalGeneralJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10])
{
    Piecesindex oldLocationIndex=getIndexOfPieces(oldLocation);
    
    Piecesindex newLocationIndex = getIndexOfPieces(newLocation);
    
    if (isRedOrBlackChesePieces == BlackChesePieces)//红方帅
    {
        if(oldLocationIndex.x != newLocationIndex.x)//将帅在同一条线上
        {
            if (oldLocationIndex.y<5)
            {
                for (int i = newLocationIndex.y+1; i<9; i++)//判断将帅中间是否有障碍
                {
                    if (cheseIndex[newLocationIndex.x][i]&&cheseIndex[newLocationIndex.x][i]!=105)//为真,表示中间有其他棋子
                    {
                        break;
                    }
                    if (cheseIndex[newLocationIndex.x][i] == 105)
                    {
                        return NO;
                    }
                }
            }
            else
            {
                for (int i = newLocationIndex.y-1; i>0; i--)//判断将帅中间是否有障碍
                {
                    if (cheseIndex[newLocationIndex.x][i]&&cheseIndex[newLocationIndex.x][i]!=105)//为真,表示中间有其他棋子
                    {
                        break;
                    }
                    if (cheseIndex[newLocationIndex.x][i] == 105)
                    {
                        return NO;
                    }
                }
            }
            //return YES;//此处不需要更新棋盘位置了,因为游戏已经结束O(∩_∩)O~
        }
    }
    else//黑方将
    {
        if(oldLocationIndex.x != newLocationIndex.x)
        {
            if (oldLocationIndex.y<5)
            {
                    for (int i = newLocationIndex.y+1; i<9; i++)//判断将帅中间是否有障碍
                    {
                        if (cheseIndex[newLocationIndex.x][i]&&cheseIndex[newLocationIndex.x][i]!=5)//为真,表示中间有其他棋子
                        {
                            break;
                        }
                        if (cheseIndex[newLocationIndex.x][i] == 5)
                        {
                            return NO;
                        }
                    }
            }
            else
            {
                    for (int i = newLocationIndex.y-1; i>0; i--)//判断将帅中间是否有障碍
                    {
                        if (cheseIndex[newLocationIndex.x][i]&&cheseIndex[newLocationIndex.x][i]!=5)//为真,表示中间有其他棋子
                        {
                            break;
                        }
                        if (cheseIndex[newLocationIndex.x][i] == 5)
                        {
                            return NO;
                        }
                    }
            }
            
        }
            
    }
    
    BOOL islegalMoveLenth = isLegalGeneralMoveLenth(oldLocation, newLocation);
    
    if ((oldLocation.x == newLocation.x||oldLocation.y == newLocation.y)&&islegalMoveLenth&&CGRectContainsPoint(generalOrSoldierMoveScope(), newLocation))
    {
        moveDownAndSetNewCheseIndex(cheseIndex, oldLocationIndex, newLocationIndex);
        return YES;
    }
    return NO;
}

#pragma mark -- 黑方将移动范围
CGRect TheBlackGeneralOrSoldierMoveScope()
{
    return CGRectMake(lenthOfUnitWidth*3+chessStartPointX-20, chessStartPointY-20, lenthOfUnitWidth*3, lenthOfUnitHight*3);//原为(100,-5,70,60)由于浮点型数据精度丢失,所以扩大一点方位,这并不影响
}

#pragma mark -- 红方将移动范围
CGRect TheRedGeneralOrSoldierMoveScope()
{
    return CGRectMake(lenthOfUnitWidth*3+chessStartPointX-20, chessStartPointY-20+lenthOfUnitHight*7, lenthOfUnitWidth*3, lenthOfUnitHight*3);
}

#pragma mark -- 将-帅棋子一次移动长度
BOOL isLegalGeneralMoveLenth(CGPoint oldLocation,CGPoint newLocation)
{
    int sumMove = abs(oldLocation.x - newLocation.x)+abs(oldLocation.y-newLocation.y);
    if (sumMove<10+lenthOfUnitHight)//只要它移动的位置小于36即可
    {
        return YES;
    }
    return NO;
}
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
