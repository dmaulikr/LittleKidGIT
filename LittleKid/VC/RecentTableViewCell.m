//
//  RecentTableViewCell.m
//  LittleKid
//
//  Created by 李允恺 on 12/26/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "RecentTableViewCell.h"

@implementation RecentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.headPicture.layer.cornerRadius = (self.headPicture.layer.frame.size.height/2);
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zuijin_roundCornerRect"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
