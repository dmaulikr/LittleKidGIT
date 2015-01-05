//
//  ViewControllerContact.h
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableViewCell.h"

@interface ViewControllerContact : UIViewController <UITableViewDelegate, UITableViewDataSource>



@end

/* contact class define */
@interface Contact : NSObject

@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *phoneNumber;

@end



