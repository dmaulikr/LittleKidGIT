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

#define lenthOfUnitWidth 35

#define lenthOfUnitHight 40

#define lenthChesePieces 40

#define widthChesePieces 35

#define chessboardStartPointy 30

#define chessStartPointY chessboardStartPointy+60//-20



#define chessStartPointX 0//-10

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
