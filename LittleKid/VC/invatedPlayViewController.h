//
//  invatedPlayViewController.h
//  LittleKid
//
//  Created by XC on 15-1-29.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface invatedPlayViewController : UIViewController<RootViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *otherphoto;
@property (weak, nonatomic) IBOutlet UILabel *otherid;
@property (strong, nonatomic)NSString * toid;

@end
