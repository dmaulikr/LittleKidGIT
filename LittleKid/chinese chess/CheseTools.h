//
//  CheseTools.h
//  象棋Demo
//
//  Created by QzydeMac on 14/12/1.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef struct index
{
    int x;
    int y;
}Piecesindex;

#define RedChesePieces -1

#define BlackChesePieces 1

#define occupyByRedChese 2

#define occupyByBlackChese 1

#define noneOccupy  0



#define CHESS_CMD_MOVE  0
#define CHESS_CMD_REMOVE 1
#define CHESS_CMD_BACKMOVE 2
#define CHESS_CMD_DRAWOFFER 3
#define CHESS_CMD_DEFEAL 4
#define CHESS_CMD_ACK 5
#define CHESS_CMD_CHECK 6

extern int lenthOfUnitWidth;//  (int)(MAINSCREEN_WIDTH/9.14)

extern int lenthOfUnitHight;// (int)(MAINSCREEN_HEIGHT/14.4)

extern int lenthChesePieces;// lenthOfUnitHight

extern int widthChesePieces;// lenthOfUnitWidth

extern int chessboardStartPointy;// (int)(MAINSCREEN_HEIGHT/19.2)

extern int chessStartPointY;// (int)chessboardStartPointy*3
extern int chessStartPointX;


#define chessboardWidth   296

#define chessboardHight   400

Piecesindex getIndexOfPieces(CGPoint point);

CGRect TheBlackGeneralOrSoldierMoveScope();

CGRect TheRedGeneralOrSoldierMoveScope();

typedef CGRect (*TheGeneralOrSoldierMoveScope)();

TheGeneralOrSoldierMoveScope generalOrSoldierMoveScope;

NSUInteger redChesePiecesTagWeight;//红色棋子比黑色棋子的tag值高100个权重

void printfCheseIndex(int cheseIndex[][10]);

typedef BOOL (*cheseMoveFunc)(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

cheseMoveFunc moveFunc;
BOOL ischessToolsReverse;
int isRedOrBlackChesePieces;
void moveDownAndSetNewCheseIndex(int cheseIndex[][10],Piecesindex oldLocationIndex,Piecesindex newLocationIndex);

BOOL isLegalGeneralMoveLenth(CGPoint oldLocation,CGPoint newLocation);

BOOL isLegalRuleToJumpNewLocationOfChese(UIButton * piecesButton,CGRect oldLocation,CGPoint *newLocation,int cheseIndex[][10]);

BOOL isLegalBombJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

BOOL isLegalVehicleJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

BOOL isLegalElephantJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

BOOL isLegalHorseJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

BOOL isLegalGeneralJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

BOOL isLegalSoldierJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

BOOL isLegalhurriedlyJumpRule(CGPoint oldLocation,CGPoint newLocation,int cheseIndex[][10]);

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
