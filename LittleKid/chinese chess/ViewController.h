//
//  ViewController.h
//  Start_Me_Up_New
//
//  Created by xmhouse on 9/11/13.
//  Copyright (c) 2013 xmhouse. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ViewControllerDelegate <NSObject>

- (void) ViewControllerCancel:(UIViewController *)ViewController;

@end

@interface ViewController : UIViewController
{
    UIImageView *image1,*image2;
    float random;
    float orign;
}
@property (nonatomic, weak) id<ViewControllerDelegate> delegate;
@end
