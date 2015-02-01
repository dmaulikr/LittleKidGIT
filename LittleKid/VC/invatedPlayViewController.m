//
//  invatedPlayViewController.m
//  LittleKid
//
//  Created by XC on 15-1-29.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "invatedPlayViewController.h"
#import "CDSessionManager.h"
#import "RootViewController.h"

@interface invatedPlayViewController ()

@end

@implementation invatedPlayViewController
- (IBAction)accept:(id)sender {
    [[CDSessionManager sharedInstance] invitePlayChessAck:@"同意" toPeerId:self.toid];
    RootViewController *vc = [[RootViewController alloc] init];
    vc.otherId = self.otherid.text;
    vc.isblack = TRUE;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)reject:(id)sender {
    [[CDSessionManager sharedInstance] invitePlayChessAck:@"不同意" toPeerId:self.toid];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.otherid.text = self.toid;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rootViewControllerCancel:(RootViewController *)Controller
{
    NSLog(@"*** qb_imagePickerControllerDidCancel:");
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
